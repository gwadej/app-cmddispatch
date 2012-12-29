package App::CmdDispatch;

use warnings;
use strict;
use Config::Tiny;
use Term::ReadLine;
use App::CmdDispatch::IO;

our $VERSION = '0.004_01';

my $CMD_INDENT  = '  ';
my $HELP_INDENT = '        ';

my $SHORT_HELP = 'synopsis';
my $LONG_HELP  = 'help';

sub new
{
    my ( $class, $commands, $options ) = @_;
    $options ||= {};
    die "Command definition is not a hashref.\n" unless ref $commands eq ref {};
    die "No commands specified.\n"               unless keys %{$commands};
    die "Options parameter is not a hashref.\n"  unless ref $options  eq ref {};

    my %config      = %{$options};
    my $config_file = delete $config{config};
    my $io          = delete $config{io};
    if($io)
    {
        if(ref $io and 2 != grep { $io->can( $_ ) } qw/print prompt/)
        {
            die "Object supplied as io parameter does not supply correct interface.\n";
        }
    }
    else
    {
        $io = App::CmdDispatch::IO->new();
    }

    my $self = bless {
        cmds    => {},
        alias   => {},
        config  => \%config,
        io      => $io,
    }, $class;

    if( defined $config_file )
    {
        die "Supplied config is not a file.\n" unless -f $config_file;
        $self->_initialize_config( $config_file );
    }

    $self->_ensure_valid_command_description( $commands );

    return $self;
}

sub get_config { return $_[0]->{config}; }

sub run
{
    my ( $self, $cmd, @args ) = @_;

    if( _is_missing( $cmd ) )
    {
        $self->_print( "Missing command\n" );
        $self->_do_synopsis();
        return;
    }

    # Handle alias if one is supplied
    if( exists $self->{'alias'}->{$cmd} )
    {
        ( $cmd, @args ) = ( ( split / /, $self->{'alias'}->{$cmd} ), @args );
    }

    # Handle builtin commands
    if( $self->{cmds}->{$cmd} )
    {
        $self->{cmds}->{$cmd}->{'code'}->( $self, @args );
    }
    else
    {
        $self->_print( "Unrecognized command '$cmd'\n" );
        $self->_do_synopsis();
    }
    return;
}

sub _command_list
{
    my ( $self ) = @_;
    return ( sort grep { $_ ne $SHORT_HELP && $_ ne $LONG_HELP } keys %{ $self->{cmds} } ), grep { $self->{cmds}->{$_} } ($SHORT_HELP, $LONG_HELP);
}

sub _synopsis_string
{
    my ( $self, $cmd ) = @_;
    return $self->{cmds}->{$cmd}->{synopsis};
}

sub _help_string
{
    my ( $self, $cmd ) = @_;
    return join( "\n", map { $HELP_INDENT . $_ } split /\n/, $self->{cmds}->{$cmd}->{help} );
}

sub _list_command
{
    my ( $self, $code ) = @_;
    $self->_print( "\nCommands:\n" );
    foreach my $c ( $self->_command_list() )
    {
        next if $c eq '' or !$self->{cmds}->{$c};
        $self->_print( $code->( $c ) );
    }
    return;
}

sub synopsis
{
    my ( $self, $arg ) = @_;

    if( _is_missing( $arg ) )
    {
        $self->_list_command( sub { $CMD_INDENT, $self->_synopsis_string( $_[0] ), "\n"; } );
        $self->_list_aliases();
        return;
    }

    if( $self->{cmds}->{$arg} )
    {
        $self->_print( "\n", $self->_synopsis_string( $arg ), "\n" );
    }
    elsif( $arg eq 'commands' )
    {
        $self->_list_command( sub { $CMD_INDENT, $self->_synopsis_string( $_[0] ), "\n"; } );
    }
    elsif( $arg eq 'aliases' )
    {
        $self->_list_aliases();
    }
    else
    {
        $self->_print( "Unrecognized command '$arg'\n" );
    }

    return;
}

sub help
{
    my ( $self, $arg ) = @_;

    if( _is_missing( $arg ) )
    {
        $self->_list_command(
            sub {
                $CMD_INDENT, $self->_synopsis_string( $_[0] ), "\n", $self->_help_string( $_[0] ), "\n";
            }
        );
        $self->_list_aliases();
        return;
    }

    if( $self->{cmds}->{$arg} )
    {
        $self->_print(
            "\n",
            $self->_synopsis_string( $arg ),
            "\n",
            (
                $self->_help_string( $arg )
                    || $HELP_INDENT . "No synopsis for '$arg'"
            ),
            "\n"
        );
    }
    elsif( $arg eq 'commands' )
    {
        $self->_list_command(
            sub {
                $CMD_INDENT, $self->_synopsis_string( $_[0] ), "\n", $self->_help_string( $_[0] ), "\n";
            }
        );
    }
    elsif( $arg eq 'aliases' )
    {
        $self->_list_aliases();
    }
    else
    {
        $self->_print( "Unrecognized command '$arg'\n" );
    }

    return;
}

sub _do_synopsis
{
    my ($self) = @_;
    return $self->{cmds}->{$SHORT_HELP}->{code}->( $self ) if $self->{cmds}->{$SHORT_HELP};
    return $self->synopsis();
}

sub _list_aliases
{
    my ( $self ) = @_;
    return unless keys %{ $self->{'alias'} };

    $self->_print( "\nAliases:\n" );
    foreach my $c ( sort keys %{ $self->{'alias'} } )
    {
        $self->_print( "$CMD_INDENT$c\t: $self->{'alias'}->{$c}\n" );
    }
    return;
}

sub shell
{
    my ( $self ) = @_;

    $self->_print( "Enter a command or 'quit' to exit:\n" );
    while ( my $line = $self->_prompt( '> ' ) )
    {
        chomp $line;
        next unless $line =~ /\S/;
        last if $line eq 'quit';
        $self->run( split /\s+/, $line );
    }
    return;
}

sub _ensure_valid_command_description
{
    my ( $self, $cmds ) = @_;

    # Set defaults with closures that reference this object
    $self->{cmds}->{$LONG_HELP} = {
        code     => \&App::CmdDispatch::help,
        synopsis => "$LONG_HELP [command|alias]",
        help => "Display help about commands and/or aliases. Limit display with the\nargument.",
    };
    $self->{cmds}->{$SHORT_HELP} = {
        code     => \&App::CmdDispatch::synopsis,
        synopsis => "$SHORT_HELP [command|alias]",
        help => 'A list of commands and/or aliases. Limit display with the argument.',
    };
    $self->{cmds}->{shell} = {
        code     => \&App::CmdDispatch::shell,
        synopsis => 'shell',
        help     => 'Execute commands as entered until quit.',
    };

    # Override defaults with supplied commands.
    while ( my ( $key, $val ) = each %{$cmds} )
    {
        next if $key eq '';
        if( !defined $val )
        {
            delete $self->{cmds}->{$key};
            next;
        }
        die "Command '$key' is an invalid descriptor.\n" unless ref $val eq ref {};
        die "Command '$key' has no handler.\n" unless ref $val->{code} eq 'CODE';

        my $desc = { %{$val} };
        $desc->{synopsis} = $key unless defined $desc->{synopsis};
        $desc->{help}     = ''   unless defined $desc->{help};
        $self->{cmds}->{$key} = $desc;
    }

    return;
}

sub _initialize_config
{
    my ( $self, $config_file ) = @_;
    my $conf = Config::Tiny->read( $config_file );
    %{ $self->{alias} }  = %{ delete $conf->{alias} };
    %{ $self->{config} } = (
        ( $conf->{_} ? %{ delete $conf->{_} } : () ),    # first extract the top level
        %{$conf},                # Keep any multi-levels that are not aliases
        %{ $self->{config} },    # Override with supplied parameters
    );
    return;
}

sub _print
{
    my $self = shift;
    return  $self->{io}->print( @_ );
}

sub _prompt
{
    my $self = shift;
    return $self->{io}->prompt( @_ );
}

sub _is_missing { return !defined $_[0] || $_[0] eq ''; }

1;

__END__

=encoding utf-8

=head1 NAME

App::CmdDispatch - Handle command line processing for programs with subcommands

=head1 VERSION

This document describes App::CmdDispatch version 0.004_01

=head1 SYNOPSIS

    use App::CmdDispatch;

    my %cmds = (
        start => {
            code => sub { my $app = shift; print "start: @_\n"; },
            synopsis => 'start [what]',
            help => 'Start whatever is to be run.',
        },
        stop => {
            code => sub { my $app = shift; print "stop @_\n"; },
            synopsis => 'stop [what]',
            help => 'Stop whatever is to be run.',
        },
        stuff => {
            code => sub { my $app = shift; print "stuff: @_\n"; },
            synopsis => 'stuff [what]',
            help => 'Stuff to do.',
        },
        jump => {
            code => sub { my $app = shift; print "jump: @_\n"; },
            synopsis => 'jump [what]',
            help => 'Start whatever is to be run.',
        },
    );

    my $processor = App::CmdDispatch->new( \%cmds );
    $processor->run( @ARGV );

=head1 DESCRIPTION

One way to map a series of command strings to the code to execute for that
string is a dispatch table. The simplest dispatch table maps strings directly
to code refs. A more complicated dispatch table maps strings to objects that
provide a wider interface than just a single function call. I often find I want
more than a single function and less than a full object.

App::CmdDispatch falls in between these two extremes. One thing I always found
that I needed with my dispatch table-driven scripts was decent help that
covered all of the commands. App::CmdDispatch makes each command map to a hash
containing a code reference and a pair of help strings.

Since beginning to use git, I have found git's alias feature to be extremely
helpful. App::CmdDispatch supports reading aliases from a config file.

=head1 INTERFACE 

=head2 new( $cmdhash, $options )

Create a new C<App::CmdDispatch> object. This method can take one or two
hashrefs as arguments. The first is required and describes the commands.
The second is optional and provides option information for the
C<App::CmdDispatch> object.

=head2 run( $cmd, @args )

Look up the supplied command and execute it.

=head2 synopsis( $cmd )

Print a short synopsis listing all commands and aliases or just the synopsis
for the supplied command.

=head2 help( $cmd )

Print help for the program or just help on the supplied command.

=head2 shell()

Start a read/execute loop which supports running multiple commands in the same
execution of the main program.

=head2 set_in_out( $ifh, $ofh )

Reset the input and output file handles for the dispatcher.

=head2 get_config()

Return a reference to the configuration hash for the dispatcher.

=head1 CONFIGURATION AND ENVIRONMENT

App::CmdDispatch can read a configuration file specified in a Config::Tiny supported
format. Should be specified in the config parameter.

=head1 DEPENDENCIES

Config::Tiny
Term::Readline

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-app-cmddispatch@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

G. Wade Johnson  C<< <wade@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, G. Wade Johnson C<< <wade@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

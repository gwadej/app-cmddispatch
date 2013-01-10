package App::CmdDispatch;

use warnings;
use strict;
use Config::Tiny;
use Term::ReadLine;
use App::CmdDispatch::IO;
use App::CmdDispatch::Table;

our $VERSION = '0.004_02';

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
    die "Options parameter is not a hashref.\n"  unless $options and ref $options  eq ref {};

    my %config      = %{$options};
    my $config_file = delete $config{config};
    my $aliases;
    my $self = bless { config => \%config }, $class;
    if( defined $config_file )
    {
        die "Supplied config is not a file.\n" unless -f $config_file;
        $self->_initialize_config( $config_file );
        $aliases = delete $self->{config}->{alias};
    }
    $aliases = {} unless ref $aliases eq ref {};

    $commands = $self->_setup_commands( $commands );
    my $table = App::CmdDispatch::Table->new( $commands, $aliases );
    $self->_normalize_help( $table );

    my $io = delete $config{'io'};
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

    $self->{table} = $table;
    $self->{io}    = $io;

    return $self;
}

sub get_config { return $_[0]->{config}; }

sub run
{
    my ( $self, $cmd, @args ) = @_;

    eval {
        $self->{table}->run( $self, $cmd, @args );
        1;
    } or do {
        my $ex = $@;
        if( $ex eq App::CmdDispatch::Table::MissingCommand() )
        {
            $self->_print( "Missing command\n" );
            $self->synopsis;
        }
        elsif( $ex eq App::CmdDispatch::Table::UnknownCommand() )
        {
            $self->_print( "Unrecognized command '$cmd'\n" );
            $self->synopsis;
        }
        else
        {
            die $ex;
        }
    };
    return;
}

sub command_list
{
    my ( $self ) = @_;
    my @cmds = $self->{table}->command_list();
    return ( sort grep { $_ ne $SHORT_HELP && $_ ne $LONG_HELP } @cmds ), grep { $self->{table}->get_command( $_ ) } ($SHORT_HELP, $LONG_HELP);
}

sub _synopsis_string
{
    my ( $self, $cmd ) = @_;
    my $desc = $self->{table}->get_command( $cmd );
    return $desc ? $desc->{synopsis} : $desc;
}

sub _help_string
{
    my ( $self, $cmd ) = @_;
    my $desc = $self->{table}->get_command( $cmd );
    return '' unless defined $desc;
    return join( "\n", map { $HELP_INDENT . $_ } split /\n/, $desc->{help} );
}

sub _list_command
{
    my ( $self, $code ) = @_;
    $self->_print( "\nCommands:\n" );
    foreach my $c ( $self->command_list() )
    {
        next if $c eq '' or !$self->{table}->get_command( $c );
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

    if( $self->{table}->get_command( $arg ) )
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

    if( $self->{table}->get_command( $arg ) )
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
    my $desc = $self->{table}->get_command( $SHORT_HELP );
    return $desc->{code}->( $self ) if $desc;
    return $self->synopsis();
}

sub alias_list { return $_[0]->{table}->alias_list(); }

sub _list_aliases
{
    my ( $self ) = @_;
    return unless $self->{table}->has_aliases;

    $self->_print( "\nAliases:\n" );
    foreach my $c ( $self->alias_list() )
    {
        $self->_print( "$CMD_INDENT$c\t: " . $self->{table}->get_alias( $c ) . "\n" );
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

sub _initialize_config
{
    my ( $self, $config_file ) = @_;
    my $conf = Config::Tiny->read( $config_file );
    %{ $self->{config} } = (
        ( $conf->{_} ? %{ delete $conf->{_} } : () ),    # first extract the top level
        %{$conf},                # Keep any multi-levels that are not aliases
        %{ $self->{config} },    # Override with supplied parameters
    );
    return;
}

sub _setup_commands
{
    my( $self, $commands ) = @_;

    return $commands unless $self->{config}->{default_commands};

    foreach my $def ( split / /, $self->{config}->{default_commands} )
    {
        if( $def eq 'shell' )
        {
            $commands->{shell} = {
                code     => \&App::CmdDispatch::shell,
                synopsis => 'shell',
                help     => 'Execute commands as entered until quit.',
            };
        }
        elsif( $def eq 'help' )
        {
            $commands->{$LONG_HELP} = {
                code     => \&App::CmdDispatch::help,
                synopsis => "$LONG_HELP [command|alias]",
                help => "Display help about commands and/or aliases. Limit display with the\nargument.",
            };
            $commands->{$SHORT_HELP} = {
                code     => \&App::CmdDispatch::synopsis,
                synopsis => "$SHORT_HELP [command|alias]",
                help => 'A list of commands and/or aliases. Limit display with the argument.',
            };
        }
        else
        {
            die "Unrecognized default command: '$def'\n";
        }
    }
    return $commands;
}

sub _normalize_help
{
    my ( $self, $table ) = @_;
    foreach my $cmd ( $table->command_list )
    {
        my $desc = $table->get_command( $cmd );
        $desc->{synopsis} = $cmd unless defined $desc->{synopsis};
        $desc->{help}     = ''   unless defined $desc->{help};
    }
    return;
}

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

=head3 The $options hash

This hash determines some of the default behavior of the C<App::CmdDispatch>
object.

=over 4

=item config_file

=item default_commands

=item io

=back

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

=head2 get_config()

Return a reference to the configuration hash for the dispatcher.

=head2 command_list()

Returns the list of commands in a defined order.

=head2 alias_list()

Returnd the list of aliases in sorted order.

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

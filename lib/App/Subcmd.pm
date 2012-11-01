package App::Subcmd;

use warnings;
use strict;
use Config::Tiny;
use Term::ReadLine;

our $VERSION = '0.003_01';

sub new
{
    my ( $class, $commands, $options ) = @_;
    $options ||= {};
    die "Command definition is not a hashref.\n" unless ref $commands eq ref {};
    die "Options parameter is not a hashref.\n"  unless ref $options  eq ref {};

    my %config      = %{$options};
    my $config_file = delete $config{config};

    my $self = bless {
        cmds    => {},
        alias   => {},
        config  => \%config,
        readfh  => \*STDIN,
        writefh => \*STDOUT,
    }, $class;

    $self->_initialize_config( $config_file ) if defined $config_file and -f $config_file;

    # Set defaults with closures that reference this object
    $self->{cmds}->{help}     = {
        code => sub { return $self->help( @_ ); },
        synopsis => 'help [command|alias]',
        help => 'Display help about commands and/or aliases. Limit display with the argument.',
    };
    $self->{cmds}->{synopsis} = {
        code => sub { return $self->synopsis( @_ ); },
        synopsis => 'synopsis [command|alias]',
        help => 'A list of commands and/or aliases. Limit display with the argument.',
    };
    $self->{cmds}->{shell}    = {
        code => sub { return $self->shell( @_ ); },
        synopsis => 'shell',
        help => 'Execute commands as entered until quit.',
    };

    $self->_ensure_valid_command_description( $commands );

    return $self;
}

sub run
{
    my ( $self, $cmd, @args ) = @_;

    if ( !defined $cmd ) {
        $self->_print( "Missing command\n\n" );
        $self->help();
        return;
    }

    # Handle alias if one is supplied
    if ( exists $self->{'alias'}->{$cmd} )
    {
        ( $cmd, @args ) = ( ( split / /, $self->{'alias'}->{$cmd} ), @args );
    }

    # Handle builtin commands
    if ( $self->{cmds}->{$cmd} )
    {
        $self->{cmds}->{$cmd}->{'code'}->( @args );
    }
    else
    {
        $self->_print( "Unrecognized command '$cmd'\n\n" );
        $self->synopsis();
    }
    return;
}

sub _command_list
{
    my ($self) = @_;
    return (sort grep { $_ ne 'help' && $_ ne 'synopsis' } keys %{$self->{cmds}}), qw/synopsis help/;
}

sub _synopsis_string
{
    my ($self, $cmd) = @_;
    return '' if !defined $cmd || !$self->{cmds}->{$cmd};
    return $self->{cmds}->{$cmd}->{synopsis} || $cmd;
}

sub _help_string
{
    my ($self, $cmd) = @_;
    return '' if !defined $cmd || !$self->{cmds}->{$cmd}->{help};
    return "        $self->{cmds}->{$cmd}->{help}";
}

sub synopsis
{
    my ( $self, $arg ) = @_;

    if ( defined $arg && $self->{cmds}->{$arg} )
    {
        $self->_print( "\n", $self->_synopsis_string( $arg ), "\n" );
        return;
    }

    if ( !$arg or $arg eq 'commands' )
    {
        $self->_print( "\nCommands:\n" );
        foreach my $c ( $self->_command_list() )
        {
            $self->_print( $self->_synopsis_string( $c ), "\n" );
        }
    }
    if ( !$arg or $arg eq 'aliases' )
    {
        $self->_list_aliases();
    }

    if ($arg && !exists $self->{cmds}->{$arg})
    {
         $self->_print( "Unrecognized command '$arg'\n" );
    }

    return;
}

sub help
{
    my ( $self, $arg ) = @_;

    if ( defined $arg && $self->{cmds}->{$arg} )
    {
        $self->_print( "\n", $self->_cmd_synopsis(), $self->_synopsis_string( $arg ), "\n", ($self->_help_string( $arg ) || "        Sorry, '$arg' does not currently have any help information"), "\n" );
        return;
    }

    if ( !$arg or $arg eq 'commands' )
    {
        $self->_print( "\nCommands:\n" );
        foreach my $c ( $self->_command_list() )
        {
            $self->_print( $self->_synopsis_string( $c ), "\n   ", $self->_help_string( $c ), "\n" );
        }
    }
    if ( !$arg or $arg eq 'aliases' )
    {
        $self->_list_aliases();
    }

    if ($arg && !exists $self->{cmds}->{$arg}) 
    {
         $self->_print( "Unrecognized command '$arg'\n" );
    }

    return;
}

sub _list_aliases
{
    my ( $self ) = @_;
    return unless keys %{ $self->{'alias'} };

    $self->_print( "\nAliases:\n" );
    foreach my $c ( sort keys %{ $self->{'alias'} } )
    {
        $self->_print( "$c\t: $self->{'alias'}->{$c}\n" );
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
        last if $line eq 'quit';
        $self->run( split /\s+/, $line );
    }
    return;
}

sub _ensure_valid_command_description
{
    my ( $self, $cmds ) = @_;

    while ( my ( $key, $val ) = each %{$cmds} )
    {
        die "Command '$key' is an invalid descriptor.\n" unless ref $val eq ref {};
        $self->{cmds}->{$key} = { %{$val} };
    }

    return;
}

sub _initialize_config
{
    my ( $self, $config_file ) = @_;
    my $conf = Config::Tiny->read( $config_file );
    %{$self->{alias}} = %{delete $conf->{alias}};
    %{$self->{config}} = (
        ($conf->{_} ? %{delete $conf->{_}} : ()),   # first extract the top level
        %{$conf},                                   # Keep any multi-levels that are not aliases
        %{$self->{config}},                         # Override with supplied parameters
    );
    return;
}

sub _print
{
    my $self = shift;
    print { $self->{writefh} } @_;
    return;
}

sub _prompt
{
    my $self = shift;
    print { $self->{writefh} } @_;
    return readline( $self->{readfh} );
}

1;

__END__

=encoding utf-8

=head1 NAME

App::Subcmd - Handle command line processing for programs with subcommands

=head1 VERSION

This document describes App::Subcmd version 0.003_01

=head1 SYNOPSIS

    use App::Subcmd;

    my %cmds = (
        start => {
            code => sub { print "start: @_\n"; },
            synopsis => 'start [what]',
            help => 'Start whatever is to be run.',
        },
        stop => {
            code => sub { print "stop @_\n"; },
            synopsis => 'stop [what]',
            help => 'Stop whatever is to be run.',
        },
        stuff => {
            code => sub { print "stuff: @_\n"; },
            synopsis => 'stuff [what]',
            help => 'Stuff to do.',
        },
        jump => {
            code => sub { print "jump: @_\n"; },
            synopsis => 'jump [what]',
            help => 'Start whatever is to be run.',
        },
    );

    my $processor = App::Subcmd->new( \%cmds );
    $processor->run( @ARGV );

=head1 DESCRIPTION

This class handles command processing for a script based on a command
description consisting of a hash containing the name of each command
mapped to a hash giving code and help information.

=head1 INTERFACE 

=head2 new

=head2 run

=head2 synopsis

=head2 help

=head2 shell 

=head1 CONFIGURATION AND ENVIRONMENT

App::Subcmd can read a configuration file specified in a Config::Tiny supported
format. Should be specified in the config parameter.

=head1 DEPENDENCIES

Config::Tiny
Term::Readline

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-app-subcmd@rt.cpan.org>, or through the web interface at
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

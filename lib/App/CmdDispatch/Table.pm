package App::CmdDispatch::Table;

use warnings;
use strict;

our $VERSION = '0.004_02';

sub MissingCommand { return "Missing command\n"; }
sub UnknownCommand { return "Unrecognized command\n"; }

sub new
{
    my ( $class, $commands, $aliases ) = @_;
    $aliases ||= {};
    die "Command definition is not a hashref.\n" unless ref $commands eq ref {};
    die "No commands specified.\n"               unless keys %{$commands};
    die "Aliases definition is not a hashref.\n" unless ref $aliases eq ref {};

    my $self = bless {
        cmds    => {},
        alias   => {},
    }, $class;

    $self->_ensure_valid_command_description( $commands );
    $self->_ensure_valid_aliases( $aliases );

    return $self;
}

sub run
{
    my ( $self, $base, $cmd, @args ) = @_;

    die MissingCommand if !defined $cmd || $cmd eq '';

    # Handle alias if one is supplied
    if( exists $self->{alias}->{$cmd} )
    {
        ( $cmd, @args ) = ( ( split / /, $self->{alias}->{$cmd} ), @args );
    }

    # Handle builtin commands
    die UnknownCommand unless $self->{cmds}->{$cmd};
    $self->{cmds}->{$cmd}->{'code'}->( $base, @args );

    return;
}

sub _ensure_valid_command_description
{
    my ( $self, $cmds ) = @_;
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
        $self->{cmds}->{$key} = $desc;
    }

    return;
}

sub _ensure_valid_aliases
{
    my ( $self, $aliases ) = @_;
    while ( my ( $key, $val ) = each %{$aliases} )
    {
        next if $key eq '';
        if( !defined $val )
        {
            delete $self->{alias}->{$key};
            next;
        }
        die "Alias '$key' mapping is not a string.\n" if ref $val;
        $self->{alias}->{$key} = $val;
    }

    return;
}

sub command_list
{
    my ($self) = @_;
    return sort keys %{$self->{cmds}};  ## no critic - intended to return list
}

sub alias_list
{
    my ($self) = @_;
    return sort keys %{$self->{alias}};  ## no critic - intended to return list
}

sub get_command
{
    my ($self, $cmd) = @_;
    return $self->{cmds}->{$cmd};
}

sub get_alias
{
    my ($self, $alias) = @_;
    return $self->{alias}->{$alias};
}

sub has_aliases
{
    my ($self) = @_;
    return 0 != keys %{ $self->{alias} };
}

1;
__END__

=encoding utf-8

=head1 NAME

App::CmdDispatch::Table - Dispatch table with support for aliases.

=head1 VERSION

This document describes App::CmdDispatch::Table version 0.004_02

=head1 SYNOPSIS

    use App::CmdDispatch::Table;
  
=head1 DESCRIPTION

This module handles the core functionality of the dispatch table system. This
includes the dispatch table itself and the run() method that dispatches
requested commands. In addition, this module handles aliasing functionality.

=head1 INTERFACE 

=head2 new( $command_hash, $alias_hash )

Create a new C<App::CmdDispatch::Table> object. This method can take one or two
hashrefs as arguments. The first is required and describes the commands. The
second is optional and provides a mapping of aliases to the command string that
the alias maps to.

=head2 run( $cmd, @args )

Given a command string (or possibly an alias) and a set of arguments, execute
the associated code.

=head2 command_list()

Return the list of commands in sorted order. This is basically the keys of the
dispatch table.

=head2 get_command( $cmd )

Return the hash that represents the the supplied command.

=head2 alias_list()

Return a sorted list of the aliases in this table.

=head2 get_alias( $alias )

Return the string that the supplied alias maps to.

=head2 has_aliases()

Returns a true value if the table has any aliases, otherwise it returns a false
value.

=head2 MissingCommand()

This class method returns the string that is thrown if run() is called with no
command.

=head2 UnknownCommand()

This class method returns the string that is thrown if run() is called with a
command or alias that is not known.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

G. Wade Johnson  C<< wade@anomaly.org >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, G. Wade Johnson C<< wade@anomaly.org >>. All rights reserved.

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

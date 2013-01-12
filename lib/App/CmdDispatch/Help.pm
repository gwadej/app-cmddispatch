package App::CmdDispatch::Help;

use warnings;
use strict;

our $VERSION = '0.004_03';

my $CMD_INDENT  = '  ';
my $HELP_INDENT = '        ';

sub new
{
    my ($class, $owner, $commands, $config) = @_;
    _extend_table_with_help( $commands );
    return bless { owner => $owner }, $class;
}

sub _extend_table_with_help
{
    my ( $commands ) = @_;
    $commands->{help} = {
        code     => \&App::CmdDispatch::Help::help,
        synopsis => "help [command|alias]",
        help => "Display help about commands and/or aliases. Limit display with the\nargument.",
    };
    $commands->{hint} = {
        code     => \&App::CmdDispatch::Help::hint,
        synopsis => "hint [command|alias]",
        help => 'A list of commands and/or aliases. Limit display with the argument.',
    };
    return;
}

sub _hint_string
{
    my ( $self, $cmd ) = @_;
    my $desc = $self->_table->get_command( $cmd );
    return $desc ? $desc->{synopsis} : $desc;
}

sub _help_string
{
    my ( $self, $cmd ) = @_;
    my $desc = $self->_table->get_command( $cmd );
    return '' unless defined $desc;
    return join( "\n", map { $HELP_INDENT . $_ } split /\n/, $desc->{help} );
}

sub _list_command
{
    my ( $self, $code ) = @_;
    $self->_print( "\nCommands:\n" );
    foreach my $c ( $self->{owner}->command_list() )
    {
        next if $c eq '' or !$self->_table->get_command( $c );
        $self->_print( $code->( $c ) );
    }
    return;
}

sub _list_aliases
{
    my ( $self ) = @_;
    return unless $self->_table->has_aliases;

    $self->_print( "\nAliases:\n" );
    foreach my $c ( $self->{owner}->alias_list() )
    {
        $self->_print( "$CMD_INDENT$c\t: " . $self->_table->get_alias( $c ) . "\n" );
    }
    return;
}

sub _is_missing { return !defined $_[0] || $_[0] eq ''; }

sub hint
{
    my ( $self, $arg ) = @_;
    if( ref $self ne __PACKAGE__ )
    {
        $self = $self->{_helper};
    }

    if( _is_missing( $arg ) )
    {
        $self->_list_command( sub { $CMD_INDENT, $self->_hint_string( $_[0] ), "\n"; } );
        $self->_list_aliases();
        return;
    }

    if( $self->_table->get_command( $arg ) )
    {
        $self->_print( "\n", $self->_hint_string( $arg ), "\n" );
    }
    elsif( $self->_table->get_alias( $arg ) )
    {
        $self->_print( "\n$arg\t: ", $self->_table->get_alias( $arg ), "\n" );
    }
    elsif( $arg eq 'commands' )
    {
        $self->_list_command( sub { $CMD_INDENT, $self->_hint_string( $_[0] ), "\n"; } );
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
    if( ref $self ne __PACKAGE__ )
    {
        $self = $self->{_helper};
    }

    if( _is_missing( $arg ) )
    {
        $self->_list_command(
            sub {
                $CMD_INDENT, $self->_hint_string( $_[0] ), "\n", $self->_help_string( $_[0] ), "\n";
            }
        );
        $self->_list_aliases();
        return;
    }

    if( $self->_table->get_command( $arg ) )
    {
        $self->_print(
            "\n",
            $self->_hint_string( $arg ),
            "\n",
            (
                $self->_help_string( $arg )
                    || $HELP_INDENT . "No hint for '$arg'"
            ),
            "\n"
        );
    }
    elsif( $self->_table->get_alias( $arg ) )
    {
        $self->_print(
            "\n$arg\t: ",
            $self->_table->get_alias( $arg ),
            "\n",
        );
    }
    elsif( $arg eq 'commands' )
    {
        $self->_list_command(
            sub {
                $CMD_INDENT, $self->_hint_string( $_[0] ), "\n", $self->_help_string( $_[0] ), "\n";
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

sub _do_hint
{
    my ($self) = @_;
    my $desc = $self->_table->get_command( 'hint' );
    return $desc->{code}->( $self ) if $desc;
    return $self->hint();
}

sub normalize_command_help
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

sub _print
{
    my ($self) = shift;
    return $self->{owner}->_print( @_ );
}

sub _table { return $_[0]->{owner}->{table}; }

1;
__END__

=encoding utf-8

=head1 NAME

App::CmdDispatch::Help - Provide help functionality for the CmdDispatch module

=head1 VERSION

This document describes App::CmdDispatch::Help version 0.004_03.3


=head1 SYNOPSIS

    use App::CmdDispatch::Help;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 new()

=head2 normalize_command_help( $table )

=head2 hint( $dispatch, $cmd )

Print a short hint listing all commands and aliases or just the hint
for the supplied command.

=head2 help( $dispatch, $cmd )

Print help for the program or just help on the supplied command.

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
App::CmdDispatch::Help requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

=head1 AUTHOR

G. Wade Johnson  C<< wade@anomaly.org >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) <YEAR>, G. Wade Johnson C<< wade@anomaly.org >>. All rights reserved.

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


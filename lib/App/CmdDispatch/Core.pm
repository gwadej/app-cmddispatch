package App::CmdDispatch::Core;

use warnings;
use strict;
use Config::Tiny;
use Term::ReadLine;

our $VERSION = '0.004_01';

sub MissingCommand { return "Missing command\n"; }
sub UnknownCommand { return "Unrecognized command\n"; }

sub new
{
    my ( $class, $commands, $options ) = @_;
    $options ||= {};
    die "Command definition is not a hashref.\n" unless ref $commands eq ref {};
    die "No commands specified.\n"               unless keys %{$commands};
    die "Options parameter is not a hashref.\n"  unless ref $options  eq ref {};

    my %config      = %{$options};
    my $config_file = delete $config{config};

    my $self = bless {
        cmds    => {},
        alias   => {},
        config  => \%config,
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

sub get_command_desc
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

=head1 NAME

App::CmdDispatch::Core - Dispatch table with support for aliases and config file.

=head1 VERSION

This document describes App::CmdDispatch::Core version 0.004_01

=head1 SYNOPSIS

    use App::CmdDispatch::Core;
  
=head1 DESCRIPTION

This module handles the core functionality of the dispatch table system. This
includes the dispatch table itself and the run() method that dispatches
requested commands. In addition, this module handles aliasing functionality.

=head1 INTERFACE 

=head2 new( $cmdhash, $options_hash )

Create a new C<App::CmdDispatch::Core> object. This method can take one or two
hashrefs as arguments. The first is required and describes the commands. The
second is optional and provides option information for the
C<App::CmdDispatch::Core> object.

=head2 run( $cmd, @args )

=head2 command_list()

=head2 get_command_desc( $cmd )

=head2 alias_list()

=head2 get_alias( $alias )

=head2 has_aliases()

=head2 get_config()

=head2 MissingCommand()

=head2 UnknownCommand()

=head1 CONFIGURATION AND ENVIRONMENT

App::CmdDispatch::Core can read a configuration file specified in a Config::Tiny supported
format. Should be specified in the config parameter.

=head1 DEPENDENCIES

Config::Tiny
Term::Readline

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

G. Wade Johnson  C<< wade@anomaly.org >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, G. Wade Johnson C<< wade@anomaly.org >>. All rights reserved.

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
package ModName;

use warnings;
use strict;
use Carp;

our $VERSION = '0.0.3';

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;


# Module implementation here


1;
__END__

=head1 NAME

ModName - [One line description of module's purpose here]


=head1 VERSION

This document describes ModName version 0.0.3


=head1 SYNOPSIS

    use ModName;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


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
  
ModName requires no configuration files or environment variables.


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


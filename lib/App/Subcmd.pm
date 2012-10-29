package App::Subcmd;

use warnings;
use strict;
use Carp;

our $VERSION = 0.003;

sub new {
    my ($class, $commands, $options) = @_;
    $options ||= {};
    die "Command definition is not a hashref.\n" unless ref $commands eq ref {};
    die "Options parameter is not a hashref.\n" unless ref $options eq ref {};

    return bless {}, $class;
}

sub run {
}

sub synopsis {
}

sub help {
}

sub shell {
}

1;
__END__

=head1 NAME

App::Subcmd - Handle command line processing for programs with subcommands

=head1 VERSION

This document describes App::Subcmd version 0.003

=head1 SYNOPSIS

    use App::Subcmd;

    my %commands = (
        'start'   => {
            code => \&log_event,
            synopsis => 'start {event description}',
            help => 'Stop last event and start timing a new event.',
        },
        'stop'    => {
            code => sub { log_event( 'stop' ); },
            synopsis => 'stop',
            help => 'Stop timing last event.',
        },
        'push'    => {
            code => \&push_event,
            synopsis => 'push {event description}',
            help => 'Save last event on stack and start timing new event.',
        },
        'pop'     => {
            code => \&pop_event,
            synopsis => 'pop',
            help => 'Stop last event and restart top event on stack.',
        },
        'drop'    => {
            code => \&drop_event,
            synopsis => 'drop [all|{n}]',
            help => 'Drop one or more items from top of event stack or all if argument supplied.',
        },
        'nip'    => {
            code => \&nip_event,
            synopsis => 'nip',
            help => 'Drop one item from under the top of event stack.',
        },
        'ls'      => {
            code => \&list_events,
            synopsis => 'ls [date]',
            help => 'List events for the specified day. Default to today.',
        },
        'lsproj'  => {
            code => \&list_projects,
            synopsis => 'lsproj',
            help => 'List known projects.',
        },
        'lstk'    => {
            code => \&list_stack,
            synopsis => 'lstk',
            help => 'Display items on the stack.',
        },
        'edit'    => {
            code => sub { system $config{'editor'}, $config{'logfile'}; },
            synopsis => 'edit',
            help => 'Open the timelog file in the current editor',
        },
        'help'    => {
            code => \&usage,
            synopsis => 'help [commands|aliases]',
            help => 'A list of commands and/or aliases. Limit display with the argument.',
        },
        'report'  => {
            code => \&daily_report,
            synopsis => 'report [date [end date]]',
            help => 'Display a report for the specified days.',
        },
        'summary' => {
            code => \&daily_summary,
            synopsis => 'summary [date [end date]]',
            help => q{Display a summary of the appropriate days' projects.},
        },
        'hours' => {
            code => \&report_hours,
            synopsis => 'hours [date [end date]]',
            help => q{Display the hours worked for each of the appropriate days.},
        },
    );

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 new

=head2 run

=head2 synopsis

=head2 help

=head2 shell 

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
  
App::Subcmd requires no configuration files or environment variables.


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

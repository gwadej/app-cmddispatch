#!/usr/bin/env perl

use Test::More 'no_plan'; #tests => 1;

use strict;
use warnings;

use App::Subcmd;

{
    my $label = 'Single command, handler only';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );
    isa_ok( $app, 'App::Subcmd' );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help man/], "$label: noop help and man found";

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->help;
    is $output, <<EOF, "$label: Default help supplied";

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->man;
    is $output, <<EOF, "$label: Default man supplied";

Commands:
  noop

  shell
        Execute commands as entered until quit.
  help [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, handler and synopsis';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]' },
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help man/], "$label: noop help and man found";

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->help;
    is $output, <<EOF, "$label: Help as supplied";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->man;
    is $output, <<EOF, "$label: Default man supplied";

Commands:
  noop [n]

  shell
        Execute commands as entered until quit.
  help [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, all supplied';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help man/], "$label: noop help and man found";

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->help;
    is $output, <<EOF, "$label: Help as supplied";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->man;
    is $output, <<EOF, "$label: Default man supplied";

Commands:
  noop [n]
        Does nothing, n times.
  shell
        Execute commands as entered until quit.
  help [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}


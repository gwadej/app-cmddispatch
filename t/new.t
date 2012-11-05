#!/usr/bin/env perl

use Test::More tests => 19;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Subcmd 'output_is';

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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Default help supplied" );

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->man }, <<EOF, "$label: Default man supplied" );

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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->man; }, <<EOF, "$label: Default man supplied" );

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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->man; }, <<EOF, "$label: Default man supplied" );

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

{
    my $label = 'Single command, remove shell';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            shell => undef,
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop help man/], "$label: shell has been removed";

    output_is( $app, sub { $app->help; }, <<EOF, "$label: shell removed from help" );

Commands:
  noop
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->man; }, <<EOF, "$label: Default man supplied" );

Commands:
  noop

  help [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, remove help';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            help => undef,
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell man/], "$label: help has been removed";
}

{
    my $label = 'Single command, remove man';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            man => undef,
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help/], "$label: man has been removed";
}

{
    my $label = 'Replace help';
    my $called = 0;
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            help => { code => sub { ++$called; }, synopsis => 'help', help => 'Replaced help' },
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help man/], "$label: man has been removed";

    is( $called, 0, "$label: No calls made" );
    $app->run( 'help' );
    is( $called, 1, "$label: Replacement code is called" );

    output_is( $app, sub { $app->man; }, <<EOF, "$label: help strings replaced" );

Commands:
  noop

  shell
        Execute commands as entered until quit.
  help
        Replaced help
  man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

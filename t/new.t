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
    is_deeply [ $app->_command_list() ], [qw/noop shell synopsis help/], "$label: noop help and man found";

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Default help supplied" );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->help }, <<EOF, "$label: Default help supplied" );

Commands:
  noop

  shell
        Execute commands as entered until quit.
  synopsis [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
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
    is_deeply [ $app->_command_list() ], [qw/noop shell synopsis help/], "$label: noop help and synopsis found";

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Synopsis as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->help; }, <<EOF, "$label: Default help supplied" );

Commands:
  noop [n]

  shell
        Execute commands as entered until quit.
  synopsis [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
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
    is_deeply [ $app->_command_list() ], [qw/noop shell synopsis help/], "$label: noop help and synopsis found";

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->help; }, <<EOF, "$label: Default help supplied" );

Commands:
  noop [n]
        Does nothing, n times.
  shell
        Execute commands as entered until quit.
  synopsis [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
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
    is_deeply [ $app->_command_list() ], [qw/noop synopsis help/], "$label: shell has been removed";

    output_is( $app, sub { $app->synopsis; }, <<EOF, "$label: shell removed from help" );

Commands:
  noop
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->help; }, <<EOF, "$label: Default help supplied" );

Commands:
  noop

  synopsis [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, remove synopsis';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            synopsis => undef,
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell help/], "$label: synopsis has been removed";
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
    is_deeply [ $app->_command_list() ], [qw/noop shell synopsis/], "$label: help has been removed";
}

{
    my $label = 'Replace synopsis';
    my $called = 0;
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
            synopsis => { code => sub { ++$called; }, synopsis => 'synopsis', help => 'Replaced synopsis' },
        }
    );

    # Using private method for testing.
    is_deeply [ $app->_command_list() ], [qw/noop shell synopsis help/], "$label: synopsis still there";

    is( $called, 0, "$label: No calls made" );
    $app->run( 'synopsis' );
    is( $called, 1, "$label: Replacement code is called" );

    output_is( $app, sub { $app->help; }, <<EOF, "$label: synopsis strings replaced" );

Commands:
  noop

  shell
        Execute commands as entered until quit.
  synopsis
        Replaced synopsis
  help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

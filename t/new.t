#!/usr/bin/env perl

use Test::More tests => 22;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::IO;

use App::CmdDispatch;

{
    my $label = 'Single command, handler only';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io }
    );
    isa_ok( $app, 'App::CmdDispatch' );

    is_deeply [ $app->command_list() ], [qw/noop/], "$label: noop found";

    $app->hint;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop
EOF

    $io->clear;
    $app->help;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop

EOF
}

{
    my $label = 'Single command, handler only';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io, default_commands => 'shell help' }
    );
    isa_ok( $app, 'App::CmdDispatch' );

    is_deeply [ $app->command_list() ], [qw/noop shell hint help/], "$label: noop help and hint found";

    $app->hint;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop
  shell
  hint [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->help;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop

  shell
        Execute commands as entered until quit.
  hint [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, handler and hint';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]' },
        },
        { io => $io }
    );

    is_deeply [ $app->command_list() ], [qw/noop/], "$label: noop found";

    $app->hint;
    is( $io->output, <<EOF, "$label: Synopsis as supplied" );

Commands:
  noop [n]
EOF

    $io->clear;
    $app->help;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop [n]

EOF
}

{
    my $label = 'Single command, all supplied';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        },
        { io => $io }
    );

    is_deeply [ $app->command_list() ], [qw/noop/], "$label: noop found";

    $app->hint;
    is( $io->output, <<EOF, "$label: hint as supplied" );

Commands:
  noop [n]
EOF

    $io->clear;
    $app->help;
    is( $io->output, <<EOF, "$label: help supplied" );

Commands:
  noop [n]
        Does nothing, n times.
EOF
}

{
    my $label = 'Single command, add help default';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io, default_commands => 'help' }
    );

    is_deeply [ $app->command_list() ], [qw/noop hint help/], "$label: help commands added";

    $app->hint;
    is( $io->output, <<EOF, "$label: Only help defaults added" );

Commands:
  noop
  hint [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->help;
    is( $io->output, <<EOF, "$label: Default help supplied" );

Commands:
  noop

  hint [command|alias]
        A list of commands and/or aliases. Limit display with the argument.
  help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

{
    my $label = 'Single command, add shell default';
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { default_commands => 'shell' }
    );

    # Using private method for testing.
    is_deeply [ $app->command_list() ], [qw/noop shell/], "$label: only shell added";
}

{
    my $label = 'Replace hint';
    my $called = 0;
    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
            hint => { code => sub { ++$called; }, synopsis => 'hint', help => 'Replaced hint' },
        },
        { io => $io }
    );

    is_deeply [ $app->command_list() ], [qw/noop hint/], "$label: hint still there";

    is( $called, 0, "$label: No calls made" );
    $app->run( 'hint' );
    is( $called, 1, "$label: Replacement code is called" );

    $app->help;
    is( $io->output, <<EOF, "$label: hint strings replaced" );

Commands:
  noop

  hint
        Replaced hint
EOF
}

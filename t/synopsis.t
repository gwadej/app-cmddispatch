#!/usr/bin/env perl

use Test::More tests => 19;

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
        { io => $io, default_commands => 'shell help' }
    );

    $app->synopsis;
    is( $io->output, <<EOF, "$label: Default synopsis supplied" );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $label = 'Single command, handler and synopsis';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]' },
        },
        { io => $io, default_commands => 'shell help' }
    );

    $app->synopsis;
    is( $io->output, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $label = 'Single command, all supplied';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        },
        { io => $io, default_commands => 'shell help' }
    );

    $app->synopsis;
    is( $io->output, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->synopsis( undef );
    is( $io->output, <<EOF, "$label: undef supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->synopsis( '' );
    is( $io->output, <<EOF, "$label: empty string supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->synopsis( 0 );
    is( $io->output, "Unrecognized command '0'\n", "$label: zero supplied to synopsis" );

    $io->clear;
    $app->synopsis( 'noop' );
    is( $io->output, <<EOF, "$label: command supplied to synopsis" );

noop [n]
EOF

    $io->clear;
    $app->synopsis( 'synopsis' );
    is( $io->output, <<EOF, "$label: synopsis supplied to synopsis" );

synopsis [command|alias]
EOF

    $io->clear;
    $app->synopsis( 'commands' );
    is( $io->output, <<EOF, "$label: 'commands' supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->synopsis( 'aliases' );
    is( $io->output, '', "$label: 'aliases' supplied to synopsis, with no aliases" );
}

{
    my $label = 'Single command, all supplied, aliases';
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        },
        { io => $io, default_commands => 'shell help', alias => { help2 => 'help help' } }
    );

    $app->synopsis;
    is( $io->output, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]

Aliases:
  help2\t: help help
EOF

    $io->clear;
    $app->synopsis( undef );
    is( $io->output, <<EOF, "$label: undef supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]

Aliases:
  help2\t: help help
EOF

    $io->clear;
    $app->synopsis( '' );
    is( $io->output, <<EOF, "$label: empty string supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]

Aliases:
  help2\t: help help
EOF

    $io->clear;
    $app->synopsis( 0 );
    is( $io->output, "Unrecognized command '0'\n", "$label: zero supplied to synopsis" );

    $io->clear;
    $app->synopsis( 'noop' );
    is( $io->output, <<EOF, "$label: command supplied to synopsis" );

noop [n]
EOF

    $io->clear;
    $app->synopsis( 'synopsis' );
    is( $io->output, <<EOF, "$label: synopsis supplied to synopsis" );

synopsis [command|alias]
EOF

    $io->clear;
    $app->synopsis( 'commands' );
    is( $io->output, <<EOF, "$label: 'commands' supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->synopsis( 'aliases' );
    is( $io->output, <<EOF, "$label: ask for alias list" );

Aliases:
  help2\t: help help
EOF

    $io->clear;
    $app->synopsis( 'help2' );
    is( $io->output, <<EOF, "$label: alias supplied to synopsis" );

help2\t: help help
EOF
}

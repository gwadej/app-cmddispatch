#!/usr/bin/env perl

use Test::More tests => 4;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::IO;

use App::CmdDispatch;

{
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io }
    );

    $app->run();
    is( $io->output, <<EOF, "Running with no command gives error.\n" );
Missing command

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io }
    );

    $app->run( '' );
    is( $io->output, <<EOF, "Running with empty command gives error.\n" );
Missing command

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io }
    );

    $app->run( 'synopsis' );
    is( $io->output, <<EOF, "Synopsis command run successfully" );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $io = Test::IO->new();
    my $app = App::CmdDispatch->new(
        {
            noop => { code => sub {} },
        },
        { io => $io }
    );

    $app->run( 'foo' );
    is( $io->output, <<EOF, "Unrecognized command gives error" );
Unrecognized command 'foo'

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}


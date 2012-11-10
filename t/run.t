#!/usr/bin/env perl

use Test::More 'no_plan'; #tests => 1;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Subcmd 'output_is';

use App::Subcmd;

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    output_is( $app, sub { $app->run(); }, <<EOF, "Running with no command gives error.\n" );
Missing command

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    output_is( $app, sub { $app->run( '' ); }, <<EOF, "Running with empty command gives error.\n" );
Missing command

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    output_is( $app, sub { $app->run( 'synopsis' ); }, <<EOF, "Synopsis command run successfully" );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    output_is( $app, sub { $app->run( 'foo' ); }, <<EOF, "Unrecognized command gives error" );
Unrecognized command 'foo'

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}


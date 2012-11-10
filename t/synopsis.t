#!/usr/bin/env perl

use Test::More tests => 10;

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

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Default synopsis supplied" );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $label = 'Single command, handler and synopsis';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]' },
        }
    );

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF
}

{
    my $label = 'Single command, all supplied';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        }
    );

    output_is( $app, sub { $app->synopsis }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->synopsis( undef ) }, <<EOF, "$label: undef supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->synopsis( '' ) }, <<EOF, "$label: empty string supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->synopsis( 0 ) }, "Unrecognized command '0'\n", "$label: zero supplied to synopsis" );

    output_is( $app, sub { $app->synopsis( 'noop' ) }, <<EOF, "$label: command supplied to synopsis" );

noop [n]
EOF

    output_is( $app, sub { $app->synopsis( 'synopsis' ) }, <<EOF, "$label: synopsis supplied to synopsis" );

synopsis [command|alias]
EOF

    output_is( $app, sub { $app->synopsis( 'commands' ) }, <<EOF, "$label: 'commands' supplied to synopsis" );

Commands:
  noop [n]
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->synopsis( 'aliases' ) }, undef, "$label: 'aliases' supplied to synopsis, with no aliases" );
}

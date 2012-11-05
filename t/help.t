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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Default help supplied" );

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF
}

{
    my $label = 'Single command, handler and synopsis';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]' },
        }
    );

    output_is( $app, sub { $app->help }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF
}

{
    my $label = 'Single command, all supplied';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {}, synopsis => 'noop [n]', help => 'Does nothing, n times.' },
        }
    );

    output_is( $app, sub { $app->help }, <<EOF, "$label: Help as supplied" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->help( undef ) }, <<EOF, "$label: undef supplied to help" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->help( '' ) }, <<EOF, "$label: empty string supplied to help" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->help( 0 ) }, "Unrecognized command '0'\n", "$label: zero supplied to help" );

    output_is( $app, sub { $app->help( 'noop' ) }, <<EOF, "$label: command supplied to help" );

noop [n]
EOF

    output_is( $app, sub { $app->help( 'help' ) }, <<EOF, "$label: help supplied to help" );

help [command|alias]
EOF

    output_is( $app, sub { $app->help( 'commands' ) }, <<EOF, "$label: 'commands' supplied to help" );

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    output_is( $app, sub { $app->help( 'aliases' ) }, undef, "$label: 'aliases' supplied to help, with no aliases" );
}

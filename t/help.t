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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Help as supplied" );

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

    output_is( $app, sub { $app->help }, <<EOF, "$label: Default man supplied" );

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

    output_is( $app, sub { $app->help( undef ); }, <<EOF, "$label: undef supplied to synopsis" );

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

    output_is( $app, sub { $app->help( '' ) }, <<EOF, "$label: empty string supplied to synopsis" );

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

    output_is( $app, sub { $app->help( 0 ); }, "Unrecognized command '0'\n", "$label: zero supplied to synopsis" );

    output_is( $app, sub { $app->help( 'noop' ); }, <<EOF, "$label: command supplied to synopsis" );

noop [n]
        Does nothing, n times.
EOF

    output_is( $app, sub { $app->help( 'help' ); }, <<EOF, "$label: help supplied to help" );

help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF

    output_is( $app, sub { $app->help( 'commands' ); }, <<EOF, "$label: 'commands' supplied to help" );

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

    output_is( $app, sub { $app->help( 'aliases' ); }, undef, "$label: 'aliases' supplied to help, with no aliases" );
}


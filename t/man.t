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

    output_is( $app, sub { $app->man }, <<EOF, "$label: Help as supplied" );

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

    output_is( $app, sub { $app->man }, <<EOF, "$label: Default man supplied" );

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

    output_is( $app, sub { $app->man( undef ); }, <<EOF, "$label: undef supplied to help" );

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

    output_is( $app, sub { $app->man( '' ) }, <<EOF, "$label: empty string supplied to help" );

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

    output_is( $app, sub { $app->help( 0 ); }, "Unrecognized command '0'\n", "$label: zero supplied to help" );

    output_is( $app, sub { $app->help( 'noop' ); }, <<EOF, "$label: command supplied to help" );

noop [n]
EOF

    output_is( $app, sub { $app->man( 'man' ); }, <<EOF, "$label: man supplied to man" );

man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF

    output_is( $app, sub { $app->man( 'commands' ); }, <<EOF, "$label: 'commands' supplied to man" );

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

    output_is( $app, sub { $app->man( 'aliases' ); }, undef, "$label: 'aliases' supplied to man, with no aliases" );
}


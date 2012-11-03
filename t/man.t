#!/usr/bin/env perl

use Test::More tests => 10;

use strict;
use warnings;

use App::Subcmd;

{
    my $label = 'Single command, handler only';
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->man;
    is $output, <<EOF, "$label: Default man supplied";

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

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->man;
    is $output, <<EOF, "$label: Help as supplied";

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

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->man;
    is $output, <<EOF, "$label: Default man supplied";

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

    $output = '';
    $app->man( undef );
    is $output, <<EOF, "$label: undef supplied to help";

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

    $output = '';
    $app->man( '' );
    is $output, <<EOF, "$label: empty string supplied to help";

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

    $output = '';
    $app->help( 0 );
    is $output, "Unrecognized command '0'\n", "$label: zero supplied to help";

    $output = '';
    $app->help( 'noop' );
    is $output, <<EOF, "$label: command supplied to help";

noop [n]
EOF

    $output = '';
    $app->man( 'man' );
    is $output, <<EOF, "$label: man supplied to man";

man [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF

    $output = '';
    $app->man( 'commands' );
    is $output, <<EOF, "$label: 'commands' supplied to man";

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

    $output = '';
    $app->man( 'aliases' );
    is $output, '', "$label: 'aliases' supplied to man, with no aliases";
}


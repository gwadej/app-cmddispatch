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
    $app->help;
    is $output, <<EOF, "$label: Default help supplied";

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

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->help;
    is $output, <<EOF, "$label: Help as supplied";

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

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->help;
    is $output, <<EOF, "$label: Help as supplied";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->help( undef );
    is $output, <<EOF, "$label: undef supplied to help";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->help( '' );
    is $output, <<EOF, "$label: empty string supplied to help";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
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
    $app->help( 'help' );
    is $output, <<EOF, "$label: help supplied to help";

help [command|alias]
EOF

    $output = '';
    $app->help( 'commands' );
    is $output, <<EOF, "$label: 'commands' supplied to help";

Commands:
  noop [n]
  shell
  help [command|alias]
  man [command|alias]
EOF

    $output = '';
    $app->help( 'aliases' );
    is $output, '', "$label: 'aliases' supplied to help, with no aliases";
}

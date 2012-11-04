#!/usr/bin/env perl

use Test::More 'no_plan'; #tests => 1;

use strict;
use warnings;

use App::Subcmd;

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );
    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->run();
    is $output, <<EOF, "Running with no command gives error.\n";
Missing command

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );
    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->run( '' );
    is $output, <<EOF, "Running with empty command gives error.\n";
Missing command

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->run( 'help' );
    is $output, <<EOF, "Help command run successfully";

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF
}

{
    my $app = App::Subcmd->new(
        {
            noop => { code => sub {} },
        }
    );

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $app->run( 'foo' );
    is $output, <<EOF, "Unrecognized command gives error";
Unrecognized command 'foo'

Commands:
  noop
  shell
  help [command|alias]
  man [command|alias]
EOF
}


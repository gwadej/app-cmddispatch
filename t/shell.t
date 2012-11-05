#!/usr/bin/env perl

use Test::More tests => 3;

use strict;
use warnings;

use App::Subcmd;

sub shell_is ($$$)
{
    my ($input, $expected, $label) = @_;
    my $app = App::Subcmd->new( { noop => { code=> sub {} } } );

    my $actual;
    open my $ofh, '>>', \$actual or die "Unable to open fh to buffer.\n";
    $input .= "\nquit\n" unless $input =~ /\bquit\b/;
    open my $ifh, '<', \$input or die "Unable to open fh to input.\n";
    $app->set_in_out( $ifh, $ofh );
    $app->shell;
    return is( $actual, $expected, $label );
}

shell_is( "quit\n", "Enter a command or 'quit' to exit:\n> ", 'Immediately exit shell' );

shell_is( "\nquit\n", "Enter a command or 'quit' to exit:\n> > ", 'Handle blank lines' );

shell_is( "help\nquit\n", "Enter a command or 'quit' to exit:\n> \nCommands:\n  noop\n  shell\n  help [command|alias]\n  man [command|alias]\n> ", 'Shell to help' );

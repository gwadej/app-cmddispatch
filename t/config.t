#!/usr/bin/env perl

use Test::More tests => 4;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Subcmd 'output_is';

use File::Temp;
use App::Subcmd;

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $app = App::Subcmd->new( { noop => { code => sub {} } }, { config => $ft->filename } );
    my $actual = $app->get_config;
    is_deeply( $actual, { parm1 => 1771, parm2 => 7171 }, 'Config is loaded.' )
        or note explain $actual;
}

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $app = App::Subcmd->new( { noop => { code => sub {} } }, { config => $ft->filename } );

    output_is( $app, sub { $app->synopsis }, <<EOF, 'See both the commands and aliases' );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]

Aliases:
  help2	: help help
  list	: synopsis
EOF
}

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $app = App::Subcmd->new( { noop => { code => sub {} } }, { config => $ft->filename } );

    output_is( $app, sub { $app->run( 'list' ) }, <<EOF, 'Verify single command alias works' );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]

Aliases:
  help2	: help help
  list	: synopsis
EOF
}

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $app = App::Subcmd->new( { noop => { code => sub {} } }, { config => $ft->filename } );

    output_is( $app, sub { $app->run( 'help2' ) }, <<EOF, 'Verify command/arg alias works' );

help [command|alias]
        Display help about commands and/or aliases. Limit display with the
        argument.
EOF
}

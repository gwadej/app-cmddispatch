#!/usr/bin/env perl

use Test::More tests => 8;

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

    output_is( $app, sub { $app->run( qw/help commands/ ) }, <<EOF, 'Verify help commands works' );

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

    output_is( $app, sub { $app->run( qw/help aliases/ ) }, <<EOF, 'Verify help aliases' );

Aliases:
  help2\t: help help
  list\t: synopsis
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

    output_is( $app, sub { $app->run( qw/synopsis commands/ ) }, <<EOF, 'Verify synopsis commands works' );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    output_is( $app, sub { $app->run( qw/synopsis aliases/ ) }, <<EOF, 'Verify synopsis aliases' );

Aliases:
  help2\t: help help
  list\t: synopsis
EOF
}

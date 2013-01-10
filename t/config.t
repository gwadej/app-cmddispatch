#!/usr/bin/env perl

use Test::More tests => 9;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::IO;

use File::Temp;
use App::CmdDispatch;

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

    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename } );
    my $actual = $app->get_config;
    is_deeply( $actual, { parm1 => 1771, parm2 => 7171 }, 'Config is loaded.' )
        or note explain $actual;
}

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
default_commands=shell help
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename, io => $io } );

    my $got = [ $app->command_list ];
    is_deeply( $got, [ qw/noop shell synopsis help/ ], "Correct commands found.\n" )
        or note explain $got;
    $got = [ $app->alias_list ];
    is_deeply( $got, [ qw/help2 list/ ], "Correct aliases found.\n" )
        or note explain $got;
}

{
    my $ft = File::Temp->new( SUFFIX => '.conf' );
    print {$ft} <<EOF;
parm1=1771
parm2=7171
default_commands=shell help
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename, io => $io } );

    $app->run( 'list' );
    is( $io->output, <<EOF, 'Verify single command alias works' );

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
default_commands=shell help
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename, io => $io } );

    $app->run( 'help2' );
    is( $io->output, <<EOF, 'Verify command/arg alias works' );

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
default_commands=shell help
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename, io => $io } );

    $app->run( qw/help commands/ );
    is( $io->output, <<EOF, 'Verify help commands works' );

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

    $io->clear;
    $app->run( qw/help aliases/ );
    is( $io->output, <<EOF, 'Verify help aliases' );

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
default_commands=shell help
[alias]
list=synopsis
help2=help help
EOF
    close $ft;

    my $io = Test::IO->new;
    my $app = App::CmdDispatch->new( { noop => { code => sub {} } }, { config => $ft->filename, io => $io } );

    $app->run( qw/synopsis commands/ );
    is( $io->output, <<EOF, 'Verify synopsis commands works' );

Commands:
  noop
  shell
  synopsis [command|alias]
  help [command|alias]
EOF

    $io->clear;
    $app->run( qw/synopsis aliases/ );
    is( $io->output, <<EOF, 'Verify synopsis aliases' );

Aliases:
  help2\t: help help
  list\t: synopsis
EOF
}

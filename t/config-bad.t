#!/usr/bin/env perl

use Test::More tests => 1;
use Test::Exception;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Subcmd 'output_is';

use File::Temp;
use App::Subcmd;

throws_ok { App::Subcmd->new( { noop => { code => sub {} } }, { config => 'xyzzy' } ) }
    qr/Supplied config is not a file./, 'Exception if supplied bad file name';

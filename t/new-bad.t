#!/usr/bin/env perl

use Test::More 'no_plan'; #tests => 1;
use Test::Exception;

use strict;
use warnings;

use App::Subcmd;

throws_ok { App::Subcmd->new }          qr/Command definition is not a hashref/, 'No args';
throws_ok { App::Subcmd->new( 'foo' ) } qr/Command definition is not a hashref/, 'Non-hashref arg';
throws_ok { App::Subcmd->new( {}, 'foo' ) } qr/Options .* not a hashref/, 'Non-hashref options';

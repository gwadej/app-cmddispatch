#!/usr/bin/env perl

use Test::More tests => 6;
use Test::Exception;

use strict;
use warnings;

use App::Subcmd;

throws_ok { App::Subcmd->new }          qr/Command definition is not a hashref/, 'No args';
throws_ok { App::Subcmd->new( 'foo' ) } qr/Command definition is not a hashref/, 'Non-hashref arg';
throws_ok { App::Subcmd->new( {}, 'foo' ) } qr/Options .* not a hashref/, 'Non-hashref options';

# Bad commands
throws_ok { App::Subcmd->new( { foo => 'aa' } ) }
    qr/'foo' is an invalid/, 'Command description not a hash';
throws_ok { App::Subcmd->new( { foo => {} } ) }
    qr/'foo' has no handler/, 'No handler for foo';
throws_ok { App::Subcmd->new( { foo => { code => 'ddd' } } ) }
    qr/'foo' has no handler/, 'Handler for foo is not code';

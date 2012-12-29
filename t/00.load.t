use Test::More tests => 3;

BEGIN {
    use_ok( 'App::CmdDispatch' );
}

note( "Testing App::CmdDispatch $App::CmdDispatch::VERSION" );

can_ok( 'App::CmdDispatch', qw/new get_config run help synopsis shell/ );
can_ok( 'App::CmdDispatch::IO', qw/new print readline prompt/ );

use Test::More tests => 2;

BEGIN {
    use_ok( 'App::CmdDispatch' );
}

note( "Testing App::CmdDispatch $App::CmdDispatch::VERSION" );

can_ok( 'App::CmdDispatch', qw/new set_in_out get_config run help synopsis shell/ );

use Test::More tests => 2;

BEGIN {
    use_ok( 'App::Subcmd' );
}

note( "Testing App::Subcmd $App::Subcmd::VERSION" );

can_ok( 'App::Subcmd', qw/new set_in_out run help man shell/ );

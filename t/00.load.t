use Test::More tests => 2;

BEGIN {
    use_ok( 'App::Subcmd' );
}

note( "Testing App::Subcmd $App::Subcmd::VERSION" );

can_ok( 'App::Subcmd', qw/new run synopsis help shell/ );

use Mojo::Base -strict;
use Test::More;
use Mojo::Pg;
use Test::Mojo;

my $t = Test::Mojo->new('lite_app');

$t->post_ok('/', json => {RFID => '12.34.56.78'})
  ->status_is(200);


done_testing();



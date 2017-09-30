use Test::More;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../library.pl";

my $t = Test::Mojo->new;

$t->post_ok('/', json => {RFID => '12.34.56.78'})
  ->status_is(200);


done_testing();



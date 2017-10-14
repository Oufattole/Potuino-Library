use Test::More;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../library.pl";

my $t = Test::Mojo->new;
$t->post_ok('/', json => {RFID => '1.1.1'});
$t->post_ok('/', json => {RFID => '2.2.2'});

done_testing();



use Mojolicious::Lite;
use Mojo::Pg;

helper pg => sub { state $pg = Mojo::Pg->new('postgresql://qeqiusom:Qt9BJfRld9kw3qBtrpflbcERIo8rmHga@stampy.db.elephantsql.com:5432/qeqiusom') };
app->pg->migrations->from_data->migrate;


post '/' => sub {
  my $c  = shift;
  #$c->pg->migrations->name('my_names_app')->from_string(<<EOF)->migrate;

#EOF
  my $rfid;
  $rfid = $c->req->json->{'RFID'};
  $c->pg->db->query('insert into status (rfid, tick) values (?, current_timestamp) returning *' => $rfid);
  $c->render(text => "rfid of $rfid recieved", format => 'txt');
};
#get '/' => sub {
#};

app->start;
__DATA__
@@ migrations
-- 1 up
CREATE TABLE IF NOT EXISTS status ( id SERIAL PRIMARY KEY, rfid text, tick timestamp);
CREATE TABLE IF NOT EXISTS books ( rfid text, name text);
CREATE TABLE IF NOT EXISTS people (rfid text, name text);
-- 1 down
drop table chec;
drop table books;
drop table people;



use Mojolicious::Lite;
use Mojo::Pg;

helper pg => sub { state $pg = Mojo::Pg->new('postgresql://qeqiusom:Qt9BJfRld9kw3qBtrpflbcERIo8rmHga@stampy.db.elephantsql.com:5432/qeqiusom') };
app->pg->migrations->from_data->migrate;


post '/' => sub {
  my $c  = shift;
	my $rfid = $c->req->json->{'RFID'};
  $c->session(expiration => 10);
  #if ( $c->session('user') eq '' ) 

  
  if ($c->session('user') == '1')#executes if person has already swipped login tag
  #check if it is book, put it after prfid, and set status to out
  {
  	my @books = $c->pg->db->query('select brfid from books')->to_array;
  		my $y = 0;
  		foreach my $book ( @books )
  			if($book eq $rfid)
  				$y=1;
  		if($y==1){
  			$c->pg->db->query('update books set status = "out", where brfid = ?' => $rfid);
  			$c->pg->db->query('insert into log (prfid, brfid, tick) values (?, ?, current_timestamp)' => ($c->session('urfid'), $rfid);
  		}
  	$c->session(expiration => 0);
  }
  else{#if book it checks out, if person it waits for else if statement
  #otherwise it stops
  	my @people = $c->pg->db->query('select prfid from people')->to_array;
  	my $x = 0;
  	foreach my $peep ( @people ){ # checking if person rfid
  		if ($peep eq $rfid)
  			$x=1;}
  	if ($x=1) # found person
  	{
  		$c->session(user => '1');
  		$c->session(urfid => $rfid);
  		$c->session(expiration => 10);
  	}
  	else{ # checking if book rfid
  		my @books = $c->pg->db->query('select brfid from books')->to_array;
  		my $y = 0;
  		foreach my $book ( @books )
  			if($book eq $rfid)
  				$y=1
  		if($y=1){
  		$c->pg->db->query('update books set status = "in", where brfid = ?' => $rfid); #sets book status to in
  		}
  		else;# both checks failed, it is not book or person rfid
  		$c->session(expiration => 0);
  			
  	}
  }
  #$c->render(text => "rfid of $rfid recieved", format => 'txt');
};
#get '/' => sub {
#};

app->start;
__DATA__
@@ migrations
-- 1 up
#CREATE TABLE IF NOT EXISTS status ( id SERIAL PRIMARY KEY, rfid text, tick timestamp);
CREATE TABLE IF NOT EXISTS log (prfid text, brfid text, tick timestamp);
CREATE TABLE IF NOT EXISTS books ( brfid text, name text, status text);
CREATE TABLE IF NOT EXISTS people (prfid text, name text);
-- 1 down
drop table chec;
drop table books;
drop table people;



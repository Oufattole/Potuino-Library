use Mojolicious::Lite;
use Mojo::Pg;
app->config(hypnotoad => {listen => ['http://*:3004']});
helper pg => sub { state $pg = Mojo::Pg->new('postgresql://qeqiusom:Qt9BJfRld9kw3qBtrpflbcERIo8rmHga@stampy.db.elephantsql.com:5432/qeqiusom') };
app->pg->migrations->from_data->migrate;
app->secrets(['Keystone']);

post '/' => sub {
	my $c  = shift;
	my $y = 0;
	my $x = 0;
	warn $c->req->json->{'RFID'};
	my $rfid = $c->req->json->{'RFID'};
	my $response= 'error';
	warn $rfid;
	warn 'begin';
  	$c->session(expiration => 20);
  	warn $c->session('user');
  	#if ( $c->session('user') eq '' ) 
  	#warn $c->session('user');
  	if ($c->session('user') eq '1')#executes if person has already swipped login tag
  	#check if it is book, put it after prfid, and set status to out
  	{
  		warn 'Step 2';
  		my @books = @{$c->pg->db->query('select brfid from books')->hashes};
  			foreach my $book ( @books ){
  				if($book->{'brfid'} eq $rfid){
  					$y=1;
  				}
  			}
  		if($y==1){
  			my @values = ('out', $rfid);
  			$c->pg->db->query('update books set status = ? where brfid = ?' => @values);
  			@values = ($c->session('urfid'), $rfid);
  			$c->pg->db->query('insert into log (prfid, brfid, tick) values (?, ?, current_timestamp)' => @values);
  			$response= 'check out logged';
  		}
  	$c->session(expiration => 0);
  	}
  	else{#if book it checks out, if person it waits for next swipe and will store data
  	#otherwise it stops
  	warn 'Step 1';
  		my @people = @{$c->pg->db->query('select prfid from people')->hashes};
  		#warn %{${$people[0]}[1]};
  		warn @people;
  		$x = 0;
  		foreach my $peep ( @people ){ # checking if person rfid
  			warn $peep->{'prfid'};
  			if ($peep->{'prfid'} eq $rfid){
  				$x = 1;
  			}
  		}
  		if ($x==1) # found person
  		{
  			warn 'person found';
  			$c->session(user => '1');
  			$c->session(urfid => $rfid);
  			$c->session(expiration => 20);
  			$response= 'logged in';
  		}
  		else{ # checking if book rfid
  			warn 'book check';
  			my @books = @{$c->pg->db->query('select brfid from books')->hashes};
  			$y = 0;
  			foreach my $book ( @books ){
  				warn $book->{brfid};
  				if($book->{brfid} eq $rfid){

  					$y=1;
  				}
  			}
  			
  			if($y==1){
  				warn 'book found';
  				my @values = ('in', $rfid);
  				$c->pg->db->query('update books set status = ? where brfid = ?' => @values); #sets book status to in
  				$response= 'Book checked in';
  			}
  			warn 't1';
  			$c->session(expiration => 0);
  			warn 't2';
  		}
  		warn 'hey1';
  	}
  	warn 'hey2';
  	warn $response;
  	#$c->render(text => $response, format => 'txt');
  	$c->render(json => {resp => $response});
  };
  #warn 'hey';
  #$c->render(text => "rfid of $rfid recieved", format => 'txt');

#get '/' => sub {
#};
#CREATE TABLE IF NOT EXISTS status ( id SERIAL PRIMARY KEY, rfid text, tick timestamp);
app->start;
__DATA__
@@ migrations
-- 1 up

CREATE TABLE IF NOT EXISTS log (prfid text, brfid text, tick timestamp);
CREATE TABLE IF NOT EXISTS books ( brfid text, name text, status text);
CREATE TABLE IF NOT EXISTS people (prfid text, name text);
-- 1 down
drop table chec;
drop table books;
drop table people;



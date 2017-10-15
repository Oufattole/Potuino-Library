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
	my $rfid = $c->req->json->{'RFID'};
	my $response= 'error';
  	$c->session(expiration => 20);
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
  		$x = 0;
  		foreach my $peep ( @people ){ # checking if person rfid
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
  			$c->session(expiration => 0);
  		}

  	}

  	$c->render(json => {resp => $response});
  };


get '/' => sub {
  my $c = shift;
  
  $c->render(template => 'catalog');
};
get '/catalog' => sub {
	my $c = shift;
	my @bookha = @{$c->pg->db->query('select brfid from books')->hashes};
  my @bookrfid = ();
  my @bookname = ();
  foreach my $book ( @bookha )
  {
  		push @bookrfid, $book->{'brfid'};
  }
  	@bookha = @{$c->pg->db->query('select name from books')->hashes};
  	foreach my $book ( @bookha )
  	{
  		push @bookname, $book->{'name'};
  	}
  	my %books;
	@books{@bookname} = @bookrfid;
	$c->render(json => %books)
};


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

@@ catalog.html.ep
<html>
<script type="text/javascript">
    var data = {key1: "val1", key2: "val2"};
    for (var key in data) {
       $('table').append('<tr><td>' + data[key] + '</td></tr>');
    }
</script>
</html>

@@ index.html.ep
<html>
<style>
/*----- Toggle Button -----*/
.toggle-nav {
    display:none;
}
h1 {
	color:#66a992;
}
 
/*----- Menu -----*/
@media screen and (min-width: 860px) {
    .menu {
        width:95%;
        padding:10px 18px;
        box-shadow:0px 1px 1px rgba(0,0,0,0.15);
        border-radius:3px;
        background:#303030;
    }
}
 
.menu ul {
    display:inline-block;
}
 
.menu li {
    margin:0px 50px 0px 0px;
    float:left;
    list-style:none;
    font-size:17px;
}
 
.menu li:last-child {
    margin-right:0px;
}
 
.menu a {
    text-shadow:0px 1px 0px rgba(0,0,0,0.5);
    color:#777;
    transition:color linear 0.15s;
}
 
.menu a:hover, .menu .current-item a {
    text-decoration:none;
    color:#66a992;
}
 
/*----- Search -----*/
.search-form {
    float:right;
    display:inline-block;
}
 
.search-form input {
    width:200px;
    height:30px;
    padding:0px 8px;
    float:left;
    border-radius:0px 0px 0px 20px;
    font-size:13px;
}
 
.search-form button {
    height:30px;
    padding:0px 7px;
    float:right;
    border-radius:0px 0px 20px 0px;
    background:#66a992;
    font-size:13px;
    font-weight:600;
    text-shadow:0px 1px 0px rgba(0,0,0,0.3);
    color:#fff;
}
 
/*----- Responsive -----*/
@media screen and (max-width: 1150px) {
    .wrap {
        width:90%;
    }
}
 
@media screen and (max-width: 970px) {
    .search-form input {
        width:120px;
    }
}
 
@media screen and (max-width: 860px) {
    .menu {
        position:relative;
        display:inline-block;
    }
 
    .menu ul.active {
        display:none;
    }
 
    .menu ul {
        width:100%;
        position:absolute;
        top:120%;
        left:0px;
        padding:10px 18px;
        box-shadow:0px 1px 1px rgba(0,0,0,0.15);
        border-radius:3px;
        background:#303030;
    }
 
    .menu ul:after {
        width:0px;
        height:0px;
        position:absolute;
        top:0%;
        left:22px;
        content:'';
        transform:translate(0%, -100%);
        border-left:7px solid transparent;
        border-right:7px solid transparent;
        border-bottom:7px solid #303030;
    }
 
    .menu li {
        margin:5px 0px 5px 0px;
        float:none;
        display:block;
    }
 
    .menu a {
        display:block;
    }
 
    .toggle-nav {
        padding:20px;
        float:left;
        display:inline-block;
        box-shadow:0px 1px 1px rgba(0,0,0,0.15);
        border-radius:3px;
        background:#303030;
        text-shadow:0px 1px 0px rgba(0,0,0,0.5);
        color:#777;
        font-size:20px;
        transition:color linear 0.15s;
    }
 
    .toggle-nav:hover, .toggle-nav.active {
        text-decoration:none;
        color:#66a992;
    }
 
    .search-form {
        margin:12px 0px 0px 20px;
        float:left;
    }
 
    .search-form input {
        box-shadow:-1px 1px 2px rgba(0,0,0,0.1);
    }
}
</style>
<script>
jQuery(document).ready(function() {
    jQuery('.toggle-nav').click(function(e) {
        jQuery(this).toggleClass('active');
        jQuery('.menu ul').toggleClass('active');
 
        e.preventDefault();
    });
    $.getJSON( "/catalog", function( data ) {
  var items = [];
  $.each( data, function( key, val ) {
    items.push( "<li id='" + key + "'>" + val + "</li>" );
  });
 
  $( "<ul/>", {
    "class": "my-new-list",
    html: items.join( "" )
  }).appendTo( "body" );
});
});

</script>
<title>Keystone Library</title>
<h1>Keystone Library<h1>
<nav class="menu">
    <ul class="active">
        <li id="catalog", class="current-item"><a href="/catalog">Catalog</a></li>
        <li><a href="/logs">Checking Logs</a></li>
        <li><a href="/user">User Database</a></li>
        <li><a href="/secret">Book Database</a></li>
    </ul>
 
    <a class="toggle-nav" href="#">&#9776;</a>
 
    <form class="search-form">
        <input type="text">
        <button>Search</button>
    </form>
</nav>
<body>

</body>
</html>
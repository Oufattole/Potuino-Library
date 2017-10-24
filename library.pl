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
  $c->render(template => 'index', table => 'home', result => '');
};
get '/catalog' => sub {
  my $c = shift;
  $c->render(template => 'index', table => 'catalog', result => '');
};
get '/user' => sub {
  my $c = shift;
  $c->render(template => 'index', table => 'users', result => '');
};
get '/logs' => sub {
  my $c = shift;
  $c->render(template => 'index', table => 'logs', result => '');
};
get '/update' => sub {
  my $c = shift;
  $c->render(template => 'index', table => 'update', result => '');
};


get '/search' => sub {
  my $c = shift;
  my $result='error';
  my $rfid = $c->param('RFID');
  my $type = $c->param('medium');
  my $check;
  if(length($rfid)>0){
  if($type eq 'book'){
    $check = $c->pg->db->query('select name from books where brfid = ?' => $rfid)->array;
  if(defined($check)){
  $result = 'RFID: '.$rfid ." represents Book: ". $check->[0];
  }}
  else{
    $check = $c->pg->db->query('select name from people where prfid = ?' => $rfid)->array;
  if(defined($check)){
  $result = 'RFID: '.$rfid ." represents User: ". $check->[0];
  }}
}
warn $result;
  $c->render(template => 'index', table => 'search', result => $result);
};



get '/add' => sub {
  my $c = shift;
  my $rfid = $c->param('rfid');
  my $name = $c->param('name');
  my $root = 'add';
  if(length($rfid)>0 && length($name)>0){
  my $type = $c->param('type');
  my @values;
  if($type eq 'Book'){
  @values = ($rfid, $name, 'in');
  warn @values;
  $c->pg->db->query('insert into books (brfid, name, status) values (?, ?, ?)' => @values);
  }
  else{
    @values = ($rfid, $name);
  $c->pg->db->query('insert into people (prfid, name) values (?, ?)' => @values);
  }
}
else{
$root = 'error';
  }
  $c->render(template => 'index', table => $root, result => '', result => '');
};

get '/catalog/:id' => sub {
  my $c = shift;
  warn $c->param('id');
  $c->pg->db->query('delete from books where name = ?' => $c->param('id'));
  $c->render(template => 'index', table => 'catalog', result => '');
};
get '/user/:id' => sub {
  my $c = shift;
  warn $c->param('id');
  $c->pg->db->query('delete from people where name = ?' => $c->param('id'));
  $c->render(template => 'index', table => 'users', result => '');
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

@@ add.html.ep


@@ index.html.ep
<html>
<style>
/*----- Table -----*/
table {
    border-collapse: collapse;
}
th {
    background-color: #303030;
    color: #66a992;
}
tr:nth-child(even) {background-color: #f2f2f2}
th, td {
    border-bottom: 1px solid #ddd;
    padding: 15px;
    text-align: left;
}
/*----- Toggle Button -----*/
.toggle-nav {
    display:none;
}
h1 {
  color:#66a992;
}
 
/*----- Menu -----*/
@media screen and (min-width: 1000px) {
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
 
@media screen and (max-width: 1000px) {
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
h4{
  font-size: 10px;
}
</style>
<script>
jQuery(document).ready(function() {
    jQuery('.toggle-nav').click(function(e) {
        jQuery(this).toggleClass('active');
        jQuery('.menu ul').toggleClass('active');
 
        e.preventDefault();
    });
});

</script>
<title>Keystone Library</title>
<h1>Keystone Library<h1>
<nav class="menu">
    <ul class="active">
        % if($table eq 'logs'){
        <li id="home"><a href="/">Home</a></li>
        <li ><a href="/catalog">Catalog</a></li>
        <li class="current-item"><a href="/logs">Checking Logs</a></li>
        <li><a href="/user">User Database</a></li>
        <li><a href="/update">Add Units</a></li>
        %}
        % elsif($table eq 'users'){
        <li id="home"><a href="/">Home</a></li>
        <li><a href="/catalog">Catalog</a></li>
        <li><a href="/logs">Checking Logs</a></li>
        <li class="current-item"><a href="/user">User Database</a></li>
        <li><a href="/update">Add Units</a></li>
        %}
        % elsif($table eq 'catalog'){
        <li id="home"><a href="/">Home</a></li>
        <li class="current-item"><a href="/catalog">Catalog</a></li>
        <li><a href="/logs">Checking Logs</a></li>
        <li><a href="/user">User Database</a></li>
        <li><a href="/update">Add Units</a></li>
        %}
        % elsif($table eq 'home'){
        <li id="home", class="current-item"><a href="/">Home</a></li>
        <li><a href="/catalog">Catalog</a></li>
        <li><a href="/logs">Checking Logs</a></li>
        <li><a href="/user">User Database</a></li>
        <li><a href="/update">Add Units</a></li>
        %}
        % else{
        <li id="home"><a href="/">Home</a></li>
        <li><a href="/catalog">Catalog</a></li>
        <li><a href="/logs">Checking Logs</a></li>
        <li><a href="/user">User Database</a></li>
        <li class="current-item"><a href="/update">Add Units</a></li>
        %}
    </ul>
 
    <a class="toggle-nav" href="#">&#9776;</a>
 
   
    <form action="/search", class="search-form">
%= select_field medium => ['book', 'user']
  <input name="RFID" type="text">
  <button type="submit" value="Submit">Search RFID Value</button>
</form>
</nav>

<body>
% if($table eq 'catalog')
%{
% my @sth = @{pg->db->query('select * from books')->arrays->to_array};
  <br>
  
  <table>
    <tr>
      <th>RFID</th>
      <th>Book Name</th>
      <th>Stock Status</th>
    </tr>
    % for my $row (@sth) {
      <tr>
        % for my $text (@$row) {
          <td><%= $text %></td>
        % }
        <td>
        %= link_to delete => '/catalog/' . @$row[1]
        </td>
      </tr>

    % }
    </table>
%}
% elsif($table eq 'users')
%{
% my @sth = @{pg->db->query('select * from people')->arrays->to_array};
  <br>
  <table>
    <tr>
      <th>RFID</th>
      <th>Username</th>
    </tr>
    % for my $row (@sth) {
      <tr>
        % for my $text (@$row) {
          <td><%= $text %></td>
        % }
        <td>
        %= link_to delete => '/user/' . @$row[1]
        </td>
      </tr>
    % }
    </table>
%}
% elsif($table eq 'logs')
%{
% my @sth = @{pg->db->query('select * from log limit 100')->arrays->to_array};
  <br>
  <table>
    <tr>
      <th>Person RFID</th><th></th>
      <th>Book RFID</th>
      <th>Timestamp</th>
    </tr>
    % for my $row (reverse(@sth)) {
      % my $x=0;
      <tr>
        % for my $text (@$row) {
          % $x++;
          % if($x==1){
              <td><%=$text %><td>
          % }
          % elsif($x==2){
            <td><%= $text%></td>
          % }
          % else{
          <td><%=$text %></td>
        % }
        %}
      </tr>
    % }
    </table>
%}
% elsif($table eq "update"){
<h3>
%= form_for add => begin
User or Book
%= select_field type => ['Book', 'User']
RFID
  %= text_field 'rfid'
Name
  %= text_field 'name'
  %= submit_button 'Submit'
% end
</h3>
% }
% elsif($table eq 'add'){
<h3>
SUCCESS!
%= form_for add => begin
User or Book
%= select_field type => ['Book', 'User']
RFID
  %= text_field 'rfid'
Name
  %= text_field 'name'
  %= submit_button 'Submit'
% end
</h3>
% }
% elsif($table eq 'error'){
<h3 color = red>ERROR</h3>
%= form_for add => begin
User or Book
%= select_field type => ['Book', 'User']
RFID
  %= text_field 'rfid'
Name
  %= text_field 'name'
  %= submit_button 'Submit'
% end
</h3>
% }
% elsif($table eq 'search'){
<h3>
%= $result;
</h3>
% }
% else{}
  
</body>
</html>

@@ secret.html.ep
<html>
Secrets! Secrets! are no fun
Until they're shared with everyone!

<html>

use Mojolicious::Lite;
use Mojo::Pg;
use Data::Dumper;
app->config(hypnotoad => {listen => ['http://*:3004']});
helper pg => sub { state $pg = Mojo::Pg->new('postgresql://qeqiusom:Qt9BJfRld9kw3qBtrpflbcERIo8rmHga@stampy.db.elephantsql.com:5432/qeqiusom') };
app->pg->migrations->from_data->migrate;
app->secrets(['Keystone']);

get '/' => sub {
my $c = shift;
  $c->render(template => 'index');
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
 
@@ index.html.ep
% my $sth = pg->db->query('SELECT * FROM books');
<html>
<p>Hello tester</p>
<body>

  <br>
  Data: <br>
  <table border="1">
    <tr>
      <th>Name</th>
      <th>Age</th>
    </tr>
    % while (my $row = $sth->arrays->to_array) {
      <tr>
        % for my $text (@$row) {
          <td><%= $text %></td>
        % }
      </tr>
    % }
  </table>
</body>
</html>
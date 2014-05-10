<html><head><title>Bazil McKenzie - Logs</title></head>
<body bgcolor="white" text="black">
<?php
	$link = mysql_connect("www.freesql.org", "bazil", "fnord")
	   or die("Could not connect : " . mysql_error());
	echo "<br>Connected successfully...";
	mysql_select_db("iantha") or die("Could not select database");

$query = "SELECT id, dt, title, location FROM log ORDER BY dt ASC";
$result = mysql_query($query) or die("Query failed : " . mysql_error());

echo "<table border=\"1\">\n";
echo "<tr><td>ID</td><td>Date</td><td>Title</td><td>Location</td></tr>\n";
while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
   echo "\t<tr>\n";
   foreach ($line as $col_value) {
       echo "\t\t<td>$col_value</td>\n";
   }
   echo "\t</tr>\n";
}
echo "</table>\n";

mysql_free_result($result);

mysql_close($link);
?>
<br><FORM action="insert.php" method="post">
    <P>
    <b>ADD LOG</b><br>
    Date: <INPUT type="text" name="dt"> Title: <INPUT type="text" name="title"><BR>
    Location: <INPUT type="text" name="location"><BR>
    Characters: <INPUT type="text" name="characters"><BR>
    Background:<BR><INPUT type="textarea" rows=7 cols=80 name="background"><BR>
    Log:<BR><INPUT type="textarea" rows=7 cols=80 name="log"><BR>
    <INPUT type="password" type="text" name="pw" value="**********" size="10"><BR>
    <INPUT type="submit" value="Send"> <INPUT type="reset">
    </P>
</FORM>
<FORM action="delete.php" method="post">
    <P>
    <b>DELETE WORD</b><br>
    ID#: <INPUT type="text" name="id" size="3">
    <INPUT type="password" type="text" name="pw" value="**********" size="10"><BR>
    <INPUT type="submit" value="Send"> <INPUT type="reset">
    </P>
</FORM>
<FORM action="update.php" method="post">
    <P>
    <b>UPDATE LOG</b><br>
    ID#: <INPUT type="text" name="id" size="3">
    <INPUT type="password" type="text" name="pw" value="**********" size="10"><BR>
    &nbsp;&nbsp;<SELECT name="field">
	<OPTION selected value="none">Field to Change</OPTION>
	<OPTION value="dt">Date</OPTION>
	<OPTION value="title">Title</OPTION>
	<OPTION value="location">Location</OPTION>
	<OPTION value="characters">Characters</OPTION>
	<OPTION value="background">Background</OPTION>
	<OPTION value="log">Log</OPTION>
    </SELECT><br>
    New Value:<br><INPUT type="textbox" name="value" rows=7 cols=80><br>
    <INPUT type="submit" value="Send"> <INPUT type="reset">
    </P>
</FORM>

<br /><br /><a href="..\logs.php">Main Logs</a>
</body>
</html>
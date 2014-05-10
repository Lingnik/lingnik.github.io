<html><head><title>Bazil's Logs - #<? echo($id); ?></title></head>
<body>
<?php
$link = mysql_connect("www.freesql.org", "bazil", "fnord")
   or die("Could not connect : " . mysql_error());
mysql_select_db("iantha") or die("Could not select database");
$query = "SELECT * FROM log WHERE id=$id";
$result = mysql_query($query) or die("Query failed : " . mysql_error());

while ($line = mysql_fetch_array($result, MYSQL_NUM)) {
  echo ("#$line[0] - $line[1]<br />");
  echo ("\"$line[2]\"<br />");
  echo ("$line[3]<br />");
  echo ("$line[4]<br /><br />");
  echo ("$line[5]<br /><br />");
  echo ("------------------------------------------------------------------------------<br /><br />");
  echo ("$line[6]<br /><br />");
  echo ("&lt;Log Ends&gt;<br />");
  echo ("------------------------------------------------------------------------------<br />");
}

?>
<a href="logs.php">Back</a>
</body>
</html>
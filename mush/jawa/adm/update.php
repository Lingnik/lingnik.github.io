<html><head><title>Bazil's Logs - Deleting...</title></head>
<body bgcolor="white" text="black">
<?php
if ($pw == "iantha")
{
   if ($field == "none")
   {
      echo "YOU MUST CHOOSE A FIELD TYPE.\n<br>";
      echo "You have been devoured by a grue.\n";
   } else {
	echo "Connecting...";
	$link = mysql_connect("www.freesql.org", "bazil", "fnord")
	   or die("Could not connect : " . mysql_error());
	echo "<br>Connected successfully...";
	mysql_select_db("iantha") or die("Could not select database");
	
	echo "<br>Sending request to update #" . $id . "...";
	$query = "UPDATE log SET " . $field . "=\"" . addslashes(nl2br($value)) . "\" WHERE id=" . $id;
	$result = mysql_query($query) or die("<br>Query failed : " . mysql_error());
	
	echo "<br>Completed... Cleaning up...\n";
	
	mysql_free_result($result);

	mysql_close($link);
   }
} else {
	echo "<br>Permission denied. Password incorrect.\n";
}
?>
<br><br><a href="index.php">Return.</a>
</body>
</html>
<html><head><title>Bazil's Logs - Updating...</title></head>
<body bgcolor="white" text="black">
<?php
if ($pw == "abaddon" OR $pw == "iantha")
{
	echo "Connecting...";
	$link = mysql_connect("www.freesql.org", "bazil", "fnord")
	   or die("Could not connect : " . mysql_error());
	echo "<br>Connected successfully...";
	mysql_select_db("iantha") or die("Could not select database");
	
	echo "<br>Sending new data...";
	$query = "INSERT INTO log VALUES (NULL,\"" . $dt . "\",\"" . addslashes($title) . "\",\"" . addslashes($location) . "\",\"" . addslashes($characters) . "\",\"" . addslashes(nl2br($background)) . "\",\"" . addslashes(nl2br($log)) . "\")";
	$result = mysql_query($query) or die("<br>Query failed : " . mysql_error());
	
	echo "<br>Completed... Cleaning up...\n";
	
	mysql_free_result($result);

	mysql_close($link);
} else {
	echo "<br>Permission denied. Password incorrect.\n";
}
?>
<br><br><a href="index.php">Return.</a>
</body>
</html>
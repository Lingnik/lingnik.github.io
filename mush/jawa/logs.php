<HTML><HEAD><TITLE>Bazil's Logs - Index</TITLE></HEAD>
<BODY>

<?PHP
$link = mysql_connect("www.freesql.org", "bazil", "fnord")
   or die("Could not connect : " . mysql_error());
mysql_select_db("iantha") or die("Could not select database");

$query = "SELECT * FROM log";
$result = mysql_query($query) or die("Query failed : " . mysql_error());

 $count = 0;
 printf ("<table border=\"1\">\n");
 printf ("\t<tr><td>ID</td><td>Date</td><td>Title</td><td>Location</td></tr>\n");
 while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
    printf ("\t<tr>\n");
     printf ("\t\t<td><a href=\"view.php?id=%s\">%s</a></td>", $row["id"], $row["id"]);
     printf ("\t\t<td><a href=\"view.php?id=%s\">%s</a></td>", $row["id"], $row["dt"]);
     printf ("\t\t<td><a href=\"view.php?id=%s\">%s</a></td>", $row["id"], $row["title"]);
     printf ("\t\t<td><a href=\"view.php?id=%s\">%s</a></td>", $row["id"], $row["location"]);
    printf ("\t</tr>\n");
    $count++;
 }
 printf ("</table>\n");
 printf ("\t$count logs returned.\n");

 mysql_free_result($result);
?>
<br /><br /><a href=".\">The Dirty Jawa</a>

</BODY>
</HTML>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html> <head>
<title></title>
</head>

<body>
<h1></h1>
<?php
session_start();
$_SESSION = array();
session_destroy();
$msg = "LOG-OUT EFFETTUATO.";
$msg = urlencode($msg); // non ci possono essere spazi nell'URL
header("location: index.php?msg=$msg");
exit();
?>



<hr>
<address></address>
<!-- hhmts start --> Last modified: Thu Aug  7 11:43:11 CEST 2014 <!-- hhmts end -->
</body> </html>

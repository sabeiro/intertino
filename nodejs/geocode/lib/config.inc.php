<?php
global $db_host, $db_user, $db_password, $db_name;
$db_host = "localhost";
$db_user = "kotoba";
$DaCrittografare = "t61kvg90";
$Crittografata="5cdecd096ef2dc0dd743d8803bcd9fad";//sha1
//$db_password = md5($DaCrittografare);
$db_password = $DaCrittografare;
$db_name = "patient";
?>

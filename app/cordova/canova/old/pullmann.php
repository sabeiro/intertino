<!DOCTYPE HTML>
<html>
<head>
 <?php
include("Intestazioni.php");
WrHeader();
include("config.inc.php");
include("SqlFunction.php");
include("AdminFuncSql.php");
$addetto="";
if(isset($_GET['Name'])){  $addetto = $_GET['Name'];}
$pullmann="";
if(isset($_GET['Name'])){  $pullmann = $_GET['Pullmann'];}
?>
<link rel="stylesheet" type="text/css" href="css/coupon.css">
  </head>
  <?  Priv();
  $dbConn = new AdminSql();
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>
<body>
<div class="testbox">
  <? Intestazione(); Priv();?>
  <hr>
  <div class="pagetype">
  Modifica dati
  </div>
  <hr>
  <form method="get" action='<?php echo $PHP_SELF; ?>'>
  <?php WrProfile($dbConn,"pullmann","wa_pullmann"); ?>
  <?php Chiusura(); ?>
  </div>
  </body>
  </html>


<!DOCTYPE HTML>
<html>
<head>
  <?php
     include("Intestazioni.php");
     include("config.inc.php");
     include("SqlFunction.php");
include("AdminFuncSql.php");
     WrHeader();
if (!isset($_SESSION['login'])){	
    header("Location: index.php");
}
     ?>
<link rel="stylesheet" type="text/css" href="css/reg.css">
<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,300,300italic,400italic,600' rel='stylesheet' type='text/css'>
<link href="//netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css" rel="stylesheet">
</head>
<body>
  <?php
$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>

<div class="testbox">
<?php Intestazione(); Priv();?>
      <hr>
    <div class="pagetype">
  Amministrazione
    </div>
  <hr>
  <br><br>
  <a class="buttonBig" id="coupon" href="addetti.php"> modifica addetti</a> <br>
  <br><br>
  <a class="buttonBig" id="coupon" href="pullmann.php"> modifica pullmann</a> <br>
<br><br>
  <a class="buttonBig" id="coupon" href="riepilogo.php"> consulta storico</a> <br>
  <br><br>

<?php Chiusura(); ?>
</div>
</div>
</body>
</html>

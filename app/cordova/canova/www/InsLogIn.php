<!DOCTYPE HTML>
<html>
<head>
  <?php
     include("Intestazioni.php");
     include("config.inc.php");
     include("SqlFunction.php");
include("AdminFuncSql.php");
     $_SESSION['WSum']=$_GET['sum'];
     WrHeader();
     ?>
  <script type="text/javascript" src="js/jquery-1.3.2.min.js" ></script>
  <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js" ></script>
  <link rel="stylesheet" href="css/jquery-ui-1.7.2.custom.css" type="text/css" >
</head>
<body>
  <?php
session_start();
$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>

<div class="testbox">
<?php Intestazione(); ?>

Log in <br>
<?php LogIn($dbConn); ?>
<?php Chiusura(); ?>
</div>

</body>
</html>


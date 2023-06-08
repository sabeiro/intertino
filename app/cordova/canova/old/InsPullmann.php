<!DOCTYPE HTML>
<html>
<head>
    <?php
       include("Intestazioni.php");
       include("config.inc.php");
       include("SqlFunction.php");
include("AdminFuncSql.php");

WrHeader();
       ?>
<script type="text/javascript" src="js/jquery-1.3.2.min.js" /></script>
  <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js" ></script>
<link rel="stylesheet" href="css/jquery-ui-1.7.2.custom.css" type="text/css" />
</head>
<body>
    <?php
$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name); 
?>
<div class="testbox">
<? Intestazione(); ?>

  <div id="container">
<br><br><br>
      <div class="selection1" id="event"> 
    <?php InsRecord($dbConn,$_POST[PAddetto],$_POST[PPullmann],$_POST[PPulizia],$_POST[datepicker],$_POST[PManutenzione]); 
    header("Location: index.php");
?>
      </div> <!--selector-->
      <br> <br> <br> <br> 
	 <p> <a class="button" id="coupon" href="index.php"> home </a></p>

<?php Chiusura(); ?>
</div>
  </body>
</html>

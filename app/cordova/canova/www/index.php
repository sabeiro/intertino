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
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
<script src="//code.jquery.com/ui/1.11.0/jquery-ui.js"></script>
<link rel="stylesheet" href="/resources/demos/style.css">
<script>
$(function() {
$( "#datepicker" ).datepicker({ dateFormat: "yy-mm-dd" });
});
</script>
</head>
<body>
  <?php

$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>

<div class="testbox">
<?php Intestazione(); ?>

<form action="InsPullmann.php" method="post">
      <hr>
    <div class="pagetype">
Inserimento dati
    </div>
  <hr>
  <!-- <label id="icon" for="name"><i class="icon-envelope "></i></label> -->
  <!-- <input type="text" name="name" id="name" placeholder="Email" required/> -->
<?php WrList($dbConn); ?>
<?php echo 'Giorno: <input type="text" id="datepicker" class="data-attivita" name="datepicker" size="5" value="' . date('Y-m-d') . '" required/> ' . "\n"; ?><br>
<p>Inserimento delle ultime pulizie.</p>
<input id="saveForm" name="saveForm" class="btTxt submit" type="submit" value="inserisci"/>
 </form>
<?php Chiusura(); ?>
</div>
<script type="text/javascript" src="cordova.js"></script>
        <script type="text/javascript" src="js/index.js"></script>
</body>
</html>

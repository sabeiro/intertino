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
<link rel="stylesheet" type="text/css" href="css/reg.css">
<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,300,300italic,400italic,600' rel='stylesheet' type='text/css'>
<link href="//netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css" rel="stylesheet">
</head>
<body>
  <?php
$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>

<div class="testbox">
<?php Intestazione(); ?>
      <hr>
    <div class="pagetype">
Area privata
    </div>
  <hr>
<form action="InsLogIn.php" method="POST">
  <label id="icon" for="name"><i class="icon-user"></i></label>
  <input type="text" name="username" id="username" placeholder="Utente" required/>
  <label id="icon" for="name"><i class="icon-shield"></i></label>
  <input type="password" name="password" id="password" placeholder="Password" required/>
  <div class="gender">
<!--     <input type="radio" value="None" id="male" name="gender" checked/> -->
<!--     <label for="male" class="radio">Uno</label> -->
<!-- <input type="radio" value="None" id="female" name="gender" /> -->
<!--     <label for="female" class="radio">Due</label> -->
   </div> 
  <p>Nell'area privata si può accedere allo storico degli addetti e modificare i dati.</p>
   <input name="submit" type="submit" value="Login">
</form>
 </form><br>
  <hr>
<?php Chiusura(); ?>
</div>
</div>
</body>
</html>

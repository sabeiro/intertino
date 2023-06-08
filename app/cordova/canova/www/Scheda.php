<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html"; charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gardash</title>
    <meta name="description" content="baresco, deposito e commercio articoli vetrari">
    <meta name="keywords" content="vetro">
    <meta name="author" content="baresco">
    <link rel="stylesheet" href="css/Stile.css" type="text/css">
    <link rel="stylesheet" href="css/Slider.css" type="text/css">
    <link rel="shortcut icon" href="images/favicon.ico">
    <script language="JavaScript" src="js/KotoBa.js" type="text/javascript"></script>
    <script language="JavaScript" src="js/jquery.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery-easing-1.js"></script>
    <script type="text/javascript" src="js/jquery-easing-compatibility.js"></script>
    <!-- <script src="js/ga.js" async="" type="text/javascript"></script> -->
    <!-- <script src="js/modernizr.js"></script> -->
    <!-- <script src="js/pro.js" async="" type="text/javascript"></script> -->
    <!-- <script src="js/bsa.js" async="" type="text/javascript"></script> -->
   <!-- JavaScript -->
  </head>
  <body  style="background-image: url(images/SfondoLeg.png);" >
    <?php
       include("Intestazioni.php");
       include("config.inc.php");
       include("SqlFunction.php");
       Intestazione(); 
       session_start();       
       ?>
<div id="container" class="ltr">
	 <?php WrScheda() ?>
</div><!--container-->
<?php Chiusura(); ?>
  </body>
</html>

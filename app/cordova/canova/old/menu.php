<!DOCTYPE HTML>
<html>
<head>
    <?php
       include("Intestazioni.php");
       include("SqlFunction.php");
       WrHeader();
       ?>
<style type="text/css">
  img, div { behavior: url(web/iepngfix.htc) }
</style>
</head>
<body>
  <div id="container"><!-- start header -->
    <?php session_start();
Intestazione();
//       ColR("transport.php?sum=0");
?>
    <br><br>
    <div id="divCenter">
      <div class="intro-wrap" id="intro"> pulizie </div>
      </div>
    <div id="central-wrap">
      <a class="button" id="coupon" href="pullmann.php?sum=0."><b>TURNI</b></a>
      <a class="button" id="coupon" href="riepilogo1.php?sum=0."><b>PULLMANN</b></a>
      <a class="button" id="coupon" href="riepilogo.php?sum=0."><b>ADDETTI</b></a>
     <a class="button" id="coupon" href="#" onclick="turnLed()"><img id="GuideLed" src="f/redled.png" width="18"> <b>CONNETTI</b></a>
    </div>
</body>
</html>

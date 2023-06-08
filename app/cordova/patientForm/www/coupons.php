<!DOCTYPE HTML>
<html>
<head>
    <?php
       include("Intestazioni.php");
       include("config.inc.php");
       include("SqlFunction.php");
       $_SESSION['WSum']=$_GET['sum'];
       WrHeader();
       ?>
<link rel="stylesheet" type="text/css" href="css/coupon.css">
</head>
</head>
<body>
    <?php
       Intestazione();
       ?>
<div id="container">
<br><br>
  <div id="fixed-image">
  </div>
  <div id="coupon-container"><!-- start header -->
    <div id="central-wrap">
<table width="100%" cellspacing="0" cellpadding="0"><tbody>
	 <tr>
	 <td align="center" width="150">
	   <div id="imageCoupon"> <a href="#" class="selection1" id="transport1">  <img id="imageCoupon1" class="logo" src="f/rist1.jpg" height="60">  </a></div></td>
	 <td align="center" width="150"><div id="imageCoupon"> <a href="#" class="selection1"  id="transport1"> <img id="imageCoupon1"  height="60" class="logo" src="f/rist2.jpg">  </a></div></td>
	 </tr>
	 <tr>
	   <td><a href="#" class="selection" id="transport" onclick='addWallet(10.,"complete")'>  10€ </a></td>
	   <td><a href="#" class="selection" id="transport" onclick='addWallet(10.,"complete")'>  10€ </a></td>
	  </tr><tr>
	 <tr>
	 <td align="center" width="180">  <div id="imageCoupon"><a href="#" class="selection1" id="transport1">  <img id="imageCoupon1" class="logo" src="f/rist5.jpg" height="60">  </a></div></td>
	 <td align="center" width="180">  <div id="imageCoupon"><a href="#" class="selection1"  id="transport1"> <img  id="imageCoupon1" height="60" class="logo" src="f/rist4.jpg">  </a></div></td>
	 </tr>
	 <tr>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(20.,"complete")'> 20€ </a></td>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(20.,"complete")'> 20€ </a></td>
	   </tr></tr></tbody></table>
	 <p id="nextPage"><a class="button" id="coupon" href="complete.php?sum=0"> complete </a></p>
</div>
<div id="footer">
  <div class="testo1">Total: <b id='boldStuff'>0</b> €</div>
</div>
<script>
	 addWallet(parseFloat(<?php CurrSum(); ?>),"complete");
</script>
</body>
</html>

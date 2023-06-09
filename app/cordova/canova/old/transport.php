<!DOCTYPE HTML>
<html>
<head>
    <?php
       include("Intestazioni.php");
       include("config.inc.php");
       include("SqlFunction.php");
       WrHeader();
       session_start();
       $_SESSION['WSum']=0.;
       ?>
</head>
<body>
    <?php
       Intestazione();
       ?>
<div id="container">
<br><br>
<div id="transport-wrap">
<br>
<table width="100%" cellspacing="0" cellpadding="0"><tbody>
	 <tr align="align">
	 <!-- <td><p class="selection1" id="transport1">  ACTV </p></td> -->
	 <!-- <td><p class="selection1"  id="transport1"> airport </p></td> -->
	 <td width="120"><p class="selection1" id="transport1"><img src="f/trasporti.png" width="120"></p><br></td>
	 <td width="120"><p class="selection1" id="transport1"><img src="f/transfer.png" width="120"></p><br></td>
	 </tr>
	 <tr>
	   <td><a href="#" class="selection" id="transport" onclick='addWallet(12.,"events")'>  12h/18€ </a></td>
	   <td><a href="#" class="selection" id="transport" onclick='addWallet(6.,"events")'>  Bus/6€ </a></td>
	   </tr><tr>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(20.,"events")'> 24h/20€ </a></td>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(11.,"events")'> A-R Bus/11€ </a></td>
	   </tr><tr>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(25.,"events")'> 36h/25€ </a></td>	 
<td><a href="#" class="selection"  id="transport" onclick='addWallet(36.,"events")'> Waterbus/15€ </a></td>
	   </tr><tr>
  <td></td>
  <td><a href="#" class="selection"  id="transport" onclick='addWallet(27.,"events")'> A-R Waterbus/27€</a></td>
	 <!-- <ul id="lateral-wrap"> -->
	 <!-- <li> <a href="#" onclick='addWallet(12.,"events")'>bus/6€</a> </li> -->
	 <!-- <li> <a href="#" onclick='addWallet(24.,"events")'>a/r bus/11€</a></li> -->
	 <!-- <li> <a href="#"  onclick='addWallet(36.,"events")'>vaporetto/15€</a></li> -->
	 <!-- <li> <a href="#"  onclick='addWallet(36.,"events")'>a/r vaporetto/27€</a></li> -->
	 <!-- </ul> -->
	 </td></tr></tbody></table>
	 <p id="nextPage"><a class="button"  id="coupon" href="events.php?sum=0"> events </a></p>
</div>
</div><!-- container -->
<div id="footer">
  <div class="testo1">Total: <b id='boldStuff'>0</b> €</div>
</div>
<script>
	 addWallet(parseFloat(<?php CurrSum(); ?>),"events");
</script>
</body>


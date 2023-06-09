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
</head>
<body>
    <?php
       Intestazione();
       ?>
<div id="container">
<br><br>
	 <br><br>
<div class="selection1" id="event"> 
<select id="PMuseo" name="PMuseo" class="selectClass">
  <option value="" >  Museums </option> 
  <option value="10." type="float">Palazzo Ducale 10€</option>
  <option value="10." type="float">Museo Correr 10€</option>
  <option value="10." type="float">Museo Archeologico Nazional10€</option>
  <option value="10." type="float"> Biblioteca Nazionale Marciana 10€</option>
  <option value="10." type="float">Cà Rezzonico - Museo del 10€</option>
  <option value="10." type="float">Settecento Veneziano 10€</option>
  <option value="10." type="float">Casa di Carlo Goldoni 10€</option>
  <option value="10." type="float">Museo di Palazzo Mocenigo 10€</option>
  <option value="10." type="float">Cà Pesaro  10€</option>
  <option value="10." type="float">Museo del Vetro - Murano 10€</option>
  <option value="10." type="float">Museo del Merletto - Burano 10€</option>
  <option value="10." type="float">Museo di Storia Naturale 10€</option>
</select>
<input id="saveForm" class="selectClass" name="saveForm" class="btTxt submit" type="submit" value="add" onclick='addWallet(parseFloat(PMuseo.value),"coupons");'/>
</div> <!--selector-->
<br><br>
<div class="selection1" id="event"> 
<select id="PChiesa" name="PChiesa" class="selectClass">
  <option value=""> Churches </option>  
  <option value="10." type="float"> Santa Maria del Giglio 10€</option>
  <option value="10." type="float"> Santo Stefano 10€</option>
  <option value="10." type="float"> Santa Maria Formosa 10€</option>
  <option value="10." type="float"> Santa Maria dei Miracoli 10€ </option>
  <option value="10." type="float"> San Giovanni Elemosinario 10€</option>
  <option value="10." type="float"> San Polo 10€</option>
  <option value="10." type="float"> S. M. Gloriosa dei Frari 10€</option>
  <option value="10." type="float"> San Giacomo dall'Orio 10€</option>
  <option value="10." type="float"> San Stae 10€</option>
  <option value="10." type="float"> Sant'Alvise 10€</option>
  <option value="10." type="float"> San Pietro di Castello 10€</option>
  <option value="10." type="float"> Santissimo Redentore 10€</option>
  <option value="10." type="float"> Santa Maria del Rosario 10€</option>
  <option value="10." type="float"> San Sebastiano 10€</option>
  <option value="10." type="float">  San Giobbe 10€</option>
</select>
<input id="saveForm"  class="selectClass" name="saveForm" class="btTxt submit" type="submit" value="add" onclick='addWallet(parseFloat(PChiesa.value),"coupons");'/>
</div> <!--selector-->
<br><br><br>
	 <p id="nextPage"><a class="button"  id="coupon" href="coupons.php?sum=0"> coupons </a></p>
</div><!-- container -->
<div id="footer">
  <div class="testo1">Total: <b id='boldStuff'>0</b> €</div>
</div>
<script>
	 addWallet(parseFloat(<?php CurrSum(); ?>),"coupons");
</script>
</body>


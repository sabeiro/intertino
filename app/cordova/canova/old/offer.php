<!DOCTYPE HTML>
<html>
<head>
    <?php
       include("Intestazioni.php");
WrHeader();
       include("config.inc.php");
       include("SqlFunction.php");
       ?>
<link rel="stylesheet" type="text/css" href="css/coupon.css">
</head>
<?php        Intestazione(); ?>
<body>
<div id="container">
<br><br>
<p class="selection1"  id="transport1">offers so far: <?php echo $_SESSION['WOffer']; ?>  </p>
<div>
<ul class="coupon-list">
  <li class="coupon-element"><p class="element-p-no-sub">Transport 24h</p></li>
  <li class="coupon-element"><p class="element-p-no-sub">Waterbus</p></li>
  <li class="coupon-element"><p class="element-p">Museo Correr Piazza <br/><span class="subtitle">San Marco, 52, 30124 Venezia</span></p></li>
  <li class="coupon-element"><p class="element-p">Hostaria da Fanio <br/><span class="subtitle">Via I° Maggio, 54 </span></p></li>
  
</ul>
</div>
</body>
</html>

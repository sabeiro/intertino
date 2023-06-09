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
<p class="selection1"  id="transport1">total to pay: <?php echo $_SESSION['WSum']; ?>€  </p>
<div id="qrCode2">
	 <input id="qrCode3" class="selectClass" name="saveForm" class="btTxt submit" type="submit" value="accept" onclick='showQr();'/>
</div>
	 <div id="qrCode"> <img  id="qrCode1" src="f/qrCode.jpg" width="150"> </div>
	 <a class="qrButton" id="qrButton1" href="offer.php"> >visualize offer </a>

</body>
</html>

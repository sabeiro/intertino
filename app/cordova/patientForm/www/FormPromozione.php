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
  </head>
  <body  style="background-image: url(images/SfondoLeg.png);" >
    <?php include("Intestazioni.php");
       Intestazione(); ?>
    <?php
       include("MySqlLocalAccess.php");
       include("config.inc.php");
       ?>
    <div id="container" class="ltr">
      <?php
	 $db = mysqli_connect($db_host, $db_user, $db_password);
	 if ($db == FALSE){
	 die ("Errore nella connessione. Verificare i parametri nel file config.inc.php");
	 }
	 mysqli_select_db($db,$db_name);
	 $query = "SELECT nome FROM promozioni";
	 $result = mysqli_query($db,$query);
	 $id = 1;
	 while ($row = mysqli_fetch_array($result)){
	 $id = $id + 1;
	 }
	 $query = "INSERT INTO promozioni (ID,nome,luogo,settore,descrizione,data,dataAl)
		   VALUES 
		   ('$id','$_POST[PNome]','$_POST[PLuogo]','$_POST[PSettore]','$_POST[PDescrizione]','$_POST[PData]','$_POST[PDataAl]');";
	 echo "query:<br>$query<br>";
	 $result = mysqli_query($db,$query);
	 echo "$result\n";
	 if (!$result){
         die('Error:  ' . mysqli_error($db));
	 }
	 echo "1 record added";
	 mysqli_close($db);
	 ?> 
      <br>
      <br>
      <table border="0" align="center" cellpadding="2" cellspacing="2" class="maintable" width="100%" >
		 <tbody>
		 <tr>
		 <td width="60"> <div id="testo1" style="font:18px Verdana, Helvetica, sans-serif;"> <a href="InsEvento.php"> nuovo evento </a> </div></td>
		 </tr>
		 </tbody></table>
    </div><!--container-->
  </body>
</html>

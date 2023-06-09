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
  <script type="text/javascript" src="js/jquery-1.3.2.min.js" ></script>
  <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js" ></script>
  <link rel="stylesheet" href="css/jquery-ui-1.7.2.custom.css" type="text/css" >
  <style type="text/css">
    #accordion {
    width: 50%;
    }
  </style>
  <script type="text/javascript">
    $(function() {
    $(".data:input").datepicker();
    });
  </script>
  <script type="text/javascript">
    function CheckData(form){
    missing = "";
    IfContinue = 1;
    var PEntries = new Array(form.PPullmann.value,
    form.PAddetto.value,form.datepicker.value);
    var PMissing = new Array("pullmann, ","addetto, ","data, ");
    for(i=0;i< PEntries.length;i++){
	       if(PEntries[i] == ""){
	       missing += PMissing[i];
	       IfContinue = 0;
	       }
	       }
	       if(IfContinue){
	       document.getElementById("InsertData").innerHTML = '<p id="nextPage"><a class="button" id="coupon" href="#"> <input id="saveForm" name="saveForm" class="btTxt submit" type="submit" value="inserisci"/> </a></p>';
	       }
else{
	       document.getElementById("CheckData").innerHTML = "manca: " + missing;
}
	       }
	       </script>
</head>
<body>
  <?php
Intestazione();
$dbConn = new AdminSql();   
$dbConn->DbConnect($db_host,$db_user,$db_password,$db_name);   ?>

  <div id="container">
    <br><br>
    <form action="InsPullmann.php" method="post">
      <div class="selection1" id="event"> 
	<?php WrListUfficio($dbConn); ?>
      </div> <!--selector-->
      <div class="selection1" id="event"> 
	<p>
	  <?php echo 'Giorno: <input type="text" id="datepicker" class="data-attivita" name="datepicker" value="' . date('Y-m-d') . '"> ' . "\n"; ?>
	</p>
	<p id="nextPage">
	  <a class="button"  id="coupon" href="#"> <input onclick="CheckData(form)" type="button" value="controlla" > </a></p>
	<p id="CheckData">
	  <script> CheckData(form); </script>
	</p>
	<p id="InsertData">
	  <script> InsertData(form); </script>
	</p>
      </div> <!--selector-->
    </form> 
  </div><!-- container -->
  <div id="footer">
    <div class="testo1">Total: <b id='boldStuff'>0</b> €</div>
  </div>
  <!-- <script> -->
  <!-- 	 addWallet(parseFloat(<?php CurrSum(); ?>),"coupons"); -->
  <!-- </script> -->
</body>
</html>


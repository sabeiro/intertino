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
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="css/Stile.css" type="text/css">
    <link rel="stylesheet" href="css/Map.css" type="text/css">
    <!-- <link rel="stylesheet" href="css/Slider.css" type="text/css"> -->
    <link rel="shortcut icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/frontend.css" type="text/css" media="all">
    <script language="JavaScript" src="js/Gardash.js" type="text/javascript"></script> 
    <!-- <script language="JavaScript" src="js/Map1.js" type="text/javascript"></script> -->
    <!-- <script src="js/OpenLayers.js"></script> -->
    <!-- <script type="text/javascript" src="js/jquery_002.js"></script> -->
    <!-- <script type="text/javascript" src="js/jquery_003.js"></script> -->
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery.ballon.js"></script>
    <!-- <script language="JavaScript" src="js/KotoBa.js" type="text/javascript"></script> -->
    <!-- <script language="JavaScript" src="js/jquery.min.js" type="text/javascript"></script> -->
    <!-- <script type="text/javascript" src="js/jquery-easing-1.js"></script> -->
    <!-- <script type="text/javascript" src="js/jquery-easing-compatibility.js"></script> -->
    <!-- <script src="js/ga.js" async="" type="text/javascript"></script> -->
    <!-- <script src="js/modernizr.js"></script> -->
    <!-- <script src="js/pro.js" async="" type="text/javascript"></script> -->
    <!-- <script src="js/bsa.js" async="" type="text/javascript"></script> -->
    <script type='text/javascript'>
      var interesse = [];
    </script>

  </head>
  <body  style="background-image: url(images/SfondoLeg.png);" onload="initMap()">
    <?php
       include("Intestazioni.php");
       include("MySqlLocalAccess.php");
       include("config.inc.php");
       include("SqlFunction.php");
       Intestazione(); 
       session_start();       
       ?>
    <div id="container">
      <table  align="center"  width="100%"> <tbody>
	  <tr align="center"><td width="300">
	      <div id="textBox" align="center">
		<center><h1> GARDASH </h1></center>
		<div id="testo1">
		Scegli il tuoi interessi, <br> 
		noi ti diciamo dove e quando.
		</div><!-- testo1-->
	      </div><!-- textBox -->
	      <br>
		<div id="attivitaBox">Attività (trascina a destra)<br>
		<table border="0" align="center"  width="100%"> <tbody>
		    <tr><td>	 
		  <ul id="elementi_da_trascinare" ondragstart="drag(event)">
		    <li draggable="true" data-icona="f/LogoMusica.jpg" data-interesse="musica" id="musica">musica</li>
		    <li draggable="true" data-icona="f/LogoVela.png" data-interesse="vela" id="vela" > vela</li>
		    <li draggable="true" data-icona="f/LogoRistorante.png" data-interesse="ristorante"  id="ristorante"> ristorante</li>
		    <li draggable="true" data-icona="f/LogoSpesa.jpg" data-interesse="spesa" id="spesa"> spesa </li>
		  </ul>
	 </td><td>
		  <ul id="elementi_da_trascinare" ondragstart="drag(event)">
		    <li draggable="true" data-icona="f/LogoAgro.jpg" data-interesse="musica">agricoltura</li>
		    <li draggable="true" data-icona="f/LogoBestie.jpg" data-interesse="vela" >allevamento</li>
		    <li draggable="true" data-icona="f/LogoEno.jpg" data-interesse="ristorante" > vino</li>
		    <li draggable="true" data-icona="f/LogoBirra.jpg" data-interesse="spesa"> birra </li>
		  </ul>

	 </tr></tbody></table>
		    <br>Bar:<br>
		  <select id="PSet" name="PSet"> <?  WrAttivita(); ?></select>
		</div><!-- attivitaBox-->
	      <p id="mostra">
		trascino:
		<script>
		  document.getElementById("mostra").innerHTML = "franco";
		</script>
	      </p>
	    </td><td align="center">
	      <div id="dashBox">
		<h1 align="center"> interessi </h1>
		<table border="0" align="center"  width="100%"> <tbody>
		    <tr align="center">
		      <td> <div id="dashItem">
			  <? WrUpdate("musica") ?>
			  <div id="dragBox" ondrop="drop(event)" ondragover="allowDrop(event)" onMouseOver="" onMouseOut="">
			  <img   id="dragIt1" dropzone="copy s:text" draggable="false" src="f/blank.png" ondragenter="inDrop(event)" ondragleave="outDrop(event)" ondragover="onDrop(event)" ondrop="drop(event)" width="100" height="100" onMouseOver="">
			  </div>
			</div> 
		      </td>
		      <td> <div id="dashItem">
			  <? WrUpdate("vela") ?>
			  <div id="dragBox" ondrop="drop(event)" ondragover="allowDrop(event)" onMouseOver="DrawCanvas('')" onMouseOut="">
			  <img   id="dragIt2" dropzone="copy s:text" draggable="false" src="f/blank.png" ondragenter="inDrop(event)" ondragleave="outDrop(event)" ondragover="onDrop(event)" ondrop="drop(event)" width="100" height="100">
			</div>
		      </td>
		      </tr><tr>
		      <td> <div id="dashItem">
			  <? WrUpdate("ristorante") ?>
			  <div id="dragBox" ondrop="drop(event)" ondragover="allowDrop(event)" onMouseOver="DrawCanvas('')" onMouseOut="">
			  <img   id="dragIt3" dropzone="copy s:text" draggable="false" src="f/blank.png" ondragenter="inDrop(event)" ondragleave="outDrop(event)" ondragover="onDrop(event)" ondrop="drop(event)" width="100" height="100">
			  </div>
		      </td>
		      <td> <div id="dashItem"> 
			  <? WrUpdate("spesa") ?>
			  <div id="dragBox" ondrop="drop(event)" ondragover="allowDrop(event)" onMouseOver="" onMouseOut="">
			  <img   id="dragIt4" dropzone="copy s:text" draggable="false" src="f/blank.png" ondragenter="inDrop(event)" ondragleave="outDrop(event)" ondragover="onDrop(event)" ondrop="drop(event)" width="100" height="100" onMouseOver="">
			  </div>
		      </td>
		</td>	  </tr>      </tbody></table>
	      </div><!-- dashBox -->
	    </td><td align="center" width="300">
    <div id="imageBox">
      <h1 align="center"> dove </h1>
      <div id="map" class="smallmap"></div>
      <!-- <img src="f/MappaDash.png" width="400" height="500" align="center"> -->
      <div id="layerBox">
	<canvas id="myCanvas" width="400" height="500"></canvas>
      </div>
    </div>
      </td>  </tr>      </tbody></table>
      <table border="0" align="center"  width="100%"> <tbody>
	  <tr align="center"><td>
      </td>	  </tr>      </tbody></table>
     <p id="mostra1">
       <script> 
	 var dbVar = <?php ArrayInterest("musica"); ?>;
	 document.getElementById("mostra1").innerHTML = dbVar[1][0]; 
       </script>
     </p>


   <script> $(function() { 
     eval(
     $('.sample10-2').balloon({classname:"fumettoBox",position:"null",hideDuration: "fast",
     hideAnimation: function(d) { this.slideUp(d); }})
     ); 
     });
   </script>
   <style>
     #sample10-demo > div { float: left; width: 100px; height: 100px;
     background-color: #ddd; margin: 20px; 
     }
   </style>
   <div id="sample10-demo">
     <div class="sample10-2" title="Slide up at hiding.">10-2</div>
   </div>
   
</div> <!-- container -->

<?php Chiusura(); ?>
</body>
</html>

</body></html>

<html lang="en"><head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" type="text/css" href="css/airvenice.css">

    <script type="text/javascript" src="js/airvenice.js"></script>
    <title>airvenice</title>
    <script type="text/javascript">
</script>
  </head>
  <body>
    <?php
       include("Intestazioni.php");
       include("SqlFunction.php");
       session_start();
       $_SESSION['WSum']=0.;
       ?>
    <div id="swipeBox" ontouchstart="touchStart(event,'swipeBox');" ontouchend="touchEnd(event);" ontouchmove="touchMove(event);" ontouchcancel="touchCancel(event);" style="position:relative;width:100%;height:100%;">
      <div id="container"><!-- start header -->
	<?php Intestazione() ?>
	<div id="central-wrap">
	  <a class="button" id="coupon" href="transport.php">TRANSPORT</a>
	  <a class="button" id="coupon" href="coupon.php">COUPON</a>
	  <a class="button" id="coupon" href="events.php">EVENTS</a>
	</div>
      </div><!-- swipeBox -->

    </div>
    

</body></html>

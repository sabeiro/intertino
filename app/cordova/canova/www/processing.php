<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <link rel="stylesheet" href="css/Stile.css" type="text/css">
    <link rel="shortcut icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/frontend.css" type="text/css" media="all">
    <script src="js/application.js"></script>
    <script src="js/processing-1.4.1.min.js"></script>
  </head>
  <body  style="background-image: url(images/SfondoLeg.png);" >
<div id="container">
    <canvas data-processing-sources="pde/mappa2.pde">
    </canvas>
    <script type="text/processing" data-processing-target="mycanvas">
void setup()
{
  size(200,200);
  background(125);
  fill(255);
  noLoop();
  PFont fontA = loadFont("courier");
  textFont(fontA, 14);  
}

void draw(){  
  text("Hello Web!",20,20);
  println("Hello ErrorLog!");
}
</script>
<canvas id="mycanvas"></canvas>
    </div> <!-- container -->
</body>

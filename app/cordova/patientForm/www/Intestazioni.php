<?php
//error_reporting(E_ERROR | E_PARSE);
//error_reporting(E_ALL ^ E_WARNING); 
error_reporting(0);
/* ini_set('error_reporting', E_ALL); */
/* ini_set('display_errors', '1'); */
function WrHeader(){
  echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">' . "\n";
  echo '<meta name="keywords" content="Venice, tickets, booking, transportation" />' ."\n";
  echo '<meta name="description" content="Integrated system for booking in Venice" />' ."\n";
  echo '<meta name="author" content=""  />' ."\n";
  echo '<meta name="copyright" content=""  />' ."\n";
  echo '<meta name="language" content="EN, English" />' ."\n";
  echo '<meta name="classification" content=""  />' ."\n";
  echo '<meta name="refresh" content=""  />' ."\n";
  echo '<script type="text/javascript" src="js/airvenice.js"></script>' ."\n";
  echo '<title>Canova management</title>' ."\n";
//  echo '<link rel="stylesheet" type="text/css" href="css/airvenice.css">' ."\n";
  echo '<meta id="viewport" name="viewport" content ="width=device-width, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no" />' ."\n";
echo '<link href="http://fonts.googleapis.com/css?family=Roboto+Condensed:400,300" rel="stylesheet" type="text/css">' . "\n";
echo '<link rel="stylesheet" type="text/css" href="css/reg.css">';
echo '<link href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,300italic,400italic,600" rel="stylesheet" type="text/css">'; 
echo '<link href="//netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css" rel="stylesheet">';
include_once("../../../lib/analyticstracking.php");
session_start();
}
function ColR($page) {
     echo "\n" . '<div id="columnR">' . "\n";
     echo '<a href="' . $page . '"> <img src="f/ToRight.png"> </a>' . "\n";
     echo '</div> <!-- columnR -->' . "\n";
}
function ColL($page) {
  echo "\n" . '<div id="columnL">' . "\n";
  echo '<a href="' . $page . '"> <img src="f/ToLeft.png"> </a>' . "\n";
  echo '</div> <!-- columnL -->' . "\n";
}
 function Intestazione() {
echo '<h1>Canova management</h1>';
}
function Chiusura() {

echo '<div class="pagecommand"><hr>';
echo '<a href="index.php" class="button">Home</a>';
if (!isset($_SESSION['login'])){	
echo '<a href="LogIn.php" class="button">LogIn</a>';
}
else{
echo '<a href="admin.php" class="button">Admin</a>';
echo '<a href="LogOut.php" class="button">LogOut</a>';
}

echo '</div>';
}
?>

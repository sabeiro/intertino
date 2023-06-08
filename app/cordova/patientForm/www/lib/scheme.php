<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

include("config.inc.php");
$version="my_0.0.0";
if(isset($_GET['version'])){
    $version = $_GET['version'];
}
$screen="patient";
if(isset($_GET['screen'])){
    $screen = $_GET['screen'];
}

global $db_user, $db_host, $db_password,$db_name;
$db = mysqli_connect($db_host, $db_user, $db_password);
if ($db == FALSE){die ("Connection error");}
mysqli_select_db($db,$db_name);
$query = "SELECT * FROM `scheme` WHERE version='$version' AND screen='$screen'";
#echo "query:<br>$query:<br>\n";
$result = mysqli_query($db,$query);
$row = mysqli_fetch_array($result);
echo $row['template'];
$json_res = json_encode($result, JSON_PRETTY_PRINT);
#echo "$json_res\n";
if(!$result){ die('Error:  ' . mysqli_error($db)); }
mysqli_close($db);
?>

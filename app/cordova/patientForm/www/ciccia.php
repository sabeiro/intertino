<?php
ini_set('error_reporting', E_ALL);
ini_set('display_errors', '1');
//header("content-type: application/json"); 
//header("content-type: Access-Control-Allow-Origin: *");
//header("content-type: Access-Control-Allow-Methods: GET");

require_once('lib/DbIo.php');
require_once('lib/DbFormat.php');
$DbIo = new DbIo();
$DbF = new DbFormat();
$DbIo->init();
$query = "SELECT * FROM wa_pulito;";
$res = $DbIo->execQuery($query);
while($row = mysql_fetch_row($res)){
    echo $row[0];
}

?>
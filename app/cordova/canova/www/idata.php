<?php
ini_set('error_reporting', E_ALL);
ini_set('display_errors', '1');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Max-Age: 1000');

require_once('lib/DbIo.php');
require_once('lib/DbFormat.php');

$DbIo = new DbIo();
$DbF = new DbFormat();
$DbIo->init();
if( $_REQUEST["query"] ){
    $query = stripslashes($_REQUEST['query']);
    $res = $DbIo->execQuery($query);
    //echo 'one record inserted ' . $query . $res . ';';
}
else{
    echo "query not defined\n";
}
?>
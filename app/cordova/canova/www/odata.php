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
$addetto = "";
if(isset($_GET['addetto'])){
    $addetto = $_GET['addetto'];
}
$pullman = "";
if(isset($_GET['pullman'])){
    $pullman = $_GET['pullman'];
}
$tab = "";
if(isset($_GET['tab'])){
    $tab = $_GET['tab'];
}
$manutenzione = "";
if(isset($_GET['manutenzione'])){
    $manutenzione = $_GET['manutenzione'];
}
$pulizia = "";
if(isset($_GET['pulizia'])){
    $pulizia = $_GET['pulizia'];
}
$date = "";
if(isset($_GET['date'])){
    $date = $_GET['date'];
}
$id = "";
if(isset($_GET['id'])){
    $id = $_GET['id'];
}
$callback = "";
if(isset($_GET['callback']) && $_GET['callback']){
    $callback = $_GET['callback'];
}
$query = "SELECT * FROM wa_pulito ";
$where = "";
$first = 1;
if($addetto != ""){
    if($first){
	$where .= "WHERE wa_pulito.addetto='$addetto'";
	$first = 0;
    }
    else{
	$where .= "AND wa_pulito.addetto='$addetto'";
    }
}
if($pullman != ""){
    if($first){
	$where .= "WHERE wa_pulito.pullman='$pullman'";
	$first = 0;
    }
    else{
	$where .= "AND wa_pulito.pullman='$pullman'";
    }
}
if($pulizia != ""){
    if($first){
	$where .= "WHERE wa_pulito.pulizia='$pulizia'";
	$first = 0;
    }
    else{
	$where .= "AND wa_pulito.pulizia='$pulizia'";
    }
}
if(isset($_GET['file'])){
    $DbIo->WrFile($query,"FormResume.csv");
    //$data_arr = $DbIo->readDb($query . $where . ";");
    //$DbF->PrintStorico($data_arr);
    exit;
}
else if(isset($_GET['storico'])){
    $data_arr = $DbIo->readDb($query . $where . ";");
    if($callback){
	echo $callback.'(';
	$DbF->PrintStoricop($data_arr);
	echo ')';
    }
    else{
	$DbF->PrintStorico($data_arr);
    }
}
else if(isset($_GET['login'])){
    $user = "";
    if(isset($_GET['user'])){
	$user = $_GET['user'];
    }
    $password = "";
    if(isset($_GET['pass'])){
	$password = $_GET['pass'];
    }
    $password = sha1($password);
    $query = "SELECT id_login FROM login WHERE username_login = '$user' AND password_login = '$password'";
    $res = $DbIo->execQuery($query);
    $auth = mysqli_fetch_row($res);
    if($auth[0]!=0){
    	echo $callback . '([{"user":"'. $user .'","login":"'.$auth[0].'"}])';
    }else{
    	echo $callback . '([{"user":"'. $user .'","login":"0"}])';
    }
}
else if(isset($_GET['query'])){
    $query = $_GET['query'];
    $DbIo->execQuery($query);
    echo 'one record inserted ' . $query;
}
else if(isset($_GET['ins'])){
    $query = "INSERT INTO wa_pulito (ID,addetto,pullman,pulizia,data,manutenzione) VALUES ('" . $id . "','" . $addetto . "','" . $pullman . "','" . $pulizia . "','" . $date . "','" . $manutenzione . "');";
    $DbIo->execQuery($query);
    echo 'one record inserted ' . $query;
}
else if($callback){
	static $input_arr = array();
	echo $callback.'(';
	$where = "";
	$query = "SELECT * FROM wa_addetto ";
	$data_arr = $DbIo->readDb($query . $where . ";");
	foreach($data_arr as $line){
	    $format = array(
		"type"=>"addetto",
		"id"=>$line[0],
		"name"=>$line[1],
		);
	    array_push($input_arr,$format);
	}
	$query = "SELECT * FROM wa_pullman ";
	$data_arr = $DbIo->readDb($query . $where . ";");
	foreach($data_arr as $line){
	    $format = array(
		"type"=>"pullman",
		"id"=>$line[0],
		"name"=>$line[1],
		);
	    array_push($input_arr,$format);
	}
	$query = "SELECT * FROM wa_pulizia ";
	$data_arr = $DbIo->readDb($query . $where . ";");
	foreach($data_arr as $line){
	    $format = array(
		"type"=>"pulizia",
		"id"=>$line[0],
		"name"=>$line[1],
		);
	    array_push($input_arr,$format);
	}
	$query = "SELECT * FROM wa_pulito ";
	$data_arr = $DbIo->readDb($query . $where . ";");
	$id = 0;
	foreach($data_arr as $line){
	    if($id < $line[0]){
		$id = $line[0];
	    }
	}
	$id = $id + 1;
	$format = array(
	    "type"=>"id",
	    "last_id"=>$id,
	    );
	array_push($input_arr,$format);
	echo json_encode(array_values($input_arr));
	echo ')';
}
else{
    $where = "";
    $query = "SELECT * FROM wa_addetto ";
    $data_arr = $DbIo->readDb($query . $where . ";");
    $DbF->PrintJSon("addetto",$data_arr);
    echo ",";
    $query = "SELECT * FROM wa_pullman ";
    $data_arr = $DbIo->readDb($query . $where . ";");
    $DbF->PrintJSon("pullman",$data_arr);
    echo ",";
    $query = "SELECT * FROM wa_pulizia ";
    $data_arr = $DbIo->readDb($query . $where . ";");
    $DbF->PrintJSon("pulizia",$data_arr);
    echo ",";
    $query = "SELECT * FROM wa_pulito ";
    $data_arr = $DbIo->readDb($query . $where . ";");
    $DbF->LastId($data_arr);
}

?>

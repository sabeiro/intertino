<?php
ini_set('error_reporting', E_ALL);
ini_set('display_errors', '1');

class DbFormat{
    public function PrintJson($name,$data_arr){
	$addetto_arr = array();
	foreach($data_arr as $line){
	    $format = array(
		"id"=>$line[0],
		"name"=>$line[1],
		);
	    array_push($addetto_arr,$format);
	    //$addetto_arr += $format;
	}
	echo '"' . $name . '":' . json_encode(array_values($addetto_arr));
    }
    public function PrintJsonp($name,$data_arr,$input_arr){
	foreach($data_arr as $line){
	    $format = array(
		"type"=>$name,
		"id"=>$line[0],
		"name"=>$line[1],
		);
	    array_push($input_arr,$format);
	}
    }
    public function PrintStorico($data_arr){
	$storico_arr = array();
	foreach($data_arr as $line){
	    $format = array(
		"id"=>$line[0],
		"addetto"=>$line[1],
		"pullman"=>$line[2],
		"pulizia"=>$line[3],
		"data"=>$line[4],
		"manutenzione"=>$line[5],
		);
	    array_push($storico_arr,$format);
	}
	echo '{"storico":' . json_encode(array_values($storico_arr)) . "}";
    }
    public function PrintStoricop($data_arr){
	$storico_arr = array();
	foreach($data_arr as $line){
	    $format = array(
		"id"=>$line[0],
		"addetto"=>$line[1],
		"pullman"=>$line[2],
		"pulizia"=>$line[3],
		"data"=>$line[4],
		"manutenzione"=>$line[5],
		);
	    array_push($storico_arr,$format);
	}
	echo json_encode(array_values($storico_arr));
    }
    public function LastId($data_arr){
	$id = 0;
	foreach($data_arr as $line){
	    if($id < $line[0]){
		$id = $line[0];
	    }
	}
	$id = $id + 1;	
	echo  '"id":' . $id;
    }
    public function LastIdp($data_arr,$input_arr){
	$id = 0;
	foreach($data_arr as $line){
	    if($id < $line[0]){
		$id = $line[0];
	    }
	}
	$id = $id + 1;
	$format = array(
	    "type"=>"id",
	    "last_id"=>$line[0],
	    );
	array_push($input_arr,$format);
    }
}
?>
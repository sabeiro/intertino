<?php
ini_set('error_reporting', E_ALL);
ini_set('display_errors', '1');

class DbIo
{
    private $dbserver = "localhost";
    /* private $dbuser = "e4busine_canova"; */
    /* private $dbpass = "example5041"; */
    /* private $dbname = "e4busine_canova"; */
    /* private $dbuser = "nuovicli_canova"; */
    /* private $dbpass = "B2Gppp4XFPC@"; */
    /* private $dbname = "nuovicli_canova"; */
    private $dbuser = "kotoba";
    private $dbpass = "t61kvg90";
    private $dbname = "kotoba";
    
    private $conn;
    private $config;
    public function init(){
    }

    function openDbConn(){
	$this->conn = mysql_connect($this->dbserver, $this->dbuser, $this->dbpass)
	    or die("Connessione non riuscita: " . mysql_error());
	$db_selected = mysql_select_db($this->dbname, $this->conn);
	if (!$db_selected)
	    die ('Can\'t use database : ' . mysql_error());

	// imposta la codifica dei caratteri
	mysql_query("SET CHARACTER SET utf8");
    }
    function closeDbConn(){
	mysql_close($this->conn);
    }
    public function readDb($query){
	$this->openDbConn();
	$res = mysql_query($query) or die (mysql_error());
	$db_arr = array();
	while($row = mysql_fetch_row($res)){
	    array_push($db_arr,$row);
	}
	$this->closeDbConn();
	return $db_arr;
    }
    public function lastId($tab){
	$this->openDbConn();
	$query = "SELECT id FROM " . $tab . ";";
	$res = mysql_query($query) or die (mysql_error());
	$id = 0;
	while($row = mysql_fetch_row($res)){
	    $id = $row[0];
	}
	$this->closeDbConn();
	return intval($id)+1;
    }
    public function execQuery($query){
	$this->openDbConn();
	$res = mysql_query($query) or die("Query non valida\n- $query -\n: " . mysql_error());
	$this->closeDbConn();
	return $res;
    }
    function WrFile($query,$fName){
	$result = $this->execQuery($query);
	$fh = fopen($fName, 'w');
	if ($fh == FALSE){
	    die ("Cannot write/create the file $myFile .");
	}
	$NCol = 0;
	$string = "";
	while ($NCol < mysql_num_fields($result)){
	    $meta = mysql_fetch_field($result, $NCol);
	    $string .= "\"" . $meta->name . "\", ";
	    $NCol = $NCol + 1;
	}
	$string .= "\"\"\n";
	fwrite($fh,$string);
	while ($row = mysql_fetch_array($result)){
	    //  $NCol = count($row);
	    $string = "";
	    $i = 0;
	    while($i < $NCol){
		$string .= "\"$row[$i]\", ";
		$i += 1;
	    }
	    $string .= "\"\"\n";
	    fwrite($fh,$string);
	}
	fclose($fh);
    }

}

?>
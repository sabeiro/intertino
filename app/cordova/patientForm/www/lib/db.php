<?php
$pdata = json_decode(file_get_contents('php://input'), true);
include("config.inc.php");
global $db_user, $db_host, $db_password,$db_name;
$db = mysqli_connect($db_host, $db_user, $db_password);
if ($db == FALSE){
    die ("Errore nella connessione. Verificare i parametri nel file config.inc.php");
}
mysqli_select_db($db,$db_name);
$date = date("Y-m-d H:i:s");
$query = "INSERT INTO record (date,record) VALUES ('$date'," . '\'' . json_encode($pdata) . '\')';
//$esc_desc = addslashes($description1);
echo "query:<br>$query:<br>";
if (TRUE){
    var_dump($_POST);
    foreach($_POST as $p) {
	echo $p, ' ';
    }
    print_r($pdata);
    echo mysqli_real_escape_string($pdata['time_call']);
    echo $query;
}
$result = mysqli_query($db,$query);
//  echo "$result\n";
if (!$result){
    die('Error:  ' . mysqli_error($db));
}
//  echo "one comment added";
mysqli_close($cdb);

?>

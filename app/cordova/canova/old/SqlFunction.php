<?php
include("AdminSql.php");
// funzione per la formattazione della data
/* public function format_data($d)  { */
/*   $vet = explode("-", $d); *//*   // converte la data in timestamp *//*   //  $vet = strtotime($d); */
/*   // converte il timestamp della variabile $vet */
/*   // in data formattata */
/*   //$df = strftime('%d-%m-%Y', $vet); */
/*   return $df; */
/* } */
function Priv(){ 
  session_start();
  if (!isset($_SESSION['login'])){
    header("Location: LogIn.php");
  }
}
function LogInForm($dbConn){
  echo '<form action="InsLogIn.php" method="POST">' . "\n";
  echo '<ul style="list-style-type: none;">' . "\n";
  echo '<li>utente:<input name="username" type="text" class="comment" size="10"></li>' . "\n";
  echo '<li>password:<input  class="comment" name="password" type="password" size="10"></li>' . "\n";
  echo '<input name="submit" type="submit" value="Login"></form></li></ul>' . "\n";
}
function LogIn($dbConn){
  echo $_POST['username'] . $_POST['password']. $_POST['submit'];
  if(isset($_POST['submit']) && (trim($_POST['submit']) == "Login")){
    // controllo sui parametri di autenticazione inviati
    if( !isset($_POST['username']) || $_POST['username']=="" ){
      echo "username missing.\n";
    }
    if( !isset($_POST['password']) || $_POST['password'] ==""){
      echo "password missing.\n";
    }
    else{
      // validazione dei parametri tramite filtro per le stringhe
      $username = trim(filter_var($_POST['username'], FILTER_SANITIZE_STRING));
      $password = trim(filter_var($_POST['password'], FILTER_SANITIZE_STRING));
      $password = sha1($password);
      // interrogazione della tabella
      $query = "SELECT id_login FROM login WHERE username_login = '$username' AND password_login = '$password'";
      echo "$query";
      $auth = $dbConn->DbQuery($query);
      // controllo sul risultato dell'interrogazione
      if(mysql_num_rows($auth)==0){
	// reindirizzamento alla homepage in caso di insuccesso
	header("Location: index.php");
      }else{
	echo "va";
	// chiamata alla funzione per l'estrazione dei dati
	$res =  $dbConn->DbFetch($auth);
	// creazione del valore di sessione
	$_SESSION['login'] = $res-> id_login;
	echo $_SESSION['login'];
	// disconnessione da MySQL
	$dbConn->DbDisc();
	// reindirizzamento alla pagina di amministrazione in caso di successo
	header("Location: index.php");
      }
    }
  }else{
  }
}
function WrList($dbConn){
  $query = "SELECT * FROM wa_addetto;";
  $result = $dbConn->DbQuery($query);
  echo '<select id="PAddetto" name="PAddetto" class="selectClass" required/>';
  echo '<option value="" > addetto </option> ' . "\n";
  while ($row = mysql_fetch_array($result)){
    echo '<option value="'. $row[1] .'" >' .  $row[1] . '</option> ';
  }
  echo '</select><br>';
  $query = "SELECT * FROM wa_pullmann;";
  $result = $dbConn->DbQuery($query);
  echo '<select id="PPullmann" name="PPullmann" class="selectClass" required/>';
  echo '<option value="" > pullmann </option> ' . "\n";
  while ($row = mysql_fetch_array($result)){
    echo '<option value="'. $row[1] .'" >' .  $row[1] . '</option> ' . "\n";
  }
  echo '</select><br>' . "\n";
  echo 'manutenzione: <input name="PManutenzione" type="checkbox" value="1"/> <br>' . "\n";
  $query = "SELECT * FROM wa_pulizia;";
  $result = $dbConn->DbQuery($query);
  echo '<select id="PPulizia" name="PPulizia" class="selectClass" required/>';
  echo '<option value="" > pulizia </option> ' . "\n";
  while ($row = mysql_fetch_array($result)){
    echo '<option value="'. $row[1] .'" >' .  $row[1] . '</option> ' . "\n";
  }
  echo '</select><br>' . "\n";
}
function InsRecord($dbConn,$addetto,$pullmann,$pulizia,$data,$manutenzione){
  $query = "SELECT addetto, pullmann FROM wa_pulito;";
  $result = $dbConn->DbQuery($query);
  $id = 1;
  while ($row = mysql_fetch_array($result)){
    $id = $id + 1;
  }
  $query = "INSERT INTO wa_pulito (ID,addetto,pullmann,pulizia,data,manutenzione) VALUES ('$id','$addetto','$pullmann','$pulizia','$data','$manutenzione');";
  $result = $dbConn->DbQuery($query);
  //echo "query:<br>$query:<br>";
  $result = mysql_query($query, $db);
  //echo "$result\n";
  //echo "1 record added";
  echo "inserito: <br> $addetto pulì il $pullmann il $data, manutenzione $manutenzione <br> \n";
}
function WrSummary($dbConn,$addetto,$pullmann){
  $query = "SELECT addetto FROM wa_addetto";
  $result = $dbConn->DbQuery($query);
  echo '<select name="Name" value="">' . "\n";
  echo "<option value=''> addetto tutti</option>\n";
  while ($row = mysql_fetch_array($result)){
    echo "<option value='$row[0]'> $row[0] </option>\n";
  }
  echo '</select><br>' . "\n";
  $query = "SELECT pullmann FROM wa_pullmann";
  $result = $dbConn->DbQuery($query);
  echo '<select name="Pullmann" value="">' . "\n";
  echo "<option value=''> pullmann tutti</option>\n";
  while ($row = mysql_fetch_array($result)){
    echo "<option value='$row[0]'> $row[0] </option>\n";
  }
  echo '</select>' . "\n";
  echo '<input type="submit" name="Apply" value="trova">' . "\n";
  echo '</form><br>' . "\n";
  echo '<a class="button" id="coupon" href="FormResume.csv"> download .csv (exel)</a> <br>';
  $query = "SELECT * FROM wa_pulito ";
  if($addetto != "" && $pullmann != ""){ 
    $query .= "WHERE wa_pulito.addetto='$addetto' AND wa_pulito.pullmann='$pullmann'";
  }
  else if($addetto != ""){ 
    $query .= "WHERE wa_pulito.addetto='$addetto'";
  }
  else if($pullmann != ""){ 
    $query .= "WHERE wa_pulito.pullmann='$pullmann'";
  }
  $query .= ";";
  //echo $query . "\n";
  $result = $dbConn->DbQuery($query);
  echo '<ul class="coupon-list">';
  while ($riga = mysql_fetch_row($result)){
    echo '<li class="coupon-element"><p class="element-p-no-sub">';
    echo "$riga[1] $riga[2]";
    if($riga[5] == 1){
	echo "*";
    }
    echo " il $riga[4] $riga[3]";
    echo "</p></li>";
  }
  echo "</ul>";
  //  $query = "SELECT * FROM wa_pulito";
  $result = $dbConn->DbQuery($query);
  $myFile = "FormResume.csv";
  $fh = fopen($myFile, 'w');
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
  /* $map = $_POST['code']; */
  /* $map = preg_replace("/,\\s*}/i", "}", $map); */
  /* $map = str_replace("{", "[", $map); */
  /* $map = str_replace("}", "]", $map); */
  /* $map = json_decode('[' . $map . ']'); */
}
function WrProfile($dbConn,$col,$table){
  $query = "SELECT $col FROM $table";
  $result = $dbConn->DbQuery($query);
  echo '<select name="Name" value="">' . "\n";
  echo "<option value=''> $col </option>\n";
  $id2 = 1;
  while ($row = mysql_fetch_array($result)){
    echo "<option value='$row[0]'> $row[0] </option>\n";
    $id2 += 1;
  }
  echo '</select>' . "\n";
  echo '<input type="submit" name="Apply" value="trova"><br>' . "\n";
  echo '</form><br>' . "\n";
  $addetto = $_GET['Name'];
  $query = "SELECT * FROM $table WHERE $table.$col='$addetto';" . "\n";
  //echo $query . "\n";
  $result = $dbConn->DbQuery($query);
  $row = mysql_fetch_array($result);
  $id = $row[0];
  echo '<form action="EditData.php?table=' . $table .'&id=' . $id .'&col=' . $col .'" method="POST">';
  echo '<input type="text" name="username" id="username" value="' . $addetto . '"/><br>';
  echo '<input name="submit" type="submit" value="cambia">' . "\n";
  echo '<input name="submit" type="submit" value="cancella">' . "\n";
  echo '</form>' . "\n";
  echo '<form action="NewData.php?table='. $table . '&id='. $id2 .'" method="POST">' . "\n";
  echo '<input type="text" name="username" id="username" placeholder="'. $col . '" required/><br>' . "\n";
  echo '<input name="submit" type="submit" value="aggiungi">' . "\n";
  echo '</form>' . "\n";
}
function EditData($dbConn,$table,$id,$col,$newval){
  echo $_POST['username'] .  $_POST['submit'];
  if(isset($_POST['submit']) && (trim($_POST['submit']) == "cambia")){
    $query = "UPDATE $table SET $col = '$newval' WHERE $table.id = '$id';";
  }
  else if(isset($_POST['submit']) && (trim($_POST['submit']) == "cancella")){
    $query = "DELETE FROM $table WHERE $table.id = '$id';";
  }
  echo $query;
  $result = $dbConn->DbQuery($query);
}
function NewData($dbConn,$table,$id,$col,$newval){
  echo $_POST['username'] .  $_POST['submit'];
  $query = "INSERT INTO `$table` (`id`, `$col`) VALUES ('$id', '$newval')";
  echo $query;
  $result = $dbConn->DbQuery($query);
}

?>

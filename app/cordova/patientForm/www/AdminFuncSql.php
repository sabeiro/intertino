<?php
include("config.inc.php");
class AdminSql{
  // controllo sulle connessioni attive
  private $attiva = false;
  private $db = false;
  // funzione per la connessione a MySQL
  public function DbConnect($db_host,$db_user,$db_password,$db_name){
//echo $db_host . "  " . $db_user . " " . $db_password . " " . $db_name;
    if(!$this->attiva){
      // connecting to db
      $this->db = mysqli_connect($db_host, $db_user, $db_password);
      if ($this->db == FALSE){
      	die ("Errore nella connessione. Verificare i parametri nel file config.inc.php");
      	/* die (mysqli_error()); */
      }
      mysqli_select_db($this->db,$db_name) or die (mysqli_error());
    }
    else {
      return true;
    }
  }
  // funzione per la chiusura della connessione
  public function DbDisc(){
    if($this->attiva){
      if(mysqli_close()){
  	$this->attiva = false;
  	return true;
      }
      else{
  	return false;
      }
    }
  }
  //funzione per l'esecuzione delle query
  public function DbQuery($query){
    if(isset($this->attiva)){
      $sql = mysqli_query($this->db,$query) or die (mysqli_error($this->db));
      return $sql;
    }
    else{
      return false;
    }
  }
  //funzione per l'inserimento dei dati in tabella
  public function DbInsert($t,$v,$r = null)
  {
    if(isset($this->attiva))
      {
  	$istruzione = 'INSERT INTO '.$t;
  	if($r != null)
  	  {
  	    $istruzione .= ' ('.$r.')';
  	  }
 
  	for($i = 0; $i < count($v); $i++)
  	  {
  	    if(is_string($v[$i]))
  	      $v[$i] = '"'.$v[$i].'"';
  	  }
  	$v = implode(',',$v);
  	$istruzione .= ' VALUES ('.$v.')';
 
  	$query = mysqli_query($istruzione) or die (mysqli_error($this->db));
 
      }else{
      return false;
    }
  }
  // funzione per l'estrazione dei record
  public function DbFetch($risultato){
    if(isset($this->attiva))
      {
  	$r = mysqli_fetch_object($risultato);
  	return $r;
      }else{
      return false;
    }
  }
  // funzione per la creazione di anteprime dei testi
  public function DbPreview($post, $offset, $collegamento) {
    return (count($anteprima = explode(" ", $post)) > $offset) ? implode(" ", array_slice($anteprima, 0, $offset)) . $collegamento : $post;
  }
  // funzione per la formattazione della data
  public function format_data($d)
  {
    $vet = explode("-", $d);
    $df = $vet[2]."-".$vet[1]."-".$vet[0];
    // converte la data in timestamp
    //  $vet = strtotime($d);
    // converte il timestamp della variabile $vet
    // in data formattata
    //$df = strftime('%d-%m-%Y', $vet);
    return $df;
  }
}
?>


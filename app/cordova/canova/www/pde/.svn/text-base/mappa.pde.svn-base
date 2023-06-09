  int sfondo = 40;
  
  void setup() {
  size(250, 250);  // impostiamo il Canvas a 250px per 250px
  frameRate(20);   // e a 20 il numero di fotogrammi al secondo
  strokeWeight(2); // impostiamo a 2px la dimensione della linea di contorno degli oggetti
  stroke(255);     // impostiamo a bianco il colore della linea
  }
  void draw() {
  sfondo++;        // con queste due righe impostiamo il ciclo per il colore di sfondo
  if(sfondo > 254) sfondo = 0;
  
  background(0);   // ricopriamo l'intero Canvas di pixel neri
  fill(sfondo);    // impostiamo a 'sfondo' il colore di riempimento
  rect(10, 10, 230, 230); // disegnamo un rettangolo con coordinate 10, 10 e dimensione 230x230px
  }

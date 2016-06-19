String typed = "";
String word = "";
float length_word = 0;


void setup() {
  size(500, 700);
}

void draw() {
  background(255);
  //fill(0);
  //text(typed, 50, 50);
  int x = 20;
  int y = 20;
  for (int i = 0; i < typed.length(); i++) {
    //char c = typed.charAt(i);
    fill(0);
    text(typed.charAt(i), x, y);
    x += textWidth(typed.charAt(i));
  }

  for (int j = 0; j < word.length(); j++) {
    //char c = typed.charAt(i);
    //fill(0);
    //text(typed.charAt(i), x, y);
    char c = word.charAt(j);
    length_word += textWidth(c);
  }

  if (x + length_word > (width-20)) {
    x = 20;
    y += 20;
  }
}


void keyPressed() {
  typed += key;
  word += key;
  if (key == ' ') {
    word = "";
  }
}
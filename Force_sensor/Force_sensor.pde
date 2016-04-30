import processing.serial.*;

PShape s;
Serial port;
float value;

void setup() {
  size(1200, 800);
  frameRate(10);
  port = new Serial(this, Serial.list()[4], 9600);
}

void draw() {
  background(0);
  translate(400, 100);
  s = loadShape("a.svg");
  editCharacter(s);
  shape(s);
}

void editCharacter(PShape s) {

  s.disableStyle();

  for (int i = 0; i < s.getVertexCount(); i++) {
    PVector v = s.getVertex(i);
      if (v.y < 50){
      v.x = v.x * mouseX/100;
      } else {
      v.x = v.x * mouseX/100;
      }

    s.setVertex(i, v.x, v.y);
    noFill();
    stroke(255);
    strokeCap(SQUARE);
    
    if (0 < port.available()){
    value = port.read();
    println(value);
    float fontStroke = map(value, 0, 255, 2, 60);
    strokeWeight(fontStroke);
    }
  }

  if (s.getChildCount() > 0) {
    for (int i = 0; i < s.getChildCount(); i++) {
      editCharacter(s.getChild(i));
    }
  }
}
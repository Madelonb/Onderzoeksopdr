float x = 100;
float y = 100;
float xspeed = 1;
float yspeed = 0;

void setup() {
  size(400, 600);
}

void draw() {
  background(255);


  rect(150, 250, x, y);

  x = x + xspeed;
  y = y + yspeed;

  if (x > 200) {
    x = 200;
    xspeed = 0;
    yspeed = 1;
  }
  if (y > 200) {
    y = 200;
    yspeed = 0;
    xspeed = -1;
  }
  if (x < 100) {
    x = 100;
    xspeed = 0;
    yspeed = -1;
  }
  if (y < 100) {
    y = 100;
    yspeed = 0;
    xspeed = 1;
  }
  println(x);
}
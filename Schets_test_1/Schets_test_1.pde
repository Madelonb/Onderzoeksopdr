void setup()  {
  size(400, 600);  
}

void draw() {
  background(255);
  
  float min_x, max_x, min_y, max_y;
  
  int x_steps = 20;
  int y_steps = 20;
  
  for (int y = 0; y < x_steps; y++) {
    for (int x = 0; x < y_steps; x++) {
      min_x = (width-(x_steps*10))/2;
      max_x = width-min_x;
      min_y = (height-(y_steps*10))/2;
      max_y = height-min_y;
      float px = map(x, 0, 20, min_x, max_x);
      float py = map(y, 0, 20, min_y, max_y);
      stroke(0);
      ellipse(px, py, 10, 10);
    }
  }
    
}
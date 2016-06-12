void setup()  {
  size(400, 600);  
}

void draw() {
  background(255);
  
  float min_x, max_x, min_y, max_y;
  
  int x_steps = 20;
  int y_steps = 20;
  
  min_x = MAX_FLOAT;
  max_x = MIN_FLOAT;
  min_y = MAX_FLOAT;
  max_y = MIN_FLOAT;
  
  for (int y = 0; y < x_steps; y++) {
    for (int x = 0; x < y_steps; x++) {
      float px = map(x, 0, x_steps-1, 0, width);
      float py = map(y, 0, y_steps-1, 0, height);
      if (px < min_x){
       min_x = px;
      }
      if (py < min_y){
       min_y = py; 
      }
      if (px > max_x){
       max_x = px; 
      }
      if (py > max_y){
       max_y = py; 
      }    
      stroke(0);
      ellipse(px, py, 10, 10);
    }
  }

println("min_x "+min_x);
println("max_x "+max_x);
println("min_y "+min_y);
println("max_y "+max_y);
}
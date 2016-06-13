//import blobDetection.*;
import fontastic.*;
import processing.serial.*;
import processing.pdf.*;
import com.github.lemmingswalker.*;
import com.hamoid.*;

VideoExport videoExport;
boolean recording = false;

final static boolean USE_ARDUINO = false;
final boolean DEBUG = true;
final boolean BACKGROUND_COLOR = false;
final boolean ANIMATE_SHAPE = false;
boolean simulate_bpm = false;
boolean show_shapeframe = false;
float scale = 0.015;

float plot_x1, plot_y1, plot_x2, plot_y2;


boolean record; 

final int MAX_SIZE = 2048;
Serial port;


char[] allowed_chars = {' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ',', '!', '.', '?', '\n'};

int index = -1;
char[] typed_chars = new char[MAX_SIZE];
PShape[] modified_shapes = new PShape[MAX_SIZE];
float[][] xy_positions = new float[MAX_SIZE][2];


float[] values_pressure_sensor = new float [MAX_SIZE];
float[] values_type_time = new float [MAX_SIZE];
float[] temperatures = new float [MAX_SIZE];
float[] kernings = new float [MAX_SIZE];
float min_temperature = 25;
float max_temperature = 35;

float charWidth;

float cursor_x = 50;
float cursor_y = 50;
float cursor_start_x = 50;
float cursor_start_y = 50;

Fontastic f;
//BlobDetection theBlobDetection;
PShape current_modified_shape;
PGraphics pg_blob;
PFont basic;


int time_diff;
int last_millis;
int timer = millis();

float key_timediff_map;
float kerning = 0.05;
//float spacing = 900 * scale;
float leading = 0.2;

//Arduino

float bpm = 50;       // HOLDS HEART RATE VALUE FROM ARDUINO
int portFail = 1;
int readFail = 1;
float temp = 30;
int portNumber = 1;
int lf = 10;      // ASCII linefeed 
float force = 10;
float fontWeight;

float bpmSpeed = 1;
float tempSpeed = 0;


float base_line = 0.7462;

float draw_shape_scale = 100;

String debug_str;


void setup() {
  size(500, 700);
  frameRate(30);
  noCursor();
  plot_x1 = 50;
  plot_y1 = 50;
  plot_x2 = width-plot_x1;
  plot_y2 = height-plot_y1;
  basic = createFont("FaktPro-Normal.ttf", 12);
  //noCursor();

  videoExport = new VideoExport(this, "interactive.mp4");



  //theBlobDetection = new BlobDetection(1000, 2000);
  pg_blob = createGraphics(650, 850);

  if (USE_ARDUINO) {
    println(Serial.list());    // print a list of available serial ports
    // choose the number between the [] that is connected to the Arduino
    port = new Serial(this, Serial.list()[4], 115200    );  // make sure Arduino is talking serial at this baud rate
    port.clear();            // flush buffer
    port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
    portFail = 0;
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

void draw() {
  
  debug_str = "";


  if (simulate_bpm) {
    if (millis() > timer + 1000) {

      boolean bpmplus = true;
      boolean bpmmin = false;

      if (bpm > 90) {
        bpmplus = false;
        bpmmin = true;
      } 

      if (bpmmin) {
        bpm = (constrain(bpm + random(-1.5, 1), 60, 120));
      }

      if (bpmplus) {
        bpm = (constrain(bpm + random(0, 1.5), 60, 120));
      }
      timer = millis();
    }
  } else if (ANIMATE_SHAPE) {

    bpm = bpm + bpmSpeed;
    temp = temp + tempSpeed;

    if (bpm > 120) {
      bpm = 120;
      bpmSpeed = 0;
      tempSpeed = -0.2;
    }
    if (temp < 25) {
      temp = 25;
      tempSpeed = 0;
      bpmSpeed = -1;
    }
    if (bpm < 50) {
      bpm = 50;
      bpmSpeed = 0;
      tempSpeed = 0.2;
    }
    if (temp > 30) {
      temp = 30;
      tempSpeed = 0;
      bpmSpeed = 1;
      force += 50;
    }
  } else if (!USE_ARDUINO) {
    temp = map(constrain(mouseX, 0, width), 0, width, 25, 35);
    bpm = map(constrain(mouseY, 100, 400), 100, 400, 50, 120);
    // force
  } 





  int X = 0;
  int Y = 1;

  if (record) {
    beginRecord(PDF, "frame-####.pdf");
  }

  pushStyle();
  colorMode(HSB, 360, 100, 100);

  if (BACKGROUND_COLOR) {

    //color a1, a2;
    //float h1, h2;
    //h1 = map(temp, 25, 35, 260, 359);
    //h2 = map(temp, 25, 35, 150, 250);

    //a1 = color(h1, height, height);
    //a2 = color(h2, height, height);

    float a1, a2;

    for (int i = 0; i < height; i++) {
      a1 = map(temp, 35, 25, -60, 80);
      a2 = map(temp, 35, 25, 0, 200);
      float h = map(i, 0, height, a1, a2);

      if (h > 0) h = 360 - h;
      h = abs(h);
      color c = color(h, 100, 100);
      stroke(c);
      line(0, i, width, i);
    }
  } else {
    background(0, 0, 100);
  }

  popStyle();

  fill(0);


  if (has_typed_something()) {
    String s = new String(subset(typed_chars, 0, index+1));
    //text(s, 20, 20);
    // we want to edit the last character typed
    char c = typed_chars[index];

    if (c == '\n') {
      cursor_x = plot_x1;
      if (index >=  1) {
        cursor_y = xy_positions[index-1][Y] + (draw_shape_scale * leading);
      } else {
        cursor_y = cursor_start_y + (leading * draw_shape_scale);
      }
      modified_shapes[index] = null;
    } else {

      PShape shape = loadCharShape(c);
      the_shape_modifier(shape);
      scale_PShape(shape, 1.0/shape.height);
      scale_PShape(shape, draw_shape_scale);
      // scale


      current_modified_shape = shape;
      modified_shapes[index] = shape;

      // set xy position
      if (index == 0) {
        cursor_x = cursor_start_x;
        cursor_y = cursor_start_y;
      } else {

        char last_c = typed_chars[index-1];
        if (last_c == '\n') {
          cursor_x = cursor_start_x;
          cursor_y = xy_positions[index-1][Y];
        } else {         
          cursor_x = xy_positions[index-1][X]+abs(modified_shapes[index-1].getWidth() * kerning);
          cursor_y = xy_positions[index-1][Y];

          //
          float temperature_prev = temperatures[index-1];
          if (temperature_prev < 28.5) {
            kerning = map(constrain(temperatures[index-1], 25, 30), min_temperature, max_temperature, 0.8, 1.0);
          } else {
            kerning = 1;
          }


          if (cursor_x + current_modified_shape.getWidth() > plot_x2) {
            cursor_x = plot_x1;
            cursor_y += leading * draw_shape_scale;
          }
          xy_positions[index][X] = cursor_x;
          xy_positions[index][Y] = cursor_y;
        }
      }
    }


    values_pressure_sensor[index] = force; //waardes die van de sensor binnenkomen
    temperatures[index] = temp;
    values_type_time[index] = time_diff;
    kernings[index] = kerning;
    println("force" +force);
    xy_positions[index][X] = cursor_x;
    xy_positions[index][Y] = cursor_y;
  }



  //line(cursor_x+shape.width+kerning, cursor_y, cursor_x+shape.width+kerning, (cursor_y+200) * scale);


  //display
  //shape(modified_shape, cursor_x, cursor_y);
  //}

  // display
  //{

  stroke(0);
  strokeCap(SQUARE);
  strokeJoin(BEVEL);
  noFill();






  for (int i = 0; i <= index; i++) {

    char c = typed_chars[i];
    if (c == '\n') {
      continue;
    }
    //pushMatrix();

    PShape shape = modified_shapes[i];
    shape.disableStyle();
    float x = xy_positions[i][X];
    float y = xy_positions[i][Y];
    
    debug_str += x + "\t\t"+ y + "\n";
    
    float fontWeight = (map(values_pressure_sensor[i], 0, 1024, 1, 30));
    //float rotationText = (map(constrain(values_type_time[i], 25, 150), 25, 150, -0.075, 0.05)) * scale;
    //rotate(rotationText);
    strokeWeight(fontWeight);



    stroke(0);
    shape(shape, x, y);

    if (show_shapeframe) {
      noFill();
      stroke(i % 2 == 0 ? color(255,0,0) :  color(0,0,255));
      strokeWeight(1);
      rectMode(CORNER);
      rect(x, y, shape.width, shape.height);
      line(x, y + shape.height * base_line, x + shape.width, y + shape.height * base_line);
      text(kernings[i], x + (shape.width/2), y);
    }
  }
  //}



  text(index, 20, 100);

  // PRINT THE DATA AND VARIABLE VALUES
  textAlign(LEFT, BOTTOM);
  fill(0);
  textFont(basic);
  text(temp + "°C", lerp(plot_x1, plot_x2, 0.5), plot_y2);
  //text(bpm + " BPM", (width-100), plot_y2);    // print the Beats Per Minute
  text("BPM "+((int) bpm), plot_x2 - textWidth("XXX BPM"), plot_y2);
  text("force "+((int) force), plot_x1, plot_y2);

  if (record) {
    endRecord();
    record = false;
  }

  saveFrame("frame-####.tif");

  if (recording) {
    videoExport.saveFrame();
  }
  
  if (DEBUG) {
    fill(0);
    textAlign(LEFT, TOP);
    text(debug_str, width-100, 50);
  }
  
}



// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

int last_keypressed_frameCount = -1; // used to avoid running keyPressed more than once in one frame

void keyPressed() {

  if (!USE_ARDUINO) {
    if (key == CODED) {
      if (keyCode == UP) {
        force += 100;
      }
      if (keyCode == DOWN) {
        force -= 100;
      }
    }
  }

  if (last_keypressed_frameCount == frameCount) return;
  last_keypressed_frameCount = frameCount;

  if (keyPressed(CONTROL) && (keyPressed('w') || keyPressed('W'))) {
    if (show_shapeframe == true) {
      show_shapeframe = false;
    } else {
      show_shapeframe = true;
    }
  }

  if (keyPressed(CONTROL) && (keyPressed('s') || keyPressed('S'))) {
    println("export");  
    println(key);
    export();
  } else if (char_ok(key)) {
    index++;
    typed_chars[index] = key;
    //update_cursor_position();
    time_diff = millis() - last_millis;
    last_millis = millis();
  } else if (key == BACKSPACE) {
    //cursor_x -= current_modified_shape.getWidth() + kerning;
    index--;
    if (index < -1) {
      index = -1;
    }
  }

  if (keyPressed(CONTROL) && (keyPressed('v') || keyPressed('V'))) {
    recording = !recording;
    println("Recording is " + (recording ? "ON" : "OFF"));
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

boolean char_ok(char c) {
  for (int i = 0; i < allowed_chars.length; i++) {
    if (allowed_chars[i] == c) return true;
  }
  return false;
}


// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

PShape loadCharShape(char c) {
  String cs = ""+c;
  // handle special cases like ' ', @, #, $, *
  if (c == '\n') return null;
  if (cs.equals(" ")) cs = "space";
  if (cs.equals(".")) cs = "dot"; 
  if (cs.equals(",")) cs = "comma";
  if (cs.equals("?")) cs = "questionmark";
  if (cs.equals("!")) cs = "exclamationmark";
  if (cs.toUpperCase().equals(cs)) cs = cs + cs;


  String file = cs+".svg";
  String dataFolder = "../MadFontData/Alfabet SVG VII/";
  // for now...
  //file = "../MadFontData/foo.svg";
  PShape shape = loadShape(dataFolder+file);
  scale_PShape(shape, 1.0/shape.height);



  //scale_PShape(shape, 50);
  shape.disableStyle();
  return shape;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


/*
void shape_modifier1(PShape shape, float bpm, float temp, int mouse_x, int mouse_y) {
 
 
 }
 */

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

boolean has_typed_something() {
  return index >= 0;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


//void update_cursor_position() {
//  if (current_modified_shape != null) {
//    cursor_x += current_modified_shape.getWidth() + kerning;
//    println("width" +current_modified_shape.getWidth());
//    if (cursor_x + 0 > (width-100)) {
//      cursor_x = 50;
//      cursor_y += 850 * scale;
//    }
//  }
//}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

//void export() {

//  f = new Fontastic(this, "MadelonFont");
//  f.setAuthor("Madelon Balk");

//  if (has_typed_something()) {
//    println("starting export");



//    for (int i = 0; i < allowed_chars.length; i++) {


//      //char c = typed_chars[index];
//      char c = allowed_chars[i];
//      // check enter



//      PShape shape = loadCharShape(c);

//      if (shape == null) {
//        continue;
//      }

//      the_shape_modifier(shape);
//      PShape modified_shape = shape;
//      // draw on PGraphics
//      pg_blob.beginDraw();
//      pg_blob.background(255);

//      if (c == 'a') {
//        println("shape width: "+modified_shape.width);
//        println("shape height: "+modified_shape.height);
//        debug_print(modified_shape);
//      }

//      //pg_blob.shape(modified_shape, cursor_x ...y);
//      pg_blob.shape(modified_shape, 0, 0, pg_blob.width, pg_blob.height);
//      pg_blob.endDraw();

//      pg_blob.save("../debug/blob/"+c+".png");
//      println(cursor_x, cursor_y);

//      image(pg_blob, 0, 0, width, height);

//      // blobscan
//      theBlobDetection.setPosDiscrimination(false);
//      theBlobDetection.setThreshold(0.38f);
//      theBlobDetection.computeBlobs(pg_blob.pixels);

//      // create glyph
//      FGlyph glyph = f.addGlyph(c);

//      // blobs to PVector[]
//      for (int n=0; n<theBlobDetection.getBlobNb(); n++) {
//        Blob b = theBlobDetection.getBlob(n);
//        if (b!=null) {
//          PVector[] vecs = blob_to_PVector_array(b);
//          for (PVector v : vecs) {
//            v.x *= pg_blob.width;
//            v.y *= pg_blob.height;
//          }

//          // add contour
//          glyph.addContour(vecs);
//        }
//      }
//    }
//    // finish exporting font

//    f.buildFont();                                  // Build the font resulting in .ttf and .woff files
//    // and a HTML template to preview the WOFF
//    //How to clean up afterwards:

//    f.cleanup();                  // Deletes all the files that doubletype created, except the .ttf and
//    // .woff files and the HTML template
//  }
//}



// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .



int scan_id = 1;

void export() {
  
  //colorMode(RGB, 255, 255, 255);

  f = new Fontastic(this, "MadelonFont"+hour()+""+second());
  f.setAuthor("Madelon Balk");

  // init BlobDetection
  ThresholdChecker thresholdChecker = new ThresholdChecker() {
    public boolean result_of(int c) {
      //                 green < 128
      return green(c) < 128;
    }
  };

  ContourData contour_data = new ContourData();
  contour_data.edge_indexes = new int[(pg_blob.width*pg_blob.height)/2];
  contour_data.corner_indexes = new int[(pg_blob.width*pg_blob.height)/2];

  int[] contour_map = new int[pg_blob.width*pg_blob.height];


  if (has_typed_something()) {
    println("starting export");

    for (int i = 0; i < allowed_chars.length; i++) {

      char c = allowed_chars[i];

      PShape shape = loadCharShape(c);

      if (shape == null) {
        continue;
      }

      the_shape_modifier(shape);
      
      scale_PShape(shape, 1.0/shape.height);
      scale_PShape(shape, pg_blob.height);
      
      println(pg_blob.height);
  
      final PShape modified_shape = shape;
      // draw on PGraphics
      pg_blob.beginDraw();
      pg_blob.background(255);
      
      
      if (c == 'a') {
        println("shape width: "+modified_shape.width);
        println("shape height: "+modified_shape.height);
        debug_print(modified_shape);
      }
      //pg_blob.strokeWeight(1);
      pg_blob.strokeWeight(1);
      pg_blob.shapeMode(CENTER);
      pg_blob.stroke(0);
      //int str_mar = 40+2;
      //pg_blob.shape(modified_shape, +str_mar, +str_mar, pg_blob.width-str_mar, pg_blob.height-str_mar);
      pg_blob.shape(modified_shape, pg_blob.width/2, pg_blob.height/2);
          
      // create border for blobscan
      pg_blob.noFill();
      pg_blob.stroke(255);
      pg_blob.strokeWeight(1);
      pg_blob.rect(0, 0, pg_blob.width-1, pg_blob.height-1);

      pg_blob.endDraw();

      if (DEBUG) {
        pg_blob.save("../debug/blob/"+c+".png");
      }

      pg_blob.loadPixels();

      // blobscan
      /*
      theBlobDetection.setPosDiscrimination(false);
       theBlobDetection.setThreshold(0.38f);
       theBlobDetection.computeBlobs(pg_blob.pixels);
       */



      // create the glyph
      final FGlyph glyph = f.addGlyph(c);

      glyph.setAdvanceWidth((int)modified_shape.width);

      ContourDataProcessor contour_data_processor = new ContourDataProcessor() {

        public boolean process(ContourData contour_data) {
          //create a contour
          PVector[] contour = new PVector[contour_data.n_of_corners];
          for (int i = 0; i < contour_data.n_of_corners; i++) {
            int index = contour_data.corner_indexes[i];
            float x = index % pg_blob.width;
            float y = (index - x) / pg_blob.width;
            // normalise
            x /= pg_blob.width;
            y /= pg_blob.height;
            y = 1-y; // flip upside down

            x *= modified_shape.width;
            y *= modified_shape.height;

            contour[i] = new PVector(x * 500, y * 500);
          }

          // douglass peucker goes here
          // ...
          glyph.addContour(contour);

          return true; // true means continue scanning
        }
      };

      int y_increment = 5;

      BlobScanner.scan(
        pg_blob.pixels, pg_blob.width, pg_blob.height, 
        0, 0, pg_blob.width, pg_blob.height, 
        y_increment, 
        thresholdChecker, 
        contour_map, 
        scan_id++, 
        contour_data, 
        contour_data_processor);
    }

    // finish exporting font

    f.buildFont();                                  // Build the font resulting in .ttf and .woff files
    // and a HTML template to preview the WOFF
    //How to clean up afterwards:

    f.cleanup();                  // Deletes all the files that doubletype created, except the .ttf and
    // .woff files and the HTML template
  }
}


// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


void debug_print(PShape shape) {
  for (int i = 0; i < shape.getVertexCount(); i++) {
    println(shape.getVertex(i));
  }

  for (int j = 0; j < shape.getChildCount(); j++) {
    debug_print(shape.getChild(j));
  }
}



//PVector[] blob_to_PVector_array(Blob the_blob) {

//  PVector[] result = new PVector[the_blob.getEdgeNb()*2];

//  int index = 0;

//  for (int i = 0; i<the_blob.getEdgeNb(); i++) {
//    EdgeVertex a = the_blob.getEdgeVertexA(i);
//    EdgeVertex b = the_blob.getEdgeVertexB(i);

//    PVector v1 = new PVector(a.x, a.y);
//    PVector v2 = new PVector(b.x, b.y);

//    result[index] = v1;
//    index += 1;
//    result[index] = v2;
//    index += 1;
//  }

//  return result;
//}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


//float shape_width(PShape original) {
//  float[] min_max = new float[] {MAX_FLOAT, MIN_FLOAT};
//  shape_width(original, min_max);
//  return min_max[1] - min_max[0];
//}


//void shape_width(PShape original, float[] min_max) {
//  int MIN = 0;
//  int MAX = 1;

//  for (int i = 0; i < original.getVertexCount(); i++) {
//    PVector result = original.getVertex(i);
//    if (result.x > min_max[MAX]) min_max[MAX] = result.x;
//    if (result.x < min_max[MIN]) min_max[MIN] = result.x;
//  }

//  if (original.getChildCount() > 0) {
//    for (int j = 0; j < original.getChildCount(); j++) {
//      shape_width(original.getChild(j), min_max);
//    }
//  }
//}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


void serialEvent(Serial port) {

  float[] list = new float[2]; 
  int TEMP = 0;
  int FORCE = 1;
  int BPM = 2;

  try {
    String inString = port.readString();
    //println(inString); // <- uncomment this to debug serial input from Arduino
    //println("raw: \t" + inString); // <- uncomment this to debug serial input from Arduino

    if (inString != null) {
      inString = trim(inString);

      //list = float(splitTokens(inString, ", \t"));
      list = float(split(inString, ','));

      if (list.length == 3) {

        temp = list[TEMP];
        if (list[FORCE] > 50) {
          force = list[FORCE];
        }
        if (simulate_bpm == false) {
          bpm = list[BPM];
        }
      } else {
        temp = list[TEMP];
        if (list[FORCE] > 50) {
          force = list[FORCE];
        }
      }


      //println(bpm);
    }
  }

  catch(RuntimeException e) {
    e.printStackTrace();
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

void mousePressed() {
  record = true;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

// Multiple key presses

boolean[] keys = new boolean[1<<020];

public boolean keyPressed(int c) {
  return keys[c];
}

public boolean keyPressed(char c) {
  c = Character.toUpperCase(c);
  int index = (int)c;
  return keys[index];
}

protected void handleKeyEvent(KeyEvent event) {

  //key = event.getKey();
  keyCode = event.getKeyCode();

  // we could also create a bigger array so function keys will work
  // if (keyCode < 256) {
  if (event.getAction() == KeyEvent.PRESS) {
    keys[keyCode] = true;
  } else if (event.getAction() == KeyEvent.RELEASE) {
    keys[keyCode] = false;
  }
  //}

  super.handleKeyEvent(event);
}
// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
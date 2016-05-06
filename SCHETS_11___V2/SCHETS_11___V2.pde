import blobDetection.*;
import fontastic.*;
import processing.serial.*;
import processing.pdf.*;

final static boolean USE_ARDUINO = false;
final boolean DEBUG = true;
boolean simulate_bpm = true;
float scale = 0.03;

float plot_x1, plot_y1, plot_x2, plot_y2;


boolean record; 

final int MAX_SIZE = 2048;
Serial port;


char[] allowed_chars = {' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ',', '!', '.', '?'};

int index = -1;
char[] typed_chars = new char[MAX_SIZE];
PShape[] modified_shapes = new PShape[MAX_SIZE];
float[] x_positions = new float[MAX_SIZE];
float[] y_positions = new float[MAX_SIZE];
float[] values_pressure_sensor = new float [MAX_SIZE];
//float[] values_type_time = new float [MAX_SIZE];

float charWidth;

float cursor_x = 50;
float cursor_y = 50;
float cursor_start_x = 50;
float cursor_start_y = 50;

Fontastic f;
BlobDetection theBlobDetection;
PShape current_modified_shape;
PGraphics pg_blob;


int time_diff;
int last_millis;
int timer = millis();

float key_timediff_map;
float kerning = 0;

//Arduino

float bpm = 120;       // HOLDS HEART RATE VALUE FROM ARDUINO
int portFail = 1;
int readFail = 1;
float temp;
int portNumber = 1;
int lf = 10;      // ASCII linefeed 
float force = 300;
float fontWeight;

void setup() {
  size(650, 950);
  plot_x1 = 50;
  plot_y1 = 50;
  plot_x2 = width-plot_x1;
  plot_y2 = height-plot_y1;

  theBlobDetection = new BlobDetection(100, 200);
  pg_blob = createGraphics(100, 200);

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
  if (record) {
    beginRecord(PDF, "frame-####.pdf");
  }

  background(255);
  fill(0);


  if (simulate_bpm) {
    if (millis() > timer + 1000) {

      if (bpm < 70) {
        bpm = (constrain(bpm + random(0, 3), 60, 120));
      } else {
        bpm = (constrain(bpm + random(-3, 1), 60, 120));
      }
      timer = millis();
    }
  }
  
  println("bpm" + bpm);



  if (has_typed_something()) {
    String s = new String(subset(typed_chars, 0, index+1));
    //text(s, 20, 20);
    // we want to edit the last character typed
    char c = typed_chars[index];
    PShape shape = loadCharShape(c);
    PShape modified_shape = shape_modifier1(shape);
    current_modified_shape = modified_shape;
    modified_shapes[index] = modified_shape;
    // do this elsewhere?

    // set xy position
    if (index-1 >= 0) {
      cursor_x = x_positions[index-1]+abs(modified_shapes[index-1].getWidth()) + kerning;
      cursor_y = y_positions[index-1];
      if (cursor_x + current_modified_shape.getWidth() > plot_x2 || key == ENTER) {
        cursor_x = plot_x1;
        cursor_y += 850 * scale;
      }
      x_positions[index] = cursor_x;
      y_positions[index] = cursor_y;
    } else {
      x_positions[index] = cursor_start_x;
      y_positions[index] = cursor_start_y;
    }



    x_positions[index] = cursor_x;
    y_positions[index] = cursor_y;
    values_pressure_sensor[index] = force; //waardes die van de sensor binnenkomen




    //line(cursor_x+shape.width+kerning, cursor_y, cursor_x+shape.width+kerning, (cursor_y+200) * scale);
    //values_type_time[index] = time_diff;

    //display
    //shape(modified_shape, cursor_x, cursor_y);
  }

  // display
  {

    stroke(0);
    //strokeWeight(10);
    strokeCap(SQUARE);
    strokeJoin(BEVEL);
    noFill();




    for (int i = 0; i <= index; i++) {
      //force = random(0, 1024);
      PShape shape = modified_shapes[i];
      shape.disableStyle();
      float x = x_positions[i];
      float y = y_positions[i];
      float fontWeight = (map(values_pressure_sensor[i], 0, 1024, 10, 100)) * scale;
      //float fontWeight = (map(constrain(values_type_time[i], 100, 1500), 100, 1500, 15, 50)) * scale;
      strokeWeight(fontWeight);
      kerning = (70 * scale) + fontWeight;
      shape(shape, x, y);
    }
  }



  //text(index, 20, 100);

  // PRINT THE DATA AND VARIABLE VALUES
  fill(0);
  text(temp + "°C", (width-200), plot_y2);
  //text(bpm + " BPM", (width-100), plot_y2);    // print the Beats Per Minute
  text("BPM "+((int) bpm), (width-100), plot_y2);


  if (record) {
    endRecord();
    record = false;
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

int last_keypressed_frameCount = -1; // used to avoid running keyPressed more than once in one frame

void keyPressed() {
  if (last_keypressed_frameCount == frameCount) return;
  last_keypressed_frameCount = frameCount;

  if (key == CODED) {
    if (keyCode == CONTROL) {// && (key == 's' || key == 'S')) {
      println(key);
      export();
    }
  } else if (char_ok(key)) {
    index++;
    typed_chars[index] = key;
    //update_cursor_position();
    time_diff = millis() - last_millis;
    last_millis = millis();
  } else if (key == BACKSPACE) {
    cursor_x -= current_modified_shape.getWidth() + kerning;
    index--;
  } //else if (key == ENTER) {
  //  cursor_x = plot_x1;
  //  cursor_y += 850 * scale;
  //}
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
  if (cs.equals(" ")) cs = "space";
  if (cs.equals(".")) cs = "dot"; 
  if (cs.equals(",")) cs = "comma";
  if (cs.equals("?")) cs = "questionmark";
  if (cs.equals("!")) cs = "exclamationmark";
  if (cs.toUpperCase().equals(cs)) cs = cs + cs;




  String file = cs+".svg";
  String dataFolder = "../MadFontData/Alfabet SVG V/";
  // for now...
  //file = "../MadFontData/foo.svg";
  PShape shape = loadShape(dataFolder+file);
  return shape;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

PShape shape_modifier1(PShape shape) {

  float heartBeatY;
  float tempX;



  heartBeatY = map(constrain(bpm, 50, 120), 50, 120, 60, 200);
  tempX = map(temp, 25, 35, -1, 1);
  key_timediff_map = map(constrain(time_diff, 20, 1000), 20, 1500, 0.6, 2);

  //tempX = 0;


  if (USE_ARDUINO) {
    shape.width = abs(shape.width * scale);
    shape.width *= abs(key_timediff_map);
  } else {
    shape.width = abs(shape.width * scale); //+ (mouseX-300);
    shape.width *= abs(key_timediff_map);
    println("width " + shape.width);
  }

  //println("o width" + shape.width);


  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x = result.x *scale;
    result.y = result.y *scale;


    if (USE_ARDUINO) {
      result.y = (result.y * heartBeatY/100) - (heartBeatY/6);
      ////italic
      //result.x = result.x - (result.y*tempX);
      
    } else {
      result.y = (result.y * mouseY/100) - mouseY/6;
      ////italic
      //result.x = result.x - (result.y / (mouseX/6));

    }
    
    result.x = result.x * key_timediff_map;



    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier1(shape.getChild(j));
    }
  }

  return shape;
}

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

void export() {

  f = new Fontastic(this, "MadelonFont");
  f.setAuthor("Madelon Balk");

  if (has_typed_something()) {
    println("starting export");

    // todo, create font etc.

    for (int i = 0; i < allowed_chars.length; i++) {
      char c = typed_chars[index];
      PShape shape = loadCharShape(c);
      PShape modified_shape = shape_modifier1(shape);
      // draw on PGraphics
      pg_blob.beginDraw();
      pg_blob.background(255);
      pg_blob.shape(modified_shape, 10, 10);
      pg_blob.endDraw();

      pg_blob.save("../debug/blob/"+c+".png");

      image(pg_blob, 0, 0, width, height);

      // blobscan
      theBlobDetection.setPosDiscrimination(false);
      theBlobDetection.setThreshold(0.38f);
      theBlobDetection.computeBlobs(pg_blob.pixels);

      // create glyph
      FGlyph glyph = f.addGlyph(c);

      // blobs to PVector[]
      for (int n=0; n<theBlobDetection.getBlobNb(); n++) {
        Blob b = theBlobDetection.getBlob(n);
        if (b!=null) {
          PVector[] vecs = blob_to_PVector_array(b);
          for (PVector v : vecs) {
            v.x *= pg_blob.width;
            v.y *= pg_blob.height;
          }

          // add contour
          glyph.addContour(vecs);
        }
      }
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



PVector[] blob_to_PVector_array(Blob the_blob) {

  PVector[] result = new PVector[the_blob.getEdgeNb()*2];

  int index = 0;

  for (int i = 0; i<the_blob.getEdgeNb(); i++) {
    EdgeVertex a = the_blob.getEdgeVertexA(i);
    EdgeVertex b = the_blob.getEdgeVertexB(i);

    PVector v1 = new PVector(a.x, a.y);
    PVector v2 = new PVector(b.x, b.y);

    result[index] = v1;
    index += 1;
    result[index] = v2;
    index += 1;
  }

  return result;
}

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
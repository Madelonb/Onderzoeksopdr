import blobDetection.*;
import fontastic.*;

final int MAX_SIZE = 1024;


char[] allowed_chars = {' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

int index = -1;
char[] typed_chars = new char[MAX_SIZE];
PShape[] modified_shapes = new PShape[MAX_SIZE];
float[] x_positions = new float[MAX_SIZE];
float[] y_positions = new float[MAX_SIZE];
float[] stroke_weights = new float [MAX_SIZE];


float charWidth;

float cursor_x = 50;
float cursor_y = 50;
float thickness = 1;

Fontastic f;
BlobDetection theBlobDetection;
PShape last_modified_shape;
PGraphics img;


int time_diff;
int last_millis;;
float key_pressed_time;

float scale = 0.25;
float kerning = 20;

void setup() {
  size(1200, 800);
  theBlobDetection = new BlobDetection(1200, 800);
  img = createGraphics(1200, 800);
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

void draw() {
  background(255);
  fill(0);

  if (has_typed_something()) {
    String s = new String(subset(typed_chars, 0, index+1));
    text(s, 20, 20);

    // we want to edit the last character typed
    char c = typed_chars[index];
    PShape shape = loadCharShape(c);
    PShape modified_shape = shape_modifier1(shape);
    last_modified_shape = modified_shape;
    modified_shapes[index] = modified_shape;
    // do this elsewhere?
    x_positions[index] = cursor_x;
    y_positions[index] = cursor_y;
    stroke_weights[index] = thickness;
    strokeWeight(thickness);
    line(cursor_x+shape.width+kerning,cursor_y,cursor_x+shape.width+kerning,cursor_y+200);

    //display
    //shape(modified_shape, cursor_x, cursor_y);
  }

  // display
  {

    stroke(0);
    strokeWeight(10);
    strokeCap(SQUARE);
    noFill();

    for (int i = 0; i <= index; i++) {
      PShape shape = modified_shapes[i];
      shape.disableStyle();
      float x = x_positions[i];
      float y = y_positions[i];
      shape(shape, x, y);
    }
  }

  text(index, 20, 100);
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

void keyPressed() {
  if (key == CODED) {
    if (keyCode == CONTROL) {// && (key == 's' || key == 'S')) {
      println(key);
      export();
    }
  } else if (char_ok(key)) {
    index++;
    typed_chars[index] = key;
    update_cursor_position();
  }


  time_diff = millis() - last_millis;
  last_millis = millis();

  key_pressed_time = map(constrain(time_diff, 100, 1500), 100, 1500, 75, 200);
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

  String file = cs+".svg";
  String dataFolder = "../MadFontData/Alfabet SVG IIII/";
  // for now...
  //file = "../MadFontData/foo.svg";
  PShape shape = loadShape(dataFolder+file);
  return shape;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

PShape shape_modifier1(PShape original) {

  //original.width = (original.width * scale) + (mouseX-800);
  original.width *= scale * key_pressed_time/100;
  
  for (int i = 0; i < original.getVertexCount(); i++) {
    PVector result = original.getVertex(i);
    result.x = result.x *scale;
    result.y = result.y *scale;
    

    //if (result.y < 100) {
    // result.y = result.y + (mouseY-800);
    //}
    //if (result.x < 30) {
    // result.x = result.x + (mouseX-800);
    //}

    result.x = result.x * key_pressed_time/100;
    println("key" +time_diff);

    original.setVertex(i, result.x, result.y);
  }

  if (original.getChildCount() > 0) {
    for (int j = 0; j < original.getChildCount(); j++) {
      shape_modifier1(original.getChild(j));
    }
  }

  return original;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

boolean has_typed_something() {
  return index >= 0;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


void update_cursor_position() {
  if (last_modified_shape != null) {
    cursor_x += last_modified_shape.getWidth() + kerning;
    //println("width" +last_modified_shape.getWidth());
    if (cursor_x + 0 > (width-200)) {
      cursor_x = 50;
      cursor_y += 150;
    }
  }
}

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
      img.beginDraw();
      img.background(255);
      img.shape(modified_shape, 100, 100, 100, 100);
      img.endDraw();

      image(img, 0, 0, width, height);

      // blobscan
      theBlobDetection.setPosDiscrimination(false);
      theBlobDetection.setThreshold(0.38f);
      theBlobDetection.computeBlobs(img.pixels);
      
      // create glyph
      FGlyph glyph = f.addGlyph(c);
      
      // blobs to PVector[]
      for (int n=0; n<theBlobDetection.getBlobNb(); n++) {
        Blob b = theBlobDetection.getBlob(n);
        if (b!=null) {
          PVector[] vecs = blob_to_PVector_array(b);
          for (PVector v : vecs) {
            v.x *= img.width;
            v.y *= img.height;
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
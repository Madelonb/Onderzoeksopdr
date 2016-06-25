//import blobDetection.*; //<>//
import fontastic.*;
import processing.serial.*;
import processing.pdf.*;
import com.github.lemmingswalker.*;
import com.hamoid.*;

boolean ask_for_email = false;
String email_adress;

final static boolean USE_ARDUINO = false;
final boolean DEBUG= true;
final boolean BACKGROUND_COLOR = true;

//final boolean ANIMATE_SHAPE = false;



final int M_USER_MODE = 0;
final int M_ANIMATE_1 = 1;
final int M_ANIMATE_2 = 2;

int mode = M_ANIMATE_1;



boolean simulate_bpm = false;
boolean show_shapeframe = false;

float plot_x1, plot_y1, plot_x2, plot_y2;


boolean record; 

final int MAX_SIZE = 2048;
Serial port;


char[] allowed_chars = {' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ',', '!', '.', '?', '\n'};

float[] original_width_chars = new float[allowed_chars.length];

int index = -1;
char[] typed_chars = new char[MAX_SIZE];
PShape[] modified_shapes = new PShape[MAX_SIZE];

float[][] positions_xy = new float[MAX_SIZE][2];
float[] values_pressure_sensor = new float [MAX_SIZE];
int[] values_type_time = new int [MAX_SIZE];
float[] temperatures = new float [MAX_SIZE];
float[] strokeWeights = new float [MAX_SIZE];
float[] bpm_values = new float [MAX_SIZE];

float min_temperature = 25;
float max_temperature = 35;

Fontastic f;

PShape current_modified_shape;
PGraphics pg_blob;
PFont basic;


int time_diff;
int last_millis;
int timer = millis();

float key_timediff_map;
float kerning = 0.05;
float leading = 0.35;

//Arduino

float bpm = 50;       // HOLDS HEART RATE VALUE FROM ARDUINO
int portFail = 1;
int readFail = 1;
float temp = 35;
int portNumber = 1;
int lf = 10;      // ASCII linefeed 
float force = 50;
float fontWeight;

float bpmSpeed = 2;
float tempSpeed = 0;
int timediffSpeed = 0;


float heartBeatY;
float tempX;


float base_line = 0.72;

float draw_shape_scale = 100;

String debug_str;

float strokeWeight;

char[] animated_chars = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}; 
int animated_char_index = 0;


void setup() {
  size(707, 1000);
  frameRate(30);
  noCursor();
  plot_x1 = 50;
  plot_y1 = 50;
  plot_x2 = width-plot_x1;
  plot_y2 = height-plot_y1;
  basic = createFont("FaktPro-Normal.ttf", 14);
  //noCursor();

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

  for (int i = 0; i < allowed_chars.length; i++) {
    char c = allowed_chars[i];
    PShape s = loadCharShape(c);
    if (s == null) {
      original_width_chars[i] = -1;
      continue;
    }

    scale_PShape(s, 1.0 / s.height);
    float s_width = shape_width(s);
    original_width_chars[i] = s_width;

    //println(c, original_width_chars[i]);
  }


  if (mode == M_USER_MODE) {
    draw_shape_scale = 100;
  }  
  if (mode == M_ANIMATE_1) {
    index = 0;
    typed_chars[0] = 'a';
    draw_shape_scale = 850;
  } 
  if (mode == M_ANIMATE_2) {
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

void draw() {


  if (mode == M_ANIMATE_2) {
    if (frameCount % 3 == 0) {
      index++;
      typed_chars[index] = 'a';
    }
  }


  debug_str = "";

  //typed_chars[index] = 'a';

  //if (keyPressed(CONTROL) && (keyPressed('f') || keyPressed('F'))) {
  //  for (int i=0; i < index+1; i++) {
  //    draw_shape_scale += 15;
  //    modified_shapes[i] = null;
  //  }
  //}

  //if (keyPressed(CONTROL) && (keyPressed('j') || keyPressed('J'))) {
  //  for (int i=0; i < index+1; i++) {
  //    draw_shape_scale -= 15;
  //    modified_shapes[i] = null;
  //  }
  //}

  draw_shape_scale = constrain(draw_shape_scale, 100, 900);

  if (keyPressed(CONTROL) && (keyPressed('='))) {
    draw_shape_scale += 10;
    for (int i=0; i < index+1; i++) {
      modified_shapes[i] = null;
    }
  }

  if (keyPressed(CONTROL) && (keyPressed('-'))) {
    draw_shape_scale -= 10;
    for (int i=0; i < index+1; i++) {
      modified_shapes[i] = null;
    }
  }


  debug_str += "fontsize: "+draw_shape_scale+"\n";

  if (ask_for_email) {
    //text(email_adress, 100, 100);
  }

  //println(email_adress);

  if (simulate_bpm) {
    if (millis() > timer + 1000) {

      if (bpm > 90) {
        bpm = (constrain(bpm + random(-1.5, 1), 60, 120));
      } else {
        bpm = (constrain(bpm + random(0, 1.5), 60, 120));
      }

      timer = millis();
    }
  } else if ((mode == M_ANIMATE_1) || (mode == M_ANIMATE_2)) {

    bpm = bpm + bpmSpeed;
    temp = temp + tempSpeed;
    time_diff = time_diff + timediffSpeed;

    if (bpm > 120) {
      bpm = 120;
      bpmSpeed = 0;
      tempSpeed = -0.4;
      timediffSpeed = 0;
    }

    if (temp < 25) {
      temp = 25;
      tempSpeed = 0;
      timediffSpeed = 16;
      //bpmSpeed = -1;
    }
    if (time_diff > 500) {
      time_diff = 500;
      timediffSpeed = 0;
      bpmSpeed = -2;
      //tempSpeed = -0.2;
    }
    if (bpm < 50) {
      bpm = 50;
      //time_diff = 0;
      //timediffSpeed = 0;
      bpmSpeed = 0;
      tempSpeed = 0.4;
    }
    if (temp > 35) {
      temp = 35;
      //bpmSpeed = 0;
      tempSpeed = 0;
      timediffSpeed = -16;
    }
    if (time_diff < 0) {
      time_diff = 0;
      timediffSpeed = 0;
      //tempSpeed = 0;
      bpmSpeed = 2;
      force += 200;
    }

    force = constrain(force, 0, 1024);
    //if ((force == 850) && (typed_chars[index] == 'a')) {
    //  typed_chars[index] = 'b';
    //}

    //println(force);
    if (force == 1024) {
      println("force == 1024");
      animated_char_index += 1;
      typed_chars[index] = animated_chars[animated_char_index];
      modified_shapes[index] = null;
      force = 50;
    }
  } else if (!USE_ARDUINO) {
    temp = map(constrain(mouseX, 0, width), 0, width, 25, 35);
    bpm = map(constrain(mouseY, 0, height), 0, height, 120, 50);

    if (keyPressed(UP)) {
      force += 10;
      if (force > 1024) {
        force = 1024;
      }
    }
    if (keyPressed(DOWN)) {
      force -= 10;
      if (force < 0) {
        force = 0;
      }
    }
  } 


  if (has_typed_something()) {
    values_pressure_sensor[index] = force; //waardes die van de sensor binnenkomen
    temperatures[index] = temp;
    values_type_time[index] = time_diff;
    strokeWeights[index] = strokeWeight;
    bpm_values[index] = bpm;
  }



  if (record) {
    beginRecord(PDF, "frame-####.pdf");
  }



  if (BACKGROUND_COLOR) {

    pushStyle();
    colorMode(HSB, 360, 100, 100);

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

    popStyle();
  } else {
    background(255);
  }

  float cursor_x;
  float cursor_y;

  if (mode == M_ANIMATE_1) {
    cursor_x = width/2;
    cursor_y = 50;
  } else {
    cursor_x = plot_x1;
    cursor_y = plot_y1 - draw_shape_scale * 0.3;
  }


  for (int i = 0; i <= index; i++) {

    if (cursor_y > (plot_y2-75)) {
      index = index - 1;
      break;
    }

    println("cursor_y "+cursor_y);

    char c = typed_chars[i];


    if (c == '\n') {
      cursor_x = plot_x1;
      cursor_y += draw_shape_scale * leading;
      continue;
    }

    String typed_string = new String(typed_chars);

    String rest_word = rest_word(typed_string, i);


    PShape shape = modified_shapes[i];
    if (shape == null || i == index) {

      heartBeatY = bpm_values[i]; 
      time_diff = (int) values_type_time[i];
      tempX = temperatures[i]; 

      bpm = bpm_values[i]; 
      time_diff = (int) values_type_time[i];
      temp = temperatures[i];

      shape = loadCharShape(c);
      the_shape_modifier(shape, c);
      scale_PShape(shape, 1.0/shape.height);
      scale_PShape(shape, draw_shape_scale);
      modified_shapes[i] = shape;
    }



    float rest_of_word_width = 0;//textWidth(rest_word);

    //for (int j = 0; j < rest_word.length(); j++) {
    //  //text(rest_word.charAt(j), 20, 20);
    //  char cc = rest_word.charAt(j);

    //  if (cc == '\0') {
    //    break;
    //  }

    //  //println("rest_word: "+rest_word);
    //  PShape shape2 = loadCharShape(cc);
    //  the_shape_modifier(shape2, cc);
    //  scale_PShape(shape2, 1.0/shape2.height);
    //  scale_PShape(shape2, draw_shape_scale);

    //  rest_of_word_width += shape_width(shape2) * 1.1;
    //}

    //println("rest_of_word_width: "+rest_of_word_width);


    if (cursor_x + rest_of_word_width > plot_x2 ) {
      // ga naar nieuwe regel
      cursor_y += draw_shape_scale * leading;
      // en zet x weer naar het begin (plot_x1)
      cursor_x = plot_x1;
    }


    if (mode != M_ANIMATE_1) {
      if (cursor_x + shape.width > plot_x2) {
        cursor_x = plot_x1;
        cursor_y += draw_shape_scale * leading;
      }
    }





    float x = cursor_x;
    float y = cursor_y;


    debug_str += x + "\t\t"+ y + "\n";

    strokeWeight = map(constrain(values_pressure_sensor[i], 0, 1024), 0, 1024, 0.005, 0.04);
    strokeWeight *= draw_shape_scale; 



    strokeWeight(strokeWeight);
    stroke(0);
    strokeCap(SQUARE);
    strokeJoin(BEVEL);
    noFill();

    if (mode == M_ANIMATE_1) {
      float half_width = shape_width(shape) / 2;
      shape(shape, x-half_width, y);
    } else {
      shape(shape, x, y);
    }

    // unused
    positions_xy[i][X] = x;
    positions_xy[i][Y] = y;

    cursor_x += shape_width(shape);

    // adjust kerning
    //float new_width = shape_width(shape) * (1.0 / shape.height);
    //float difference_width = new_width - original_width_chars[index_in_allowed_chars(c)];
    //cursor_x -= shape_width(shape) * difference_width;
    //cursor_x += draw_shape_scale * 0.05;

    //if (i > 0) {
    //float temperature_prev = temperatures[i];

    if (temperatures[i] < 27) {
      if (values_type_time[i] > 150) {
        kerning = map(constrain(temperatures[i], min_temperature, 27), min_temperature, 27, -0.05, 0.03) * draw_shape_scale;
      } else {
        kerning = map(constrain(temperatures[i], min_temperature, 27), min_temperature, 27, -0.03, 0.03) * draw_shape_scale;
      }
    } else {
      kerning = 0.03 * draw_shape_scale;
    }

    char next_char = typed_chars[i+1];
    if (c != '\0' && c != ' ' && c != '\n') {
      if ((c == 'A' && next_char == 'V') || (c == 'V' && next_char == 'A')) {
        if (values_type_time[i] < 150) {
          kerning = -0.03 * draw_shape_scale;
        } else {
          kerning = -0.06 * draw_shape_scale;
        }
      }
    }


    //cursor_x +=  shape_width(shape) * kerning;
    cursor_x += kerning + ((strokeWeights[i]/2) + (strokeWeights[i+1]/2));


    //float prev_char = typed_chars[i-1];


    //prev_char = c;




    if (show_shapeframe) {
      noFill();
      stroke(i % 2 == 0 ? color(255, 0, 0) :  color(0, 0, 255));
      strokeWeight(1);
      rectMode(CORNER);
      println(shape.width);
      rect(x, y, shape.width, shape.height);
      line(x, y + shape.height * base_line, x + shape.width, y + shape.height * base_line);
      line(x, y, x + shape.width, y + shape.height);

      //text(difference_width, x + (shape.width/2), y);
    }
  }
  //}






  //text(index, 20, 100);

  // PRINT THE DATA AND VARIABLE VALUES
  textAlign(LEFT, BOTTOM);
  fill(0);
  textFont(basic);
  String temperature = nfc(temp, 1);
  //textAlign(CENTER);
  text(temperature + "°C", lerp(plot_x1, plot_x2, 0.6), plot_y2);
  //text(bpm + " BPM", (width-100), plot_y2);    // print the Beats Per Minute
  text(time_diff +" ms/key", lerp(plot_x1, plot_x2, 0.3), plot_y2);
  text(((int) bpm)+" BPM", plot_x2 - textWidth("XXX BPM"), plot_y2);
  text("pressure "+((int) force), plot_x1, plot_y2);

  if (record) {
    endRecord();
    record = false;
  }

  //if (keyPressed(CONTROL) && (keyPressed('r') || keyPressed('R'))) {
  //  saveFrame("../MOVIEMAKER/frame-####.tif");
  //}

  saveFrame("../MOVIEMAKER/frame-####.tif");


  if (DEBUG) {
    fill(0);
    textAlign(LEFT, TOP);
    debug_str = "";
    text(debug_str, width-100, 50);
  }
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


int index_in_allowed_chars(char c) {
  for (int i = 0; i < allowed_chars.length; i++) {
    char cc = allowed_chars[i];
    if (c == cc) return i;
  }
  return -1;
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
  String dataFolder = "../MadFontData/Alfabet SVG 9/";
  // for now...
  //file = "../MadFontData/foo.svg";
  PShape shape = loadShape(dataFolder+file);
  scale_PShape(shape, 1.0/shape.height);



  //scale_PShape(shape, 50);
  shape.disableStyle();
  return shape;
}


// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

boolean has_typed_something() {
  return index >= 0;
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



// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .


float shape_width(PShape original) {
  float[] min_max = new float[] {MAX_FLOAT, MIN_FLOAT};
  shape_width(original, min_max);
  return min_max[1] - min_max[0];
}


void shape_width(PShape original, float[] min_max) {
  int MIN = 0;
  int MAX = 1;

  for (int i = 0; i < original.getVertexCount(); i++) {
    PVector result = original.getVertex(i);
    if (result.x > min_max[MAX]) min_max[MAX] = result.x;
    if (result.x < min_max[MIN]) min_max[MIN] = result.x;
  }

  if (original.getChildCount() > 0) {
    for (int j = 0; j < original.getChildCount(); j++) {
      shape_width(original.getChild(j), min_max);
    }
  }
}

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


// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

String rest_word(String s, int start_index) {
  String result = "";

  for (int i = start_index; i < s.length(); i++) {
    char c = s.charAt(i);
    if (c == ' ' || c == '-' || c == '\n') {
      break;
    }
    result += c;
  } 
  return result;
}
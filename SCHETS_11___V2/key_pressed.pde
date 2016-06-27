
int last_keypressed_frameCount = -1; // used to avoid running keyPressed more than once in one frame

void keyPressed() {

  if (last_keypressed_frameCount == frameCount) return;
  last_keypressed_frameCount = frameCount;

  if (keyPressed(CONTROL)) {

    if (keyPressed('w') || keyPressed('W')) {
      if (show_shapeframe == true) {
        show_shapeframe = false;
      } else {
        show_shapeframe = true;
      }
    } else if (keyPressed('s') || keyPressed('S')) {
      println("export");  
      println(key);
      export();
      ask_for_email = true;
    }
  } 
  
  if (key == 's'){
   ask_for_email = true; 
  }
  
  if (ask_for_email) {
    if (key == '\n') {
      println(validate(fill_in_email));
      validate(fill_in_email);
      ask_for_email = false;

      // opslaan
      // ...
      fill_in_email = "";
    } else if (key == ' ') {
      println("ERROR");
    } else {
      if (key != CODED) {
        if (key == BACKSPACE) {
          fill_in_email = fill_in_email.substring(0, max(0, fill_in_email.length()-1));
        } else {
          fill_in_email += key;
        }
      }
    }
  } else if (char_ok(key)) {
    index++;
    typed_chars[index] = key;
    //update_cursor_position();
    if (mode != M_ANIMATE_1) {
      time_diff = millis() - last_millis;
      time_diff = constrain(time_diff, 50, 500);
      last_millis = millis();
    }
  } else if (key == BACKSPACE) {
    //cursor_x -= current_modified_shape.getWidth() + kerning;
    index--;
    if (index < -1) {
      index = -1;
    }
  }


  if (keyPressed(CONTROL) && (keyPressed('d') || keyPressed('D'))) {
    for (int i=0; i < index+1; i++) {
      modified_shapes[i] = null;
    }
    index = -1;
  }
}



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
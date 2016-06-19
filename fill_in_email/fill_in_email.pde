import java.util.regex.Pattern;
import java.util.regex.Matcher;

String fill_in_email = "";
String typed = "";
boolean ask_for_email = false;

public static final Pattern VALID_EMAIL_ADDRESS_REGEX = 
  Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$", Pattern.CASE_INSENSITIVE);

void setup() {
  size(500, 300);
}

void draw() {
  background(255);
  fill(0);
  text(typed, 20, 20);

  if (ask_for_email) {
    fill(255);
    stroke(255, 0, 0);
    rect(50, 50, 400, 200);
    fill(0);
    text(fill_in_email, 70, 70);
  }
}

void keyPressed() {

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
      fill_in_email += key;
    }
  } else {
    typed += key;
  }


  if (key == 's') {
    ask_for_email = true;
  }
}

public static boolean validate(String emailStr) {
  Matcher matcher = VALID_EMAIL_ADDRESS_REGEX .matcher(emailStr);
  return matcher.find();
}


// VOOR IN HOOFDSCHETS (RESETTEN LETTERS):
//void reset() {
//  index = -1;
//  for (int i ....
//    modified_shapes[i] = null;

//  typed = "";  

//}
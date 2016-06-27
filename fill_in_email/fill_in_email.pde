import java.util.Properties;
import javax.activation.*;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import javax.mail.*;

String fill_in_email = "";
String typed = "";
boolean ask_for_email = false;
String folder_name;



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
      folder_name = "HumanType"+hour()+""+second();
      println(validate(fill_in_email));
      validate(fill_in_email);
      ask_for_email = false;
      if (validate(fill_in_email)){
      test();
      println(fill_in_email);
      println(dataPath(""));
      println(folder_name);
      }

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


void test() {

  Properties props = new Properties();
  props.put("mail.smtp.auth", true);
  props.put("mail.smtp.starttls.enable", true);
  props.put("mail.smtp.host", "smtp.gmail.com");
  props.put("mail.smtp.port", "587");

  Session session = Session.getInstance(props, 
    new javax.mail.Authenticator() {
    protected PasswordAuthentication getPasswordAuthentication() {
      return new PasswordAuthentication(username, password);
    }
  }
  );

  try {

    Message message = new MimeMessage(session);
    message.setFrom(new InternetAddress(username));
    message.setRecipients(Message.RecipientType.TO, 
      InternetAddress.parse(fill_in_email));
    message.setSubject("Testing Subject");
    message.setText("PFA");

    MimeBodyPart messageBodyPart = new MimeBodyPart();

    Multipart multipart = new MimeMultipart();
    
    messageBodyPart = new MimeBodyPart();
    String file = dataPath("")+"/"+folder_name;
    String fileName = folder_name;
    DataSource source = new FileDataSource(file);
    messageBodyPart.setDataHandler(new DataHandler(source));
    messageBodyPart.setFileName(fileName);
    multipart.addBodyPart(messageBodyPart);

    message.setContent(multipart);

    System.out.println("Sending");

    Transport.send(message);

    System.out.println("Done");
  } 
  catch (MessagingException e) {
    e.printStackTrace();
  }
  
  
}
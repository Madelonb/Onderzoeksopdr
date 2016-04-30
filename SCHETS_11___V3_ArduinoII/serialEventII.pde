void serialEvent(Serial port) {
  
  String inData = port.readStringUntil('\n');
  
  try {
    //String inString = port.readString();
    String[] list=split(inData,"\n");
    println(list[1]);
    
    temp = Float.parseFloat(list[0]);
    force = Float.parseFloat(list[1]);
    
    //if (0 < port.available()){
    //force = port.read();
   
    //}

    readFail = 0;
    println(temp);
    println(force);
 } 
  catch (Exception e){
     readFail = 1;
  }
}
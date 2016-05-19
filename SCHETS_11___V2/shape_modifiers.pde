
void the_shape_modifier(PShape shape) {
  shape_modifier2(shape);
}


void shape_modifier3(PShape shape) {

  shape.width *= 0.5;

  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x = result.x *= 0.5;
    result.y = result.y;
    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier3(shape.getChild(j));
    }
  }
}


void shape_modifier2(PShape shape) {

  float heartBeatY;
  float tempX;

  float mapMouseY;
  float mapMouseX;
  float mapMouseX2;

  heartBeatY = map(constrain(bpm, 50, 120), 50, 120, 0.75, 3);
  tempX = map(constrain(temp, 25, 35), 25, 35, 0.5, 1.5);

  //key_timediff_map = map(constrain(time_diff, 20, 500), 20, 500, 1, 2);

  mapMouseY = map(constrain(mouseY, 100, 400), 100, 400, 0.75, 3);
  mapMouseX = map(constrain(mouseX, 100, 400), 100, 400, 0.5, 1.5);
  mapMouseX2 = map(constrain(mouseX, 100, 400), 100, 400, 0, 3);


  //mapMouseY = map(constrain(mouseY, 100, 400), 100, 400, -5, 5);
  //mapMouseX = map(constrain(mouseX, 100, 400), 100, 400, -3, 3);






  //tempX = 0;


  if (USE_ARDUINO) {
    shape.width = abs(shape.width * scale);
    shape.width = abs(shape.width * tempX);
    //shape.width *= abs(key_timediff_map);
    //shape.width = abs(shape.width + tempX);
    //shape.width = shape.width - (result.y / (mouseX/6));
  } else {
    shape.width = abs(shape.width * scale); //+ (mouseX-300);
    shape.width = abs(shape.width * mapMouseX);
    //shape.width *= abs(key_timediff_map);
    //println("width " + shape.width);
  }

  //println("o width" + shape.width);


  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x = result.x *scale;
    result.y = result.y *scale;


    if (USE_ARDUINO) {
      //result.y = (result.y * heartBeatY/100) - (heartBeatY/(200*scale));
      ////italic
      //result.x = result.x - (result.y*tempX);

      result.y = result.y * heartBeatY - (heartBeatY*17.5);
      result.x = result.x * tempX;

      if (result.y < 8) {
        result.y = result.y + heartBeatY;
        //result.x = result.x + mapMouseX;
      }
      //if (result.x > 1) {
      //  result.x = result.x + tempX;
      //}
    } else {
      //result.x = result.x * mapMouseX;
      result.y = result.y * mapMouseY - (mapMouseY*17.5);
      result.x = result.x * mapMouseX;

      //result.x = result.x - (result.y*mapMouseX);
      if (result.y < -6) {
        //  result.y = result.y + mapMouseY;
        result.x = result.x + mapMouseX2;
      }

      //if (result.x > 1) {
      //  result.x = result.x + mapMouseX;
      //}





      //      result.y = (result.y * mouseY/100) - mouseY/6;
      //      //italic
      //      result.x = result.x - (result.y / (mouseX/6));
    }






    //result.x = result.x * key_timediff_map;


    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier2(shape.getChild(j));
    }
  }
}
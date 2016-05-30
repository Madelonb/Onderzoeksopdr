
void the_shape_modifier(PShape shape) {
  //scale_PShape(shape, scale);
  shape_modifier4(shape);
}


void shape_modifier3(PShape shape) {

  shape.width *= 0.5;

  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x *= 0.5;
    result.y = result.y;
    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier3(shape.getChild(j));
    }
  }
}

void shape_modifier4(PShape shape) {

  // shape.width *= 0.5;
  // shape.height *= 2.5;

  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x *= 0.5;

    float y_scale = 2.5;
    float base_line = 0.76;

    result.y -= base_line;

    if (result.y < 0) {
      result.y = result.y * y_scale;
      result.y = result.y + (base_line * y_scale);
    }
    else {
      result.y += base_line;
    }

    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier4(shape.getChild(j));
    }
  }
}



void shape_modifier2(PShape shape) {

  float heartBeatY;
  float tempX;


  heartBeatY = map(constrain(bpm, 50, 120), 50, 120, 0.75, 2);
  tempX = map(constrain(temp, 25, 30), 30, 25, 0, 0.2);
  key_timediff_map = map(constrain(time_diff, 20, 500), 20, 500, 1, 2);

  shape.width = abs(shape.width);
  shape.height = abs(shape.height);  
  shape.width = abs(shape.width + (tempX/2));
  shape.width = abs(shape.width * key_timediff_map);
  shape.height = abs(shape.height* heartBeatY);


  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);

    result.x = result.x;
    result.y = result.y;
    //result.y = result.y * heartBeatY - (heartBeatY*17.5);

    result.y = result.y * heartBeatY;

    //if (result.y < 10) {
    if (result.y < 0.5) {

      result.x = result.x + tempX;
    }

    result.x = result.x * key_timediff_map;

    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      shape_modifier2(shape.getChild(j));
    }
  }
}

void scale_PShape(PShape shape, float scale) {

  shape.width = abs(shape.width * scale);
  shape.height = abs(shape.height * scale);  

  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector result = shape.getVertex(i);
    result.x = result.x *scale;
    result.y = result.y *scale;
    shape.setVertex(i, result.x, result.y);
  }

  if (shape.getChildCount() > 0) {
    for (int j = 0; j < shape.getChildCount(); j++) {
      scale_PShape(shape.getChild(j), scale);
    }
  }
}


void normalize(PShape s) {
  float scale;
  if (s.width > s.height) {
    scale = 1/s.width;
  } else {
    scale = 1/s.height;
  }
  scale_PShape(s, scale);
}
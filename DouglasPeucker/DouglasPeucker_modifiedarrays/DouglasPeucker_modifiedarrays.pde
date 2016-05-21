float[][] points = {
  {
    45, 197
  }
  , {
    46, 196
  }
  , {
    47, 190
  }
  , {
    48, 183
  }
  , {
    50, 177
}};

float [] points_x = {45, 46, 47, 48, 50};
float [] points_y = {197, 196, 190, 183, 177};


ArrayList<PVector> vecs = new ArrayList<PVector>();

// --------------------------------------------------

void setup() {
  size(800, 800);

  //println("points_x: "+points_x);
  //println("points_y: "+points_y);
}

// --------------------------------------------------

void draw() {
  background(255);
  noFill();
  stroke(0, 0, 200);


  //beginShape();
  //for (float[] xy : points) {
  //vertex(xy[0], xy[1]);
  //println("xy[0] "+xy[0]);
  //}
  //endShape();

  beginShape();
  for (int i=0; i < points_x.length; i++) {
    float x = points_x[i];
    float y = points_y[i];
    vertex(x, y);
  }
  endShape();

  int start = millis();
  if (points.length > 3) {
    float[] result_x = douglasPeucker_x(points_x, map(mouseX, 0, width, 0, 100));
    float[] result_y = douglasPeucker_y(points_y, map(mouseX, 0, width, 0, 100));

    println(millis()-start);

    stroke(0, 200, 0);

    //beginShape();
    //for (float[] xy : result) {
    //  vertex(xy[0], xy[1]);
    //}
    //endShape();

    beginShape();
    for (int i=0; i < result_x.length; i++) {
      float x = result_x[i];
      float y = result_y[i];
      vertex(x, y);
    }
    endShape();
  }
}

// --------------------------------------------------

void mousePressed() {
  vecs.clear();
}

// --------------------------------------------------

void mouseDragged() {
  vecs.add(new PVector(mouseX, mouseY));

  beginShape();
  for (PVector v : vecs) {
    vertex(v.x, v.y);
  }
  endShape();
}

// --------------------------------------------------

void mouseReleased() {
  points = new float[vecs.size()][2];

  int i = 0;
  for (PVector v : vecs) {
    points[i++] = new float[] {v.x, v.y};
  }
}

// --------------------------------------------------


//float[][] douglasPeucker(float[][] points, float epsilon) {
//return douglasPeucker(points, 0, points.length-1, epsilon);
//}

float[] douglasPeucker_x(float[] points_x, float epsilon) {
  return douglasPeucker_x(points_x, 0, points_x.length-1, epsilon);
}

// --------------------------------------------------

float[] douglasPeucker_y(float[] points_y, float epsilon) {
  return douglasPeucker_y(points_y, 0, points_y.length-1, epsilon);
}

// --------------------------------------------------

//float[][] douglasPeucker(float[][] points, int startIndex, int endIndexInc, float epsilon) {
//  // find point with max dist
//  float dMax = 0;
//  int index = -1;

//  for (int i = startIndex+1; i <= endIndexInc; i++) {
//    float d = distToSegmentSquared(points[i][0], points[i][1], points[startIndex][0], points[startIndex][1], points[endIndexInc][0], points[endIndexInc][1]);
//    if (d > dMax) {
//      index = i;
//      dMax = d;
//    }
//  }

//  dMax = sqrt(dMax);

//  // if it's greater we simplify
//  if (dMax > epsilon) {

//    float[][] resultFront = douglasPeucker(points, startIndex, index, epsilon);
//    float[][] resultBack = douglasPeucker(points, index, endIndexInc, epsilon);

//    // combine
//    float[][] result = new float[resultFront.length+resultBack.length][2];

//    for (int i = 0; i < resultFront.length; i++) {
//      System.arraycopy(resultFront[i], 0, result[i], 0, 2);
//    }
//    for (int i = 0; i < resultBack.length; i++) {
//      System.arraycopy(resultBack[i], 0, result[i+resultFront.length], 0, 2);
//    }

//    return result;
//  } else {

//    return new float[][] { {points[startIndex][0], points[startIndex][1] }, { points[endIndexInc][0], points[endIndexInc][1] }};
//  }
//}

float[] douglasPeucker_x(float[] points_x, int startIndex, int endIndexInc, float epsilon) {
  // find point with max dist
  float dMax = 0;
  int index = -1;

  for (int i = startIndex+1; i <= endIndexInc; i++) {
    float d = distToSegmentSquared(points_x[i], points_x[i], points_x[startIndex], points_x[startIndex], points_x[endIndexInc], points_x[endIndexInc]);
    if (d > dMax) {
      index = i;
      dMax = d;
    }
  }

  dMax = sqrt(dMax);

  // if it's greater we simplify
  if (dMax > epsilon) {

    float[] resultFront_x = douglasPeucker_x(points_x, startIndex, index, epsilon);
    float[] resultFront_y = douglasPeucker_x(points_x, startIndex, index, epsilon);


    float[] resultBack_x = douglasPeucker_x(points_x, index, endIndexInc, epsilon);
    float[] resultBack_y = douglasPeucker_x(points_x, index, endIndexInc, epsilon);

    // combine
    float[] result_x = new float[resultFront_x.length+resultBack_x.length];
    float[] result_y = new float[2];

    for (int i = 0; i < resultFront_x.length; i++) {
      System.arraycopy(resultFront_x[i], 0, result_x[i], 0, 2);
    }
    for (int i = 0; i < resultBack_x.length; i++) {
      System.arraycopy(resultBack_x[i], 0, result_x[i+resultFront_x.length], 0, 2);
    }

    return result_x;
    //return result_y;
  } else {

    //return new float[] { {points[startIndex][0], points[startIndex][1] }, { points[endIndexInc][0], points[endIndexInc][1] }};
    return new float[] {points_x[startIndex], points_x[endIndexInc]};
  }
}

// --------------------------------------------------

float[] douglasPeucker_y(float[] points_y, int startIndex, int endIndexInc, float epsilon) {
  // find point with max dist
  float dMax = 0;
  int index = -1;

  for (int i = startIndex+1; i <= endIndexInc; i++) {
    float d = distToSegmentSquared(points_y[i], points_y[i], points_y[startIndex], points_y[startIndex], points_y[endIndexInc], points_y[endIndexInc]);
    if (d > dMax) {
      index = i;
      dMax = d;
    }
  }

  dMax = sqrt(dMax);

  // if it's greater we simplify
  if (dMax > epsilon) {

    float[] resultFront_x = douglasPeucker_y(points_y, startIndex, index, epsilon);
    float[] resultFront_y = douglasPeucker_y(points_y, startIndex, index, epsilon);


    float[] resultBack_x = douglasPeucker_y(points_y, index, endIndexInc, epsilon);
    float[] resultBack_y = douglasPeucker_y(points_y, index, endIndexInc, epsilon);

    // combine
    float[] result_x = new float[resultFront_y.length+resultBack_y.length];
    float[] result_y = new float[2];

    for (int i = 0; i < resultFront_y.length; i++) {
      System.arraycopy(resultFront_y[i], 0, result_y[i], 0, 2);
    }
    for (int i = 0; i < resultBack_y.length; i++) {
      System.arraycopy(resultBack_y[i], 0, result_y[i+resultFront_y.length], 0, 2);
    }

    return result_y;
    //return result_x;
  } else {

    //return new float[] { {points[startIndex][0], points[startIndex][1] }, { points[endIndexInc][0], points[endIndexInc][1] }};
    return new float[] {points_y[startIndex], points_y[endIndexInc]};
    //return new float[] {points_x[startIndex], points_x[endIndexInc]};
  }
}







// --------------------------------------------------

float dist2(float x1, float y1, float x2, float y2) { 
  return sq(x1 - x2) + sq(y1 - y2);
}


// --------------------------------------------------


float distToSegment(float px, float  py, float lx1, float  ly1, float lx2, float ly2) { 
  return sqrt(distToSegmentSquared(px, py, lx1, ly1, lx2, ly2));
}


// --------------------------------------------------


// inspired by http://stackoverflow.com/a/1501725/1022707
float distToSegmentSquared(float px, float py, float lx1, float ly1, float lx2, float ly2) {
  float lineDist = dist2(lx1, ly1, lx2, ly2);

  if (lineDist == 0) return dist2(px, py, lx1, ly1);

  float t = ((px - lx1) * (lx2 - lx1) + (py - ly1) * (ly2 - ly1)) / lineDist;

  if (t < 0) return dist2(px, py, lx1, ly1);
  if (t > 1) return dist2(px, py, lx2, ly2);

  return dist2(px, py, lx1 + t * (lx2 - lx1), ly1 + t * (ly2 - ly1));
}


// --------------------------------------------------
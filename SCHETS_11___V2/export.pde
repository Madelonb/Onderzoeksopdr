


int scan_id = 1;

void export() {

  //colorMode(RGB, 255, 255, 255);

  f = new Fontastic(this, "MadelonFont"+hour()+""+second());
  f.setAuthor("Madelon Balk");

  // init BlobDetection
  ThresholdChecker thresholdChecker = new ThresholdChecker() {
    public boolean result_of(int c) {
      //                 green < 128
      return green(c) < 128;
    }
  };

  ContourData contour_data = new ContourData();
  contour_data.edge_indexes = new int[(pg_blob.width*pg_blob.height)/2];
  contour_data.corner_indexes = new int[(pg_blob.width*pg_blob.height)/2];

  int[] contour_map = new int[pg_blob.width*pg_blob.height];


  if (has_typed_something()) {
    println("starting export");

    for (int i = 0; i < allowed_chars.length; i++) {

      char c = allowed_chars[i];

      PShape shape = loadCharShape(c);

      if (shape == null) {
        continue;
      }

      the_shape_modifier(shape, c);

      scale_PShape(shape, 1.0/shape.height);
      scale_PShape(shape, pg_blob.height);

      println(pg_blob.height);

      final PShape modified_shape = shape;
      // draw on PGraphics
      pg_blob.beginDraw();
      pg_blob.background(255);


      if (c == 'a') {
        println("shape width: "+modified_shape.width);
        println("shape height: "+modified_shape.height);
        debug_print(modified_shape);
      }
      //pg_blob.strokeWeight(1);
      pg_blob.strokeWeight(1);
      pg_blob.shapeMode(CENTER);
      pg_blob.stroke(0);
      //int str_mar = 40+2;
      //pg_blob.shape(modified_shape, +str_mar, +str_mar, pg_blob.width-str_mar, pg_blob.height-str_mar);
      pg_blob.shape(modified_shape, pg_blob.width/2, pg_blob.height/2);

      // create border for blobscan
      pg_blob.noFill();
      pg_blob.stroke(255);
      pg_blob.strokeWeight(1);
      pg_blob.rect(0, 0, pg_blob.width-1, pg_blob.height-1);

      pg_blob.endDraw();

      if (DEBUG) {
        pg_blob.save("../debug/blob/"+c+".png");
      }

      pg_blob.loadPixels();

      // blobscan
      /*
      theBlobDetection.setPosDiscrimination(false);
       theBlobDetection.setThreshold(0.38f);
       theBlobDetection.computeBlobs(pg_blob.pixels);
       */



      // create the glyph
      final FGlyph glyph = f.addGlyph(c);

      glyph.setAdvanceWidth((int)modified_shape.width);

      ContourDataProcessor contour_data_processor = new ContourDataProcessor() {

        public boolean process(ContourData contour_data) {
          //create a contour
          PVector[] contour = new PVector[contour_data.n_of_corners];
          for (int i = 0; i < contour_data.n_of_corners; i++) {
            int index = contour_data.corner_indexes[i];
            float x = index % pg_blob.width;
            float y = (index - x) / pg_blob.width;
            // normalise
            x /= pg_blob.width;
            y /= pg_blob.height;
            y = 1-y; // flip upside down

            x *= modified_shape.width;
            y *= modified_shape.height;

            contour[i] = new PVector(x * 500, y * 500);
          }

          // douglass peucker goes here
          // ...
          glyph.addContour(contour);

          return true; // true means continue scanning
        }
      };

      int y_increment = 5;

      BlobScanner.scan(
        pg_blob.pixels, pg_blob.width, pg_blob.height, 
        0, 0, pg_blob.width, pg_blob.height, 
        y_increment, 
        thresholdChecker, 
        contour_map, 
        scan_id++, 
        contour_data, 
        contour_data_processor);
    }

    // finish exporting font

    f.buildFont();                                  // Build the font resulting in .ttf and .woff files
    // and a HTML template to preview the WOFF
    //How to clean up afterwards:

    f.cleanup();                  // Deletes all the files that doubletype created, except the .ttf and
    // .woff files and the HTML template
  }
}
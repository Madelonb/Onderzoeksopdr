/**
 * Created by madelonbalk on 18-04-16.
 */
import processing.core.*;
import blobDetection.*;
import fontastic.*;

/**
 * Created by madelonbalk on 31-03-16.
 */
public class Ma_01 extends PApplet {

    public static void main(String[] args) {
        PApplet.main("Ma_01", args);
    }


    BlobDetection theBlobDetection;
    PGraphics img;
    PShape s;

    Fontastic f;  // Create a new Fontastic object

    boolean export;

    public void settings() {
        size(640, 480);
    }

    public void setup() {
        //createFont();
    }

    public void draw() {
        if (export) {
            f = new Fontastic(this, "MadelonIIFont");
            f.setAuthor("Madelon Balk");
        }


        img = createGraphics(640, 480);

        img.beginDraw();
        img.background(255);
        img.stroke(0);
        img.strokeWeight(100);
        img.noFill();
        s = img.loadShape("e-02.svg");
        editCharacter(s);
        img.shape(s, 100, 100, 100, 100);
        img.endDraw();

        image(img, 0, 0, width, height);

        if (export) {

            theBlobDetection = new BlobDetection(img.width, img.height);
            theBlobDetection.setPosDiscrimination(false);
            theBlobDetection.setThreshold(0.38f);
            theBlobDetection.computeBlobs(img.pixels);

            drawBlobsAndEdges(true, true);

            FGlyph glyph = f.addGlyph('A');

            for (int n=0; n<theBlobDetection.getBlobNb(); n++) {
                Blob b = theBlobDetection.getBlob(n);
                if (b!=null) {
                    PVector[] vecs = blob_to_PVector_array(b);
                    for (PVector v : vecs) {
                        v.x *= img.width;
                        v.y *= img.height;

                    }
                    glyph.addContour(vecs);
                }
                println();
            }

            f.buildFont();                                  // Build the font resulting in .ttf and .woff files
            // and a HTML template to preview the WOFF
            //How to clean up afterwards:

            f.cleanup();                  // Deletes all the files that doubletype created, except the .ttf and
            // .woff files and the HTML template


            export = false;
        }
        //noLoop();

    }



    void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
    {
        noFill();
        Blob b;
        EdgeVertex eA, eB;
        for (int n=0; n<theBlobDetection.getBlobNb(); n++)
        {
            b=theBlobDetection.getBlob(n);
            if (b!=null)
            {
                // Edges
                if (drawEdges)
                {
                    strokeWeight(2);
                    stroke(0, 255, 0);
                    for (int m=0; m<b.getEdgeNb(); m++)
                    {
                        eA = b.getEdgeVertexA(m);
                        eB = b.getEdgeVertexB(m);
                        if (eA !=null && eB !=null)
                            line(
                                    eA.x*width, eA.y*height,
                                    eB.x*width, eB.y*height
                            );
                    }
                }

                // Blobs
                if (drawBlobs)
                {
                    strokeWeight(1);
                    stroke(255, 0, 0);
                    rect(
                            b.xMin*width, b.yMin*height,
                            b.w*width, b.h*height
                    );
                }
            }
        }
    }



    void editCharacter(PShape s) {

        s.disableStyle();


        for (int i = 0; i < s.getVertexCount(); i++) {

            PVector v = s.getVertex(i);
            //v.x += random(-5, 5);
            //v.y += random(-5, 5);
            //ellipse(v.x, v.y, 2, 2);
            println("points"+i);
            text(""+i, v.x, v.y);
            if (i == 8) {
                v.x = v.x + (mouseX-100);
                v.y = v.y + (mouseY-100);
            }

            if (i == 10) {
                v.x = v.x + (mouseX-100);
                v.y = v.y + (mouseY-100);
            }

            if (i == 9) {
                v.x = v.x + (mouseX-100);
                v.y = v.y + (mouseY-100);
            }

            s.setVertex(i, v.x, v.y);

            noFill();
            strokeWeight(50);
            stroke(0);
        }

        if (s.getChildCount() > 0) {
            for (int i = 0; i < s.getChildCount(); i++) {
                editCharacter(s.getChild(i));
            }
        }
    }


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
/*
void createFont() {

 println("create font");
 f = new Fontastic(this, "ExampleFont");

 f.setAuthor("Madelon Balk");                  // Set author name - will be saved in TTF file too
 //How to create a glyph for the character A with a random shape of four points:



 //f.addGlyph('A').addContour(points);             // Assign contour to character A
 //How to generate the TrueType font file:

 f.buildFont();                                  // Build the font resulting in .ttf and .woff files
 // and a HTML template to preview the WOFF
 //How to clean up afterwards:

 f.cleanup();                  // Deletes all the files that doubletype created, except the .ttf and
 // .woff files and the HTML template
 }
 */

    public void keyPressed() {
        if (key == 'e') {
            //createFont();
            export = true;
        }
    }


}

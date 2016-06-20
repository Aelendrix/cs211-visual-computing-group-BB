import processing.video.*;
import java.util.Collections;
import java.util.*; 
class ImageProcessing extends PApplet {
  PImage img;
  PImage n;
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  //pgraphics used to resize the lines and the image
  PGraphics pg;
  PVector angles = new PVector(0,0,0);
  //video remplacing the webcam
  Movie cam;
  //Capture cam;
  //used to load the PImage
  
  //parameter changing the data of the windows
  boolean debug;
  public ImageProcessing(boolean debug)
  {
    img = new PImage();
    this.debug=debug;
  }
  
  void settings() {
    if(debug)
    size(1100, 300);
    else
    size(400,300);
  }

  void setup() {
    //cam = new Capture(this,cameras[0]);
    //cam.start();
    cam = new Movie(this, "C:/Users/Nicolas/Desktop/Epfl/Semestre_3_4_2015-2016/Semestre_4/Info Visuelle/Git/Game-new-after-rendu/TangibleGame/testvideo.mp4");
    cam.loop();
    pg = createGraphics(800, 600);
    float ang = 0;

    //calculate the precomputed sin and cos for the hough method
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
  }

  void draw() {
    cam.read();
    img = cam.get();
    img.resize(800,600);
    background(0);

    pg.beginDraw();
    pg.background(0);
    
    pg.image(img, 0, 0);
    //filter the image in function of hue,brightness and saturation
    //good parameters 115 23 70 20
    PImage resultHue = hueFilter(img, 115, 23, 70, 20);
    //blur the filtered image
    float[][] blur = { { 1, 1, 1 }, { 1, 1, 1 }, { 1, 1, 1 } };
    PImage resultBlurred = convolute(resultHue, blur, 50f);
    //filter the resulting black and white image using the brightness
    PImage resultBrightness = brightnessThreshold(resultBlurred, 15);
    //sobel image edge filter
    PImage result = sobel(resultBrightness);
    //print the resulted image
    image(result, 700, 0, 400, 300);
    //detects the edges of the image and return the n bests computed lines
    ArrayList<PVector> duples = hough(result, 5);

    //detects the intersections of the lines and add them to pg
    getIntersections(duples);
    //calcule quads
    List<PVector> corners = computeQuad(img, duples);
    //displayQuads(quads,duples);
    if (corners.size()==4)
    {
      TwoDThreeD twoDthreeD = new TwoDThreeD(img.height, img.width);
      angles = twoDthreeD.get3DRotations(corners);
      //println(" "+angles.x*360/(2*PI)+" "+angles.y*360/(2*PI)+" "+angles.z*360/(2*PI));
    }
    //finish to draw the image with line and resize them
    pg.endDraw();
    if(debug)
    image(pg, 0, 0, 400, 300);
    else
    image(img,0,0,400,300);
  }
  
  //getter function of the angles
  public PVector getRot(){
    return angles;
  }

  //Compute the quads of the board, filtering out the convex, the flat and small quads, using the image and the set of all lines
  //return the corners of the best quad
  private List<PVector> computeQuad(PImage image, ArrayList<PVector> lines) {
    //create a quadGraph
    QuadGraph quadGraph = new QuadGraph(lines, image.width, image.height);
    //find all the cycle of size 4
    List<int[]> quads = quadGraph.findCycles();
    //ArrayList<int[]> resultsQuad = new ArrayList<int[]>();
    //for all the quads found, filter out the bad quads
    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      //board2.jpg area = 109000    board3.jpg area = 515000       (bigger and smaller in our samples)
      if (quadGraph.isConvex(c12, c23, c34, c41)&&quadGraph.nonFlatQuad(c12, c23, c34, c41)&&quadGraph.validArea(c12, c23, c34, c41, 800000, 40000))
      {
        ArrayList<PVector> corners = new ArrayList<PVector>();
        corners.add(c12);
        corners.add(c23);
        corners.add(c34);
        corners.add(c41);
        return quadGraph.sortCorners(corners);
      }
    }
    return new ArrayList<PVector>();
  }


  //print on screen the quads given in parameters
  private void displayQuads(ArrayList<int[]> quads, ArrayList<PVector> lines)
  {

    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      // (intersection() is a simplified version of the
      // intersections() method you wrote last week, that simply
      // return the coordinates of the intersection between 2 lines)
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      // Choose a random, semi-transparent colour
      Random random = new Random();
      pg.fill(color(min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 100));
      pg.quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
    }
  }


  //function filtering the pixels of an image depending of b, pixel is white when b<brightness<255
  PImage brightnessThreshold(PImage img, float b)
  {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) 
    {
      if (brightness(img.pixels[i])>b) {
        result.pixels[i]= color(255, 255, 255);
      } else {
        result.pixels[i]= color(0, 0, 0);
      }
    }
    return result;
  }


  //function filtering image where m-d<hue<m+d for each pixel,s<saturation and b<brightness<255-b
  PImage hueFilter(PImage img, float m, float d, float s, float b)
  {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) 
    {
      if (hue(img.pixels[i])<m+d&&hue(img.pixels[i])>m-d&&s<saturation(img.pixels[i])&&brightness(img.pixels[i])>b&&brightness(img.pixels[i])<255-b&&i%img.width>60) {
        result.pixels[i]= color(255, 255, 255);
      } else {
        result.pixels[i]= color(0, 0, 0);
      }
    }
    return result;
  }


  //convolution of an image img using a matrix 3X3
  private PImage convolute(PImage img, float[][] kernel, float weight) {
    //float weight = 1.f;
    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);
    // kernel size N = 3
    //
    // for each (x,y) pixel in the image:
    // - multiply intensities for pixels in the range
    // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
    // corresponding weights in the kernel matrix
    // - sum all these intensities and divide it by the weight
    // - set result.pixels[y * img.width + x] to this value

    for (int i = 0; i < img.width * img.height; i++) 
    {
      //look if it's not on the edge of the image
      if (i/img.width != 0 && i/img.width != img.height-1 && i%img.width != 0 && i%img.width != img.width-1)
      {
        float Sum = 0;
        Sum+=brightness(img.pixels[i-1])*kernel[1][0];
        Sum+=brightness(img.pixels[i])*kernel[1][1];
        Sum+=brightness(img.pixels[i+1])*kernel[1][2];
        Sum+=brightness(img.pixels[i-1-img.width])*kernel[0][0];
        Sum+=brightness(img.pixels[i-img.width])*kernel[0][1];
        Sum+=brightness(img.pixels[i+1-img.width])*kernel[0][2];
        Sum+=brightness(img.pixels[i-1+img.width])*kernel[2][0];
        Sum+=brightness(img.pixels[i+img.width])*kernel[2][1];
        Sum+=brightness(img.pixels[i+1+img.width])*kernel[2][2];
        //float tot = kernel[0][0] + kernel[0][1] + kernel[0][2] + kernel[1][0] + kernel[1][1] + kernel[1][2] + kernel[2][0] + kernel[2][1] + kernel[2][2];
        int value = (int)(abs(Sum)/(weight));
        if(value>255){value = 255;}
        result.pixels[i] = color(value, value, value);
      } else
      {
        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }


  //edge detection of an image using convolution
  private PImage sobel(PImage img) {
    // 2 matrix 3x3 used for edge detection: one horizontal, one vertical
    float[][] hKernel = { { 0, 1, 0 }, 
      { 0, 0, 0 }, 
      { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 }, 
      { 1, 0, -1 }, 
      { 0, 0, 0 } };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];
    //convolute vertically and honrizontally edge detector
    PImage imgK = convolute(img, vKernel, 1f);
    PImage imgH = convolute(img, hKernel, 1f);
    //combine the 2 img in a buffer
    for (int i = 0; i < img.width * img.height; i++) 
    {
      float sum = sqrt(pow(brightness(imgH.pixels[i]), 2) + pow(brightness(imgK.pixels[i]), 2));
      if (sum>max)
      {
        max=sum;
      }
      buffer[i]= sum;
    }
    //filter the buffer and return the final image
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    return result;
  }


  //function computing the n best lines detected in an image
  private ArrayList<PVector> hough(PImage edgeImg, int nLines) {
    //threshold used to filter out non-line
    int minVotes = 150;
    //lists of the best lines
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the

          for (int phiIndex = 0; phiIndex<phiDim; phiIndex+=1)
          {
            //precomputed is already calculated with the scalar 1/discretizationstepR
            double precomputedR =x*tabCos[phiIndex]+y*tabSin[phiIndex];
            int rIndex = (int) (precomputedR + 0.5 * (rDim - 1));
            // increment the accumulator at THESE coordinates
            accumulator[(phiIndex + 1) * (rDim + 2) + rIndex] += 1;
            // Be careful: r may be negative, so you may want to center onto
            // the accumulator with something like: r += (rDim - 1) / 2
          }
        }
      }
    }
    // size of the region we search for a local maximum
    int neighbourhood = 10;
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }
    //sort the best lines first
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    //create the hough image, a graphical representation of the quality of the lines in each pixels and angles
    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(300, 300);
    houghImg.updatePixels();
    ArrayList<PVector> duples = new ArrayList<PVector>();
    //show the computed hough image
    image(houghImg, 400, 0, 300, 300);
    //show the best n lineson the image
    for (int i = 0; i < min(nLines, bestCandidates.size()); i++) {
      int idx = bestCandidates.get(i);
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      duples.add(new PVector(r, phi));
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      pg.stroke(204, 102, 0);
      pg.strokeWeight(4);
      if (y0 > 0) {
        if (x1 > 0)
          pg.line(x0, y0, x1, y1);
        else if (y2 > 0)
          pg.line(x0, y0, x2, y2);
        else
          pg.line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            pg.line(x1, y1, x2, y2);
          else
            pg.line(x1, y1, x3, y3);
        } else
          pg.line(x2, y2, x3, y3);
      }
    } 
    return duples;
  }



  //calculate the intersection of all the lines in the array and draw the points
  private ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to ’intersections’
        float d = cos(line2.y)*sin(line1.y)-cos(line1.y)*sin(line2.y);
        float x = (line2.x*sin(line1.y)-line1.x*sin(line2.y))/d;
        float y = (-line2.x*cos(line1.y)+line1.x*cos(line2.y))/d;
        intersections.add(new PVector(x, y));
        // draw the intersection
        pg.fill(255, 128, 0);
        pg.ellipse(x, y, 20, 20);
      }
    }
    return intersections;
  }


  //calculate the intesection of 2 lines
   private PVector intersection(PVector l1, PVector l2) {
    float r1 = l1.x, r2 = l2.x, p1 = l1.y, p2 = l2.y;
    float d = cos(p2) * sin(p1) - cos(p1) * sin(p2);

    int x = (int) ((r2 * sin(p1) - r1 * sin(p2)) / d);
    int y = (int) ((-r2 * cos(p1) + r1 * cos(p2)) / d);

    return new PVector(x, y);
  }
}
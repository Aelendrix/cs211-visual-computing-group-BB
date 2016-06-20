import java.awt.Polygon;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;
class BlobDetection {
Polygon quad = new Polygon();
/** Create a blob detection instance with the four corners of the Lego board.
*/
BlobDetection(PVector c1, PVector c2, PVector c3, PVector c4) {
quad.addPoint((int) c1.x, (int) c1.y);
quad.addPoint((int) c2.x, (int) c2.y);
quad.addPoint((int) c3.x, (int) c3.y);
quad.addPoint((int) c4.x, (int) c4.y);
}
/** Returns true if a (x,y) point lies inside the quad
*/
boolean isInQuad(int x, int y) {return quad.contains(x, y);}
boolean detectPixel(PImage input, int x, int y)
{
  //filter orange hue
  return hue(input.pixels[y*input.width+x])>10 && hue(input.pixels[y*input.width+x])<50;
}
ArrayList<Integer> findNeighbor(int[] label,int x,int y,int w)
{
  ArrayList result = new ArrayList<Integer>();
  if(y*w+x-1>=0&&label[y*w+x-1]!=0)
  {result.add(label[y*w+x-1]);}
  if(y*w+x+w+1>=0&&label[y*w+x+w+1]!=0)
  {result.add(label[y*w+x+w+1]);}
  if(y*w+x+w>=0&&label[y*w+x+w]!=0)
  {result.add(label[y*w+x+w]);}
  if(y*w+x+w-1>=0&&label[y*w+x+w-1]!=0)
  {result.add(label[y*w+x+w-1]);}
  return result;
}

PImage findConnectedComponents(PImage input){
// First pass: label the pixels and store labels’ equivalences
int [] labels= new int [input.width*input.height];
List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
int currentLabel=1;
for(int i=0;i<input.width;i++)
 {for(int j=0;j<input.height;j++)
 {
   if(isInQuad(i,j))
   {
     //is a orange pixel
     if(detectPixel(input,i,j))
     {
       ArrayList<Integer> neighbor = findNeighbor(labels,i,j,input.width);
       //has no neighbor
       if(neighbor.size() == 0)
       {
       labels[j*input.width+i]=currentLabel;
       currentLabel++;
       }
       //has neighbors
       else
       {
         int min=neighbor.get(0);
         int index=0;
         for(int k=0;k<neighbor.size();k++)
         {
           if(neighbor.get(k)<min)
           {min = neighbor.get(k);
           index = k;
           }
         }
         //take the smallest
         labels[j*input.width+i]=min;
         //mark the others as equivalents
         for(int k=0;k<neighbor.size();k++)
         {
           if(k!=index)
           {
             labelsEquivalences.get(min-1).add(neighbor.get(k));
           }
         }
       }
     }
     else
     {
       labels[j*input.width+i]=0;
     }
   }
 }
}
// Second pass: re-label the pixels by their equivalent class
for(int i=0;i<input.width;i++)
 {for(int j=0;j<input.height;j++)
 {
   if(labels[j*input.width+i]!=0)
   {
     int label = labels[j*input.width+i];
     for(int k=0;k<label;k++)
     {
     if(labelsEquivalences.get(k).contains(label))
     {
       labels[j*input.width+i]=k+1;
       break;
     }
     } 
   }
 }
}
// Finally, output an image with each blob colored in one uniform color.
//generate currentlabel colors for the output
ArrayList<PVector> randColor= new ArrayList<PVector>();
for(int k = 0; k<currentLabel;k++)
{
  randColor.add(new PVector((int)Math.random()*255,(int)Math.random()*255,(int)Math.random()*255));
}

//change the color of the blobs in the pixels of inputs
for(int i=0;i<input.width;i++)
 {for(int j=0;j<input.height;j++)
 {
   int colorIndex = labels[j*input.width+i];
   if(colorIndex!=0)
   {
   input.pixels[j*input.width+i] = color(randColor.get(colorIndex).x,randColor.get(colorIndex).y,randColor.get(colorIndex).z);
   }
 }
}
input.updatePixels();
return input;
}
}
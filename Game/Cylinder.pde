class Cylinder
{
  //cylindre
  float cylinderBaseSize;
  float cylinderHeight;
  int cylinderResolution;
  PShape cyl = createShape(GROUP);
  PShape body = new PShape();
  PShape head = new PShape();
  PShape tail = new PShape();
  
  Cylinder(float cylinderBaseSize,float cylinderHeight, int cylinderResolution)
  {
    this.cylinderBaseSize = cylinderBaseSize;
    this.cylinderHeight = cylinderHeight;
    this.cylinderResolution = cylinderResolution;
    fill(255,0,0);
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] z = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      z[i] = cos(angle) * cylinderBaseSize;
    }
    body = createShape();
    body.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      body.vertex(x[i], 0 , z[i]);
      body.vertex(x[i], cylinderHeight, z[i]);
    }
    body.endShape();
    //top part of the cylinder
    head = createShape();
    head.beginShape(TRIANGLE_FAN);
    head.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      head.vertex(x[i], 0, z[i]);
    }
    head.endShape();
    //bottom part of the cylinder
    tail = createShape();
    tail.beginShape(TRIANGLE_FAN);
    tail.vertex(0, cylinderHeight, 0 );
    for (int i = 0; i < x.length; i++) {
      tail.vertex(x[i], cylinderHeight, z[i]);
    }
    tail.endShape();
    
    cyl.addChild(head);
    cyl.addChild(body);
    cyl.addChild(tail);
  }
  
  PShape getShape()
  {
    return cyl;
  }
}
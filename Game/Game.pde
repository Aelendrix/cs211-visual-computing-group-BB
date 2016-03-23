float depth = 2000;

//rotation variables
float rz = 0;
float rx = 0;

//mouseDragged variable to calculate the rotation variables
float frz = 0;
float frx = 0;
int posX = 0;
int posY = 0;

//speed MouseWheel()
float speed = 1;
//sphere radius
int sphereR = 50;
//plan
float planX = 1500;
float planY = 50;
float planZ = 1500;
//ball
Mover mover;
//cylinder
Cylinder cylinder;
float cylinderBaseSize = 100;
float cylinderHeight = 200;
int cylinderResolution = 40;

//Mode: false = normal, true = cylinder creator
boolean stop = false;

//Position of all cylinder
ArrayList<PVector> cylinderPos = new ArrayList<PVector>();
//PFont f; 


void settings() {
  size(600, 600, P3D);
}
void setup() {
  noStroke();
  //main class of the ball
  mover = new Mover();
  //create one cylinder to have access to his PShape
  cylinder = new Cylinder(cylinderBaseSize,cylinderHeight,cylinderResolution);
  //f = createFont("Arial",32,true);
}
void draw() {
  //fill(255);
  //textFont(f,16); 
  //fill(100,0,0);
  //text("Kappa", 200, 100);
  
  //basic setup to each frame
  fill(255);
  background(200);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  //X axis red
  fill(255, 0, 0);
  box(3000, 10, 10);
  //Z axis blue
  fill(0, 0, 255);
  box(10, 10, 3000);
  //change camera pos depending of the mode: [Place Cylinder or normal]
  if (stop)
  {
    camera(0, -height*10, 1, 0, 0, 0, 0, 1, 0);
    ortho(-planX,planX,-planZ,planZ);
  } else {
    camera(0, -height*3, depth, 0, 0, 0, 0, 1, 0);
    perspective();
    rotateZ(rz);
    rotateX(rx);
  }
  //plan
  fill(255);
  box(planX, planY, planZ);
  
  //velocity,location,drawing,and collision of the main ball in the mover Class
  if (!stop)
  {
    mover.checkCylinderCollision(cylinderPos,cylinderBaseSize);
    mover.checkEdges();
    mover.update();
  }
  mover.display();
  
  //draw all the cylinder
  for (int i = 0; i<cylinderPos.size(); i++)
  {
    pushMatrix();
    translate(cylinderPos.get(i).x, -cylinderHeight-planY/2, cylinderPos.get(i).y);
    shape(cylinder.getShape());
    popMatrix();
  }
}
//calculate the total rotation of the system, depending of mousePressed()
void mouseDragged() {

  if (!stop) {
    rx = frx - (mouseY-posY)*speed*3*(PI/3)/(height);
    rz = frz + (mouseX-posX)*speed*3*(PI/3)/(width);
    if (rx<-PI/3) {
      rx=-PI/3;
    }
    if (rx>PI/3) {
      rx=PI/3;
    }
    if (rz<-PI/3) {
      rz=-PI/3;
    }
    if (rz>PI/3) {
      rz=PI/3;
    }
  }
}

//save the actual data of the mousepressed
void mousePressed() {
  posX = mouseX;
  posY = mouseY;
  frx = rx;
  frz = rz;
}

void mouseClicked() {
  //create new cylinder
  if (stop)
  {
    float px=map(mouseX-height/2,-height/2,height/2,-planX,planX);
    float py=map(mouseY-width/2,-width/2,width/2,-planZ,planZ);
    //check if it is in the plate
    if(-planX/2<px&&-planZ/2<py&&planX/2>px&&planZ/2>py)
    {
    cylinderPos.add(new PVector(px, py));
    }
  }
}

//set the speed of the whole rotation
void mouseWheel(MouseEvent event) {
  if (event.getCount()>0)
  {
    speed -= 0.1;
  } else if (event.getCount()<0)
  {
    speed += 0.1;
  }
  if (speed<0.2) {
    speed=0.2;
  }
  if (speed>1.5) {
    speed=1.5;
  }
}
//check if it is in "Place Cylinder Mode"
void keyPressed()
{
  if (keyCode == SHIFT)
  {
    stop = true;
  }
}
//check if it is in normal mode
void keyReleased()
{
  if (keyCode == SHIFT)
  {
    stop = false;
  }
}
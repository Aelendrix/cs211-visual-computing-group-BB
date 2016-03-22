float depth = 2000;
int posX = 0;
int posY = 0;
float frz = 0;
float frx = 0;
float rz = 0;
float rx = 0;
float vx = 0;
float vz = 0;
float speed = 1;
int sphereR = 50;
float sphereX = 0;
float sphereZ = 0;
float planX = 1500;
float planY = 50;
float planZ = 1500;

float dt = 0.01;
int gravityConstant=10;
PVector friction;
PVector gravityForce;
PVector ballLocation = new PVector(0, -(planY/2+sphereR), 0);
PVector ballVelocity = new PVector(0, 0, 0);
float normalForce = 1;
float mu = 0.01;
float frictionMagnitude = normalForce * mu;

//PFont f; 

void settings() {
  size(600, 600, P3D);
}
void setup() {
  noStroke();
  //f = createFont("Arial",32,true);
}
void draw() {
  //fill(255);
  //textFont(f,16); 
  //fill(100,0,0);
  //text("Kappa", 200, 100);
  fill(255);
  camera(0 , -height*3, depth, 0, 0, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  rotateZ(rz);
  rotateX(rx);
  //plan
  box(planX, planY, planZ);
  //X red
  fill(255, 0, 0);
  box(3000, 10, 10);
  //Y green
  fill(0, 255, 0);
  box(10, 3000, 10);
  //Z blue
  fill(0, 0, 255);
  box(10, 10, 3000);
  pushMatrix();
  calculateBallLocation();
  fill(100, 100, 100);
  translate(ballLocation.x, ballLocation.y, ballLocation.z);
  sphere(sphereR);
  popMatrix();
}

void mouseDragged() {

  
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

void mousePressed() {
  posX = mouseX;
  posY = mouseY;
  frx = rx;
  frz = rz;
}

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

void calculateBallLocation()
{
  gravityForce = new PVector(sin(rz) * gravityConstant, 0, -sin(rx) * gravityConstant);
  ballVelocity.x += gravityForce.x*dt;
  ballVelocity.y += gravityForce.y*dt;
  ballVelocity.z += gravityForce.z*dt;
  friction = ballVelocity.copy();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);
  
  ballVelocity = ballVelocity.add(friction);
  ballLocation.add(ballVelocity);
  if (ballLocation.x >= planX/2 ) {
    ballLocation.x = planX/2;
    ballVelocity.x *= -0.4;
  }
  if (ballLocation.x < -planX/2 ) {
    ballLocation.x = -planX/2;
    ballVelocity.x *= -0.4;
  }
  if (ballLocation.z > planZ/2 ) {
    ballLocation.z = planZ/2;
    ballVelocity.z *= -0.4;
  }
  if (ballLocation.z < -planZ/2 ) {
    ballLocation.z = -planZ/2;
    ballVelocity.z *= -0.4;
  }
  
}
class Mover {

  float dt = 0.01;
  int gravityConstant=10;
  PVector friction;
  PVector gravityForce;
  PVector ballLocation = new PVector(0, -(planY/2+sphereR), 0);
  PVector ballVelocity = new PVector(0, 0, 0);
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;

  void checkEdges()
  {
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
  void checkCylinderCollision(ArrayList<PVector>cylinderPos,float size)
  {
    boolean collision = false;
    PVector p = new PVector(0,0);
     for(int i=0;i<cylinderPos.size();i++)
     {
       p.x=ballLocation.x+ballVelocity.x-cylinderPos.get(i).x;
       p.y=ballLocation.z+ballVelocity.z-cylinderPos.get(i).y;
       collision =  sphereR+size> p.mag();
       if(collision)
       {
         PVector v1=new PVector(ballVelocity.x,ballVelocity.z);
         PVector n = p.copy().normalize();
         //formule du cours
         PVector v2 = v1.sub(n.mult(v1.dot(n)).mult(2));
         ballVelocity.x = v2.x;
         ballVelocity.z = v2.y;
       }
     }
  }
  void update()
  {
    gravityForce = new PVector(sin(rz) * gravityConstant, 0, -sin(rx) * gravityConstant);
    ballVelocity.add(gravityForce.mult(dt));
    friction = ballVelocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    ballVelocity = ballVelocity.add(friction);
    ballLocation.add(ballVelocity);
  }
  void display() {
    pushMatrix();
    fill(100, 100, 100);
    translate(ballLocation.x, ballLocation.y, ballLocation.z);
    sphere(sphereR);
    popMatrix();
  }
}
//valeur de rotation
float rx;
float ry;
float speed = 0.1;
int size = 100;
boolean val[]={false, false, false, false};//touche activé quand = true; dans l'ordre: UP,DOWN,RIGHT,LEFT
void settings() {
  size (400, 400, P3D);
}
void setup() {
}
void draw() {
  update();
  camera(400, 0, 0, 0, 0, 0, 0, 1, 0);
  background(255);
  rotateX(rx);
  rotateY(ry);
  fill(200);
  box(size);
}
//update les variables de rotation en fonction des touches pressées actuellement
void update(){
if(val[0])
{
  rx+=speed;
}
if(val[1])
{
  rx-=speed;
}
if(val[2])
{
  ry+=speed;
}
if(val[3])
{
  ry-=speed;
}
}
//active les touches pressées dans le tableau val
void keyPressed() {
  if (keyCode==LEFT)
  {
    val[3]=true;
  }
  if (keyCode==RIGHT)
  {
    val[2]=true;
  }
  if (keyCode==UP)
  {
    val[0]=true;
  }
  if (keyCode==DOWN)
  {
    val[1]=true;
  }
}
//désactive les touches "released" dans le tableau val
void keyReleased() {
  if (keyCode==LEFT)
  {
    val[3]=false;
  }
  if (keyCode==RIGHT)
  {
    val[2]=false;
  }
  if (keyCode==UP)
  {
    val[0]=false;
  }
  if (keyCode==DOWN)
  {
    val[1]=false;
  }
}
import processing.video.*;

class WebCam extends PApplet{
    Capture cam;
  void setup()
  {
    String[] cameras = Capture.list();
  if (cameras.length == 0) {
  println("There are no cameras available for capture.");
  } else {
  println("Available cameras:");
  for (int i = 0; i < cameras.length; i++) {
  println(cameras[i]);
  }
  cam = new Capture(this,cameras[0]);
  cam.start();
  }
  }
  
  
  
  void draw()
  {
    if (cam.available() == true) {
  cam.read();
  }
  image(cam.get(),0,0);
  }
  
}
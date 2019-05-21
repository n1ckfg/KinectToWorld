import peasy.PeasyCam;

PeasyCam cam;

void setupCam() {
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*100.0);  

  cam = new PeasyCam(this, 1200);
}

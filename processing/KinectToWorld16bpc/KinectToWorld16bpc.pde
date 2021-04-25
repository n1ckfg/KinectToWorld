String cameraType = "Structure";
int pointSize = 4;
int pointAlpha = 200;

PImage imgDepthNorm;
PShape shp;
KinectConverter kc;
RgbXyz rgbxyz;

boolean doFileLoop = true;
boolean doInpainting = true;

void setup() {
  size(800, 600, P3D);
  chooseFolderDialog();
  
  kc = new KinectConverter(cameraType);

  setupCam();  
}

void draw() {
  if (firstRun) {
    filesLoadedChecker();
  } else {
    background(0);
    
    pushMatrix();
    shape(shp, 0, 0);// -width/2, -height/2);
    popMatrix();
    
    if (doFileLoop) fileLoop();

    surface.setTitle("" + frameRate);
  }
}

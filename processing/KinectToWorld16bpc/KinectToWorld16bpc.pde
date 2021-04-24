String cameraType = "Structure";
int pointSize = 4;
int pointAlpha = 200;

PImage imgDepthNorm;
PShape shp;
KinectConverter kc;
RgbXyz rgbxyz;
 
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
    shape(shp, -width/2, -height/2);

    fileLoop();

    surface.setTitle("" + frameRate);
  }
}

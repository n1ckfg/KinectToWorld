String cameraType = "Structure";
String fileName = "living_room.png";
int pointSize = 4;
int pointAlpha = 200;

PImage img, imgRgb, imgDepth;
PShape shp;
KinectConverter kc;
RgbXyz rgbxyz;

void setup() {
  size(800, 600, P3D);
  
  kc = new KinectConverter(cameraType);

  setupCam();
  
  img = loadImage(fileName);
  imgRgb = img.get(640,120,640,480);
  imgRgb.loadPixels();
  imgDepth = img.get(0,120,640,480);
  
  imgDepth = kc.depthFilter(imgDepth);
  
  imgDepth.loadPixels();

  shp = createShape();
  shp.beginShape(POINTS);
  shp.strokeWeight(pointSize);
  for (int y=0; y<imgRgb.height; y++) {
    for (int x=0; x<imgRgb.width; x++) {
      int loc = x + y * imgRgb.width;
      color c = imgRgb.pixels[loc];
      float z = red(imgDepth.pixels[loc]);
      shp.stroke(c, pointAlpha);
      
      PVector p = kc.convertDepthToWorld(x, y, z);
      shp.vertex(p.x, p.y, p.z);
    }
  }
  shp.endShape();
  
  rgbxyz = new RgbXyz(imgRgb, shp);
}

void draw() {
  background(0);
  shape(shp, -width/2, -height/2);
  
  surface.setTitle("" + frameRate);
}

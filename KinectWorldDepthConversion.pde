
PImage img, imgRgb, imgDepth;
PShape shp;
KinectConverter kc;

void setup() {
  size(800, 600, P3D);
  kc = new KinectConverter("Structure");

  setupCam();
  
  img = loadImage("hallway.png");
  imgRgb = img.get(640,120,640,480);
  imgRgb.loadPixels();
  imgDepth = img.get(0,120,640,480);
  imgDepth.loadPixels();

  shp = createShape();
  shp.beginShape(POINTS);
  shp.strokeWeight(10);
  for (int y=0; y<imgRgb.height; y++) {
    for (int x=0; x<imgRgb.width; x++) {
      int loc = x + y * imgRgb.width;
      color c = imgRgb.pixels[loc];
      float z = red(imgDepth.pixels[loc]);
      shp.stroke(c, 127);
      
      PVector p = kc.convertDepthToWorld(x, y, z);
      shp.vertex(p.x, p.y, p.z);
    }
  }
  shp.endShape();
  
}

void draw() {
  background(0);
  shape(shp, -width/2, -height/2);
  
  surface.setTitle("" + frameRate);
}

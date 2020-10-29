PImage imgRgb, imgDepth;
PShape shp;
int pointSize = 4;
int pointAlpha = 200;
float scaler = 300;

void setup() {
  size(800, 600, P3D);
  setupCam();
  
  imgRgb = loadImage("output_rgb.png");
  imgRgb.loadPixels();
  imgDepth = loadImage("output_depth.png");
  imgDepth.loadPixels();  
  
  if (imgRgb.pixels.length != imgDepth.pixels.length) {
    println("Error, pixel counts don't match.");
    exit();
  }
  
  shp = createShape();
  shp.beginShape(POINTS);
  shp.strokeWeight(pointSize);
  for (int i=0; i<imgRgb.pixels.length; i++) {
      color c = imgRgb.pixels[i];
      shp.stroke(c, pointAlpha);

      PVector p = getXyzFromRgb(imgDepth.pixels[i], scaler);
      shp.vertex(p.x, p.z, p.y);
  }
  shp.endShape();
}

void draw() {
  background(0);
  shape(shp, -width/2, -height/2);
  
  surface.setTitle("" + frameRate);
}

PVector getXyzFromRgb(color _c, float _scaler) {
  float x = red(_c) / 255;
  float y = green(_c) / 255;
  float z = blue(_c) / 255;
  return new PVector(x, y, z).mult(_scaler);
}

class RgbXyz {
  
  ArrayList<RgbXyzPoint> points;
  PImage rgbImg, depthImg;
  int dimW, dimH;
  
  RgbXyz(int _dimW, int _dimH) {
    points = new ArrayList<RgbXyzPoint>();
    init(_dimW, _dimH);
  }
  
  RgbXyz(int _dimW, int _dimH, ArrayList<RgbXyzPoint> _points) {
    points = _points;
    init(_dimW, _dimH);
  }
  
  RgbXyz(PImage _img, PShape _shp) {
    if (_img.pixels.length != _shp.getVertexCount()) {
      println("ERROR pixel and vertex counts don't match");
      return;
    }
    
    _img.loadPixels();
    points = new ArrayList<RgbXyzPoint>();

    for (int i=0; i<_img.pixels.length; i++) {
      color c = _img.pixels[i];
      PVector p = _shp.getVertex(i);
      addPoint(c, p);  
    }
    
    init(_img.width, _img.height);
  }
  
  void init(int _dimW, int _dimH) {
    dimW = _dimW;
    dimH = _dimH;
    
    rgbImg = createImage(dimW, dimH, RGB);
    rgbImg.loadPixels();
    
    depthImg = createImage(dimW, dimH, RGB);
    depthImg.loadPixels();
  }

  boolean renderImage() { 
      println("points: " + points.size() + ", rgb: " + rgbImg.pixels.length + ", depth: " + depthImg.pixels.length);
    if (points.size() != rgbImg.pixels.length || points.size() != depthImg.pixels.length) {
      println("Error rendering images.");
      return false;
    }
    
    for(int i=0; i<points.size(); i++) {
      RgbXyzPoint p = points.get(i);        
      rgbImg.pixels[i] = color(p.r*255, p.g*255, p.b*255);
    }
    rgbImg.updatePixels();
    
    for(int i=0; i<points.size(); i++) {
      RgbXyzPoint p = points.get(i);   
      depthImg.pixels[i] = color(p.x*255, p.z*255, p.y*255);
    }
    depthImg.updatePixels();
    
    println("Rendered images.");
    return true;
  }
  
  void saveImage() {
    depthImg.save("render/output_depth.png");
    rgbImg.save("render/output_rgb.png");
    
    println("Saved images.");
  }
  
  void writeAll() {
    normalizeAll();
    
    if (renderImage()) {
      saveImage();
    } else {
      println("No images saved.");
    }
  }

  void addPoint(color _c, PVector _p) {
    points.add(new RgbXyzPoint(red(_c), green(_c), blue(_c), _p.x, _p.y, _p.z));    
  }
  
  void addPoint(float _r, float _g, float _b, float _x, float _y, float _z) {
    points.add(new RgbXyzPoint(_r, _g, _b, _x, _y, _z));    
  }
  
  void addPoint(color _c, float _x, float _y, float _z) {
    points.add(new RgbXyzPoint(red(_c), green(_c), blue(_c), _x, _y, _z));    
  }
  
  void addPoint(float _r, float _g, float _b, PVector _p) {
    points.add(new RgbXyzPoint(_r, _g, _b, _p.x, _p.y, _p.z));    
  }

  void normalizeAll() {
    float minR = 0;
    float maxR = 0;
    float minG = 0;
    float maxG = 0;
    float minB = 0;
    float maxB = 0;
    
    float minX = 0;
    float maxX = 0;
    float minY = 0;
    float maxY = 0;
    float minZ = 0;
    float maxZ = 0;
    
    for(int i=0; i<points.size(); i++) {
      RgbXyzPoint p = points.get(i);
      
      minR = compareMin(minR, p.r);
      maxR = compareMax(maxR, p.r);     
      minG = compareMin(minG, p.g);
      maxG = compareMax(maxG, p.g);
      minB = compareMin(minB, p.b);
      maxB = compareMax(maxB, p.b);

      minX = compareMin(minX, p.x);
      maxX = compareMax(maxX, p.x);
      minY = compareMin(minY, p.y);
      maxY = compareMax(maxY, p.y);
      minZ = compareMin(minZ, p.z);
      maxZ = compareMax(maxZ, p.z);

      println("Measured " + (i+1) + " / " + points.size());
    }
    
    for (int i=0; i<points.size(); i++) {
      RgbXyzPoint p = points.get(i);
  
      p.r = map(p.r, minR, maxR, 0, 1);
      p.g = map(p.g, minG, maxG, 0, 1);
      p.b = map(p.b, minB, maxB, 0, 1);

      p.x = map(p.x, minX, maxX, 0, 1);
      p.y = map(p.y, minY, maxY, 0, 1);
      p.z = map(p.z, minZ, maxZ, 0, 1);
      
      println("Normalized " + (i+1) + " / " + points.size());
    }
  }
  
  float compareMin(float min, float val) {
    if (val < min) {
      return val;
    } else {
      return min;
    }
  }
  
  float compareMax(float max, float val) {
    if (val > max) {
      return val;
    } else {
      return max;
    }
  }
  
}

class RgbXyzPoint {

  float r;
  float g;
  float b;
  float x;
  float y;
  float z;
  
  RgbXyzPoint(float _r, float _g, float _b, float _x, float _y, float _z) {
    r = _r;
    g = _g;
    b = _b;
    
    x = _x;
    y = _y;
    z = _z;    
  }
  
}

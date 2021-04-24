import gab.opencv.*;
import org.opencv.photo.Photo;
import org.opencv.imgproc.Imgproc;

boolean doInpainting = true;
int threshold = 5;
PGraphics canvas;
OpenCV opencv, mask;

void initInpainter() {
  canvas = createGraphics(img.width, img.height, P2D);
  mask = new OpenCV(this, canvas.width, canvas.height);
  canvas.beginDraw();
  canvas.background(0); 
  canvas.endDraw();
  canvas.loadPixels();
}

PImage runInpainter(PImage _img, boolean updateMask) {
  opencv = new OpenCV(this, _img, true);
  
  if (updateMask) {
    canvas.beginDraw();
    _img.loadPixels();
    for (int i=0; i<canvas.pixels.length; i++) {
      if (brightness(_img.pixels[i]) < threshold) {
        canvas.pixels[i] = color(255);
      } else {
        canvas.pixels[i] = color(0);
      }
    }  
    canvas.updatePixels();
    canvas.endDraw();
    mask.loadImage(canvas);
  }
 
  Imgproc.cvtColor(opencv.getColor(), opencv.getColor(), Imgproc.COLOR_BGRA2BGR);
  Photo.inpaint(opencv.getColor(), mask.getGray(), opencv.getColor(), 5.0, Photo.INPAINT_NS);
  Imgproc.cvtColor(opencv.getColor(), opencv.getColor(), Imgproc.COLOR_BGR2BGRA);

  return opencv.getOutput();
}

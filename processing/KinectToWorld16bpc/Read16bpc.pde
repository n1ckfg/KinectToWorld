// https://discourse.processing.org/t/16bit-grayscale-images/10795/3
// https://processing.org/discourse/beta/num_1211845881.html
// https://docs.oracle.com/javase/7/docs/api/java/awt/image/BufferedImage.html#TYPE_USHORT_GRAY

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.DataBufferUShort;
import javax.imageio.ImageIO;

class Read16bpc {
 
  BufferedImage bImg, bImgCropped;
  short[] bPixels, bPixelsCropped;
  PImage img, imgCropped;
  
  int minVal;
  int maxVal;
  float minValF;
  float maxValF;

  Read16bpc(String _url) {
    minVal = 0;
    maxVal = 0;
    try {
        //bImg = ImageIO.read(new File(dataPath(""), _url));
        bImg = ImageIO.read(new File(_url));
    } catch (IOException e) {
        e.printStackTrace();
    }

    bPixels = getBImagePixels(bImg);

    bImgCropped = cropBImage(bImg, 0, 120, 640, 480);
    bPixelsCropped = getBImagePixels(bImgCropped);

    bImageToPImage();
    bImageNormToPImage();
  }
  
  void bImageNormToPImage() {
    for (int i=0; i<bPixelsCropped.length; i++) {
      int val = (int) bPixelsCropped[i];
      if (val < minVal) {
        minVal = val;
      } else if (val > maxVal) {
        maxVal = val;
      }
    }
    
    println("min: " + minVal + ", max: " + maxVal);
    minValF = (float) minVal;
    maxValF = (float) maxVal;
      
    imgCropped = createImage(bImgCropped.getWidth(), bImgCropped.getHeight(), RGB);
    imgCropped.loadPixels();
    
    for (int i=0; i<imgCropped.pixels.length; i++) {
      float valF = (float) bPixelsCropped[i];

      imgCropped.pixels[i] = color(map(valF, minValF, maxValF, 0, 255));
    }
    imgCropped.updatePixels();
  }
  
  void bImageToPImage() {
    img = createImage(bImg.getWidth(), bImg.getHeight(), RGB);
    bImg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();
  }
  
  BufferedImage cropBImage(BufferedImage src, int x1, int y1, int x2, int y2) {
      BufferedImage returns = src.getSubimage(x1, y1, x2, y2);
      return returns; 
  }
  
  short[] getBImagePixels(BufferedImage src) {
    return ((DataBufferUShort) src.getRaster().getDataBuffer()).getData();
  }
  
}

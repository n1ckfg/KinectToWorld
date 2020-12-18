// https://discourse.processing.org/t/16bit-grayscale-images/10795/3
// https://processing.org/discourse/beta/num_1211845881.html

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.DataBufferUShort;
import javax.imageio.ImageIO;

class Read16bpc {
 
  BufferedImage bImg;
  short[] bPixels;
  PImage img;
  
  int minVal;
  int maxVal;
  float minValF;
  float maxValF;

  Read16bpc(String _url, boolean normalize) {
    minVal = 0;
    maxVal = 0;
    try {
        bImg = ImageIO.read(new File(dataPath(""), _url));
        bPixels = ((DataBufferUShort) bImg.getRaster().getDataBuffer()).getData();
    } catch (IOException e) {
        e.printStackTrace();
    }
    
    if (normalize) {
      bImageNormToPImage();
    } else {
      bImageToPImage();
    }
  }
  
  void bImageNormToPImage() {
    for (int i=0; i<bPixels.length; i++) {
      int val = (int) bPixels[i];
      if (val < minVal) {
        minVal = val;
      } else if (val > maxVal) {
        maxVal = val;
      }
    }
    
    println("min: " + minVal + ", max: " + maxVal);
    minValF = (float) minVal;
    maxValF = (float) maxVal;
      
    img = createImage(bImg.getWidth(), bImg.getHeight(), RGB);
    img.loadPixels();
    
    for (int i=0; i<img.pixels.length; i++) {
      float valF = (float) bPixels[i];

      img.pixels[i] = color(map(valF, minValF, maxValF, 0, 255));
    }
    img.updatePixels();
  }
  
  void bImageToPImage() {
    img = createImage(bImg.getWidth(), bImg.getHeight(), RGB);
    bImg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();
  }
  
}

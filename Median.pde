// https://forum.processing.org/one/topic/how-can-i-optimize-the-usage-of-this-median-filter.html
// * Matthew Lord * 2012.01.28

int number_of_iterations = 50;
int iteration_count = 0;
int matrixSize, rgbListMedian, z;
boolean horizontal_edge, vertical_edge;

// String values to be filled in prior to run
// images should be named numerically and with .jpg extension
// path to initial image to operate on
String img_path = "data/dirname/file_prefix";
// name of folder path for images
String save_folder_name = "data/processed_imgs/dirname";
// Offset and totalframes values to be filled before running
int offset = 0; // include what has been rendered up to (one less than where we begin)
int totalframes = 0; // number to stop at
// Arrays to hold (Alpha)RGB values for processing
int[ ] AList = new int[ 0 ];
int[ ] RList = new int[ 0 ];
int[ ] GList = new int[ 0 ];
int[ ] BList = new int[ 0 ];

/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
 *  FUNCTIONS
 *
 *  Set the values for the following variables manually for each function
 *    for the time being (until algorithm can be found):
 *      rgbListMedian
 *      matrixSize
 *
** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/

/** looking for an algorithm...
  int rlm_main = 4;
  int ms_main = 9;

  int rlm_corner = rlm_main / 4;
  int ms_corner = ms_main / 2;

  int rlm_border = rlm_main / 2;
  int ms_border = ms_main / (3 * 2);
**/

void setArraySizeBody( ) {  // for main body of image
  rgbListMedian = 4;
  matrixSize = 9;
}

void setArraySizeCorner( ) {  // for corner operations
  rgbListMedian = 1;
  matrixSize = 4;
}

void setArraySizeBorder( ) {  // for border operations
  rgbListMedian = 2;
  matrixSize = 6;
}

// RESET "Z" INTEGER
void resetZ( ) {
  z = 0;
}

// MAKE THE OPERATIONAL ARRAYS
void makeArrays(int x) {
  AList = new int[ x ];
  RList = new int[ x ];
  GList = new int[ x ];
  BList = new int[ x ];
}

// CREATION OF VARIABLES & ARRAYS DEPENDENT UPON PIXEL OPERATION
void makeCornerArrays( ) {  // make corner arrays
  setArraySizeCorner( );
  resetZ( );
  makeArrays(matrixSize);
}
void makeBorderArrays( ) {  // make border arrays
  setArraySizeBorder( );
  resetZ( );
  makeArrays(matrixSize);
}
void makeMainArrays( ) {  // make main arrays
  setArraySizeBody( );
  resetZ( );
  makeArrays(matrixSize);
}

// function for loading the position and ARGB List Arrays
void ARGBLoadArrays(int x, int y, int kx, int ky) {
  // declare variables
  int pos, alphaVal, redVal, greenVal, blueVal;
  // pixel position
  pos = (y + ky) * width + (x + kx);
  // get color values
  alphaVal = int(alpha(img.pixels[ pos ]));
  redVal = int(red(img.pixels[ pos ]));
  greenVal = int(green(img.pixels[ pos ]));
  blueVal = int(blue(img.pixels[ pos ]));
  // place the RGB values into their respective arrays
  AList[ z ] = int(alphaVal);
  RList[ z ] = int(redVal);
  GList[ z ] = int(greenVal);
  BList[ z ] = int(blueVal);
}

// takes in four arrays, sorts them, and defines a color
// select the median value (-1) for each color array ARGB
color getMedianColor(int[ ] a, int[ ] r, int[ ] g, int[ ] b, int m) {
  // color variable
  color c;
  // sort the Arrays
  a = sort(a);
  r = sort(r);
  g = sort(g);
  b = sort(b);
  // select the median value for each array
  c = color(r[ m ], g[ m ], b[ m ], a[ m ]);
  return c;
}

// applies a median filter to an image and returns it
PImage medianFilterImage(PImage img, PImage filteredImg) {
  //PImage filteredImg = img.copy();
  filteredImg.loadPixels();
  int medVal;
  color medianColor;
  // CYCLE THROUGH ALL PIXELS
  // loop through every pixel in the y-direction
  for (int y = 0; y <= img.height - 1; y++) {
    // loop through every pixel in the x-direction
    for (int x = 0; x <= img.width - 1; x++) {

      // operate on the upper left pixel
      if (y == 0 && x == 0) {
        makeCornerArrays( );
        // make an array out of the following pixels
        //  [ none ]  [ none ]  [ none ]
        //  [ none ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ none ]  [ 0, 1 ]  [ 1, 1 ]
        for (int ky = 0; ky <= 1; ky++) {
          for(int kx = 0; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the top row, main pixels
      if (y == 0 && (x > 0 && x < img.width - 1)) {
        makeBorderArrays( );
        // make an array out of the following pixels
        //  [ none ]  [ none ]  [ none ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ -1, 1 ]  [ 0, 1 ]  [ 1, 1 ]
        for (int ky = 0; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the upper right pixel
      if (y == 0 && x == (img.width - 1)) {
        makeCornerArrays( );
        // make an array out of the following [ x, y ] pixels
        //  [ none ]  [ none ]  [ none ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ none ]
        //  [ -1, 1 ]  [ 0, 1 ]  [ none ]
        for (int ky = 0; ky <= 1; ky++) {
          for (int kx = -1; kx <= 0; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the left border column pixels
      if ((y > 0 && y < (img.height - 2)) && x == 0) {
        makeBorderArrays( );
        // make an array out of the following [ x, y ] pixels
        //  [ none ]  [ 0, -1 ]  [ 1, -1 ]
        //  [ none ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ none ]  [ 0, 1 ]  [ 1, 1 ]
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = 0; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the right border column pixels
      if ((y > 0 && y < (img.height - 2)) && x == (img.width - 1)) {
        makeBorderArrays( );
        // make an array out of the following [ x, y ] pixels
        //  [ -1, -1 ]  [ 0, -1 ]  [ none ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ none ]
        //  [ -1, 1 ]  [ 0, 1 ]  [ none ]
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = 0; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the lower left pixel
      if (y == (img.height - 1) && x == 0) {
        makeCornerArrays( );
        // make an array out of the following pixels
        //  [ none ]  [ 0, -1 ]  [ 1, -1 ]
        //  [ none ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ none ]  [ none ]  [ none ]
        for (int ky = -1; ky <= 0; ky++) {
          for (int kx = 0; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the bottom row, main pixels
      if (y == (img.height - 1) && (x > 0 && x < img.width - 1)) {
        makeBorderArrays( );
        // make an array out of the following pixels
        //  [ -1, -1 ]  [ 0, -1 ]  [ 1, -1 ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ none ]  [ none ]  [ none ]
        for (int ky = -1; ky <= 0; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the lower right pixel
      if (y == (img.height - 1) && x == (img.width - 1)) {
        makeCornerArrays( );
        // make an array out of the following [ x, y ] pixels
        //  [ -1, -1 ]  [ 0, -1 ]  [ none ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ none ]
        //  [ none ]  [ none ]  [ none ]
        for (int ky = -1; ky <= 0; ky++) {
          for (int kx = -1; kx <= 0; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }

      // operate on the main portion of the image
      // check that we are not on a top or bottom edge
      horizontal_edge = y > 0 && y < img.height - 1;
      // check that we are not on the bottom edge
      vertical_edge = x > 0 && x < img.width - 1;
      if (horizontal_edge && vertical_edge) {
        makeMainArrays( );
        // make an array out of the following [ x, y ] pixels
        //  [ -1, -1 ]  [ 0, -1 ]  [ 1, -1 ]
        //  [ -1, 0 ]  [ 0, 0 ]  [ 1, 0 ]
        //  [ -1, 1 ]  [ 0, 1 ]  [ 1, 1 ]
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            ARGBLoadArrays(x, y, kx, ky);
            z++;
          }
        }
      }
      medVal = rgbListMedian - 1;
      // define the median color value
      medianColor = getMedianColor(AList, RList, GList, BList, medVal);
      // assign the RGB values to the new image pixel in the same
      // location as the original
      filteredImg.pixels[ y * img.width + x ] = color(medianColor);
    }
  }
  filteredImg.updatePixels();
  return filteredImg;
}

class KinectUtil {
  
  int DEPTH_LIMIT = 2047;
  
  KinectUtil() {
    setupDepthLookUp();
  }
  
  /*
  int kinectLookupTableSize = 10000;
  float kinectDepthScale = 10;
  float[] kinectLookupTable = new float[kinectLookupTableSize];
  
  void setupKinectLookupTable() {
    for (int i=0; i<kinectLookupTable.length; i++) {
      kinectLookupTable[i] = map(i, 0, kinectLookupTableSize, 0, 255) * kinectDepthScale;
    }
  }
  
  float getGrayDepthValue(int val) {
    return kinectLookupTable[val];
  }
  */
  
  int gray(color value) { 
    return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
  }
  
  // ~ ~ ~ ~ ~ ~ ~ ~ ~ 
  
  int getLoc(float x, float y, int w) {
    return int(x) + int(y) * w;
  }
  
  color getColor(color[] px, float x, float y, int w) {
    return px[getLoc(x, y, w)];
  }
  
  float getZ(color[] px, float x, float y, int w) {
    return red(px[getLoc(x, y, w)]) * 2;
  }
  
  PVector getPos(PVector[] points, float x, float y, int w) {
    return points[getLoc(x, y, w)];
  }
  
  float rawDepthToMeters(int depthValue) {
    if (depthValue < DEPTH_LIMIT) {
      return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
    }
    return 0.0;
  }
  
  int depth2rgb(short depth) {
    int r,g,b;
  
    float v = depth / (float) DEPTH_LIMIT;
    v = (float) Math.pow(v, 3)* 6;
    v = v*6*256;
  
    int pval = Math.round(v);
    int lb = pval & 0xff;
    switch (pval>>8) {
    case 0:
      b = 255;
      g = 255-lb;
      r = 255-lb;
      break;
    case 1:
      b = 255;
      g = lb;
      r = 0;
      break;
    case 2:
      b = 255-lb;
      g = 255;
      r = 0;
      break;
    case 3:
      b = 0;
      g = 255;
      r = lb;
      break;
    case 4:
      b = 0;
      g = 255-lb;
      r = 255;
      break;
    case 5:
      b = 0;
      g = 0;
      r = 255-lb;
      break;
    default:
      r = 0;
      g = 0;
      b = 0;
      break;
    }
  
    int pixel = (0xFF) << 24
        | (b & 0xFF) << 16
        | (g & 0xFF) << 8
        | (r & 0xFF) << 0;
  
    return pixel;
  }
  
  int depth2intensity(int depth) {//short depth) {
    float maxDepth = 8000f; //(float) DEPTH_LIMIT;
    int d = round((1 - (depth / maxDepth)) * 255f);
    int pixel = (0xFF) << 24
        | (d & 0xFF) << 16
        | (d & 0xFF) << 8
        | (d & 0xFF) << 0;
  
    return pixel;
  }
  
  double fx_d = 1.0 / 5.9421434211923247e+02;
  double fy_d = 1.0 / 5.9104053696870778e+02;
  double cx_d = 3.3930780975300314e+02;
  double cy_d = 2.4273913761751615e+02;
    
  PVector depthToWorld(int x, int y, int depthValue) {
    PVector result = new PVector(0,0,0);
    if (depthValue < depthLookUp.length) {
      double depth =  depthLookUp[depthValue];
      result.x = (float)((x - cx_d) * depth * fx_d);
      result.y = (float)((y - cy_d) * depth * fy_d);
      result.z = (float)(depth);
    }
    return result;
  }
  
  // http://shiffman.net/p5/kinect/
  
  // depthInMeters = 1.0 / (rawDepth * -0.0030711016 + 3.3309495161);
  // Rather than do this calculation all the time, we can precompute all of these
  // values in a lookup table since there are only 2048 depth values.
  
  float[] depthLookUp = new float[2048];
  
  void setupDepthLookUp() {
    for (int i = 0; i < depthLookUp.length; i++) {
      depthLookUp[i] = rawDepthToMeters(i);
    }
  }

  // ~ ~ ~ ~ ~
  
    // raw image from Kinect 1/clones
    float getDepthMillis(color pix) {       
      int green = pix >> 8 & 0xFF;       
      int red = pix >> 16 & 0xFF;       
      int depthMillis = red << 8 | green;
      return (float) depthMillis;                
    }
    
    PVector convertMillisToWorld(int x, int y, int depthMillis) {
      double fx_d = 1.0 / 5.9421434211923247e+02;
      double fy_d = 1.0 / 5.9104053696870778e+02;
      double cx_d = 3.3930780975300314e+02;
      double cy_d = 2.4273913761751615e+02;
  
      double depth = 0;   
      depth = depthMillis; ///1000;
      
      PVector result = new PVector();
      result.x = (float) ((x - cx_d) * depth * fx_d);
      result.y = (float) ((y - cy_d) * depth * fy_d);
      result.z = (float) depth;
      return result;
  }

  PVector convertMillisToWorldV2(int x, int y, int depthMillis) {
    PVector returns = new PVector(0,0,0);
    /*
    int count = 0;
    float normX, normY, z;
    float fac_XZ = tan(FOV_H/2)*2;
    float fac_YZ = tan(FOV_V/2)*2;
    float *xyzList = (float*) malloc(WIDTH*HEIGHT*3*sizeof(float));
  
    // Do filtering on 'shortxyzList' here.
  
    memset(xyzList, 0, WIDTH*HEIGHT*3*sizeof(float));
  
    for (int i = 0; i < WIDTH*HEIGHT; i++) 
      xyzList[i*3 + 2] = (float)depthList[i];
    
    for (int i = 0; i < HEIGHT*WIDTH; i++) {
      z = xyzList[i*3+2];
      normX = (i % WIDTH) / (float)WIDTH - 0.5f;
      normY = 0.5f - (int)(i/WIDTH) / (float)HEIGHT;
  
      xyzList[i*3+0] = normX * z * fac_XZ;
      xyzList[i*3+1] = normY * z * fac_YZ;
      xyzList[i*3+2] = z;
    }
    */
    return returns;
  }
    
  // ~ ~ ~ ~ ~

  float maxDistance = -1.0;
  
  void getMaxDistance() {
    for (int i=1; i<256; i++) {
      maxDistance += 1.0/i;
    }
  }
  
  float getDistance(float val) {
    if (maxDistance < 0) getMaxDistance();
    
    float returns = 0.0;
  
    for (int i=1; i<val+1; i++) {
      returns += 1.0/i;
    }
    
    return abs(maxDistance - returns) + 1.0;
  }

}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

/* REFERENCE
// Links
// http://www.imaginativeuniversal.com/blog/2014/03/05/quick-reference-kinect-1-vs-kinect-2/
// https://smeenk.com/kinect-field-of-view-comparison/
// https://stackoverflow.com/questions/17832238/kinect-intrinsic-parameters-from-field-of-view
// https://rosindustrial.org/news/2016/1/13/3d-camera-survey
// https://opdhsblobprod03.blob.core.windows.net/contents/503db294612a42b3b95420aaabac44cc/77342d6514e7dbbcf477614ed3a7acda?sv=2015-04-05&sr=b&sig=Jn1XYV3R6%2Brh309dHaPO3BqCx5vtp1A%2BkCs%2F%2BTjhZlI%3D&st=2019-05-16T15%3A06%3A45Z&se=2019-05-17T15%3A16%3A45Z&sp=r
// https://forums.structure.io/t/structure-sensors-angle-of-view/486
// http://xtionprolive.com/primesense-carmine-1.09
// http://www.i3du.gr/pdf/primesense.pdf
// https://structure.io/structure-core/specs
// https://www.intel.com/content/www/us/en/support/articles/000030385/emerging-technologies/intel-realsense-technology.html
// https://stackoverflow.com/questions/39389279/c-kinect-v2-freenect2-how-to-convert-depth-data-to-real-world-coordinates

// Original OpenNI reference

OniStatus VideoStream::convertDepthToWorldCoordinates(float depthX, float depthY, float depthZ, float* pWorldX, float* pWorldY, float* pWorldZ)
{
  if (m_pSensorInfo->sensorType != ONI_SENSOR_DEPTH)
  {
    m_errorLogger.Append("convertDepthToWorldCoordinates: Stream is not from DEPTH\n");
    return ONI_STATUS_NOT_SUPPORTED;
  }

  float normalizedX = depthX / m_worldConvertCache.resolutionX - .5f;
  float normalizedY = .5f - depthY / m_worldConvertCache.resolutionY;

  *pWorldX = normalizedX * depthZ * m_worldConvertCache.xzFactor;
  *pWorldY = normalizedY * depthZ * m_worldConvertCache.yzFactor;
  *pWorldZ = depthZ;
  return ONI_STATUS_OK;
}

OniStatus VideoStream::convertWorldToDepthCoordinates(float worldX, float worldY, float worldZ, float* pDepthX, float* pDepthY, float* pDepthZ)
{
  if (m_pSensorInfo->sensorType != ONI_SENSOR_DEPTH)
  {
    m_errorLogger.Append("convertWorldToDepthCoordinates: Stream is not from DEPTH\n");
    return ONI_STATUS_NOT_SUPPORTED;
  }

  *pDepthX = m_worldConvertCache.coeffX * worldX / worldZ + m_worldConvertCache.halfResX;
  *pDepthY = m_worldConvertCache.halfResY - m_worldConvertCache.coeffY * worldY / worldZ;
  *pDepthZ = worldZ;
  return ONI_STATUS_OK;
}

void VideoStream::refreshWorldConversionCache()
{
  if (m_pSensorInfo->sensorType != ONI_SENSOR_DEPTH)
  {
    return;
  }

  OniVideoMode videoMode;
  int size = sizeof(videoMode);
  getProperty(ONI_STREAM_PROPERTY_VIDEO_MODE, &videoMode, &size);

  size = sizeof(float);
  float horizontalFov;
  float verticalFov;
  getProperty(ONI_STREAM_PROPERTY_HORIZONTAL_FOV, &horizontalFov, &size);
  getProperty(ONI_STREAM_PROPERTY_VERTICAL_FOV, &verticalFov, &size);

  m_worldConvertCache.xzFactor = tan(horizontalFov / 2) * 2;
  m_worldConvertCache.yzFactor = tan(verticalFov / 2) * 2;
  m_worldConvertCache.resolutionX = videoMode.resolutionX;
  m_worldConvertCache.resolutionY = videoMode.resolutionY;
  m_worldConvertCache.halfResX = m_worldConvertCache.resolutionX / 2;
  m_worldConvertCache.halfResY = m_worldConvertCache.resolutionY / 2;
  m_worldConvertCache.coeffX = m_worldConvertCache.resolutionX / m_worldConvertCache.xzFactor;
  m_worldConvertCache.coeffY = m_worldConvertCache.resolutionY / m_worldConvertCache.yzFactor;
}

struct WorldConversionCache
{
  float xzFactor;
  float yzFactor;
  float coeffX;
  float coeffY;
  int resolutionX;
  int resolutionY;
  int halfResX;
  int halfResY;
} m_worldConvertCache;
*/

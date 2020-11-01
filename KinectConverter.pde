class KinectConverter {
  
  String depthCameraListUrl = "depth_camera_list.json";
  
  // given
  float resolutionX, resolutionY;
  float horizontalFov, verticalFov;
  float maxBitDepth; // ?
  float minDepth, maxDepth; // ?11-bit

  // calculated
  float xzFactor, yzFactor;
  float halfResX, halfResY;
  float coeffX, coeffY;
   
  KinectConverter() {
    setModel("Kinect", "default");
  }
  
  KinectConverter(String model) {
    setModel(model, "default");
  }
  
  KinectConverter(String model, String mode) {
    setModel(model, mode);
  }
  
  
  void setModel(String model, String mode) {
    try {
      setModelFromJson(model, mode);
    } catch (Exception e) {
      println("Error reading camera list. " + e);
      setModelDefaults();
    }

    initModel();
  }
  
  void setModelFromJson(String model, String mode) {
    JSONObject json = loadJSONObject(depthCameraListUrl);
    JSONArray camerasJson = json.getJSONArray("cameras");
    JSONObject modelJson = null;
    JSONArray modesJson = null;
    JSONObject modeJson = null;
    
    for (int i=0; i<camerasJson.size(); i++) {
      modelJson = (JSONObject) camerasJson.get(i);
      if (modelJson.get("name").equals(model)) {
        println("Found model: " + model);
        modesJson = modelJson.getJSONArray("modes");

        for (int j=0; j<modesJson.size(); j++) {
          modeJson = (JSONObject) modesJson.get(j);
          if (modeJson.get("mode").equals(mode)) {
            println("Found mode: " + mode);
            break;
          }
        }           
        
        break;
      }
    }   

    resolutionX = modeJson.getFloat("resolutionX");
    resolutionY = modeJson.getFloat("resolutionY");
    horizontalFov = modeJson.getFloat("horizontalFov");
    verticalFov = modeJson.getFloat("verticalFov");
    maxBitDepth = modeJson.getFloat("maxBitDepth");
    minDepth = modeJson.getFloat("minDepth");
    maxDepth = modeJson.getFloat("maxDepth"); 
  }
  
  void setModelDefaults() { // Kinect 1
    resolutionX = 640;
    resolutionY = 480;
    horizontalFov = 58.5;
    verticalFov = 46.6;
    maxBitDepth = 2047; // ?
    minDepth = 400; // ?
    maxDepth = 5000; // ?11-bit
  }
  
  void initModel() {
    xzFactor = tan(horizontalFov / 2) * 2;
    yzFactor = tan(verticalFov / 2) * 2;
    halfResX = resolutionX / 2;
    halfResY = resolutionY / 2;
    coeffX = resolutionX / xzFactor;
    coeffY = resolutionY / yzFactor;
  }
 
 // ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 
  // per pixel depth in mm
  PVector convertDepthToWorld(float x, float y, float z) {
    float normX = x / resolutionX - 0.5;
    float normY = 0.5 - y / resolutionY;
    
    z = abs(255 - z);
    float worldZ = map(z, 0, 255, minDepth, maxDepth);
    float worldX = normX * worldZ;
    float worldY = normY * worldZ;
    
    if (resolutionX > resolutionY) {
      worldX *= (resolutionX / resolutionY);
    } else if (resolutionY > resolutionX) {
      worldY *= (resolutionY / resolutionX);
    }
    
    return new PVector(worldX, -worldY, -worldZ);
  }

  PImage depthFilter(PImage img) {
    PImage newImg = img.copy();
    newImg.filter(ERODE);
    newImg.filter(DILATE);
    return newImg;
  }
  
  // raw image from Kinect 1/clones
  float getDepthMillis(color pix) {       
    int green = pix >> 8 & 0xFF;       
    int red = pix >> 16 & 0xFF;       
    int depthMillis = red << 8 | green;
    return (float) depthMillis;                
  }
  
  PVector convertMillisToWorld(int x, int y, float depthMillis) {
    double fx_d = 1.0 / 5.9421434211923247e+02;
    double fy_d = 1.0 / 5.9104053696870778e+02;
    double cx_d = 3.3930780975300314e+02;
    double cy_d = 2.4273913761751615e+02;

    double depth = 0;   
    depth = depthMillis/1000;
    
    PVector result = new PVector();
    result.x = (float) ((x - cx_d) * depth * fx_d);
    result.y = (float) ((y - cy_d) * depth * fy_d);
    result.z = (float) depth;
    return result;
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

class KinectConverter {
  
  float horizontalFov;
  float verticalFov;
  int resolutionX;
  int resolutionY;
  int maxDepthVals;
  
  float xzFactor;
  float yzFactor;
  float coeffX;
  float coeffY;
  int halfResX;
  int halfResY;

  KinectConverter() {
    setModel("Kinect");
    init();
  }
  
  KinectConverter(String model) {
    setModel(model);
    init();
  }
  
  void init() {
    xzFactor = tan(horizontalFov / 2) * 2;
    yzFactor = tan(verticalFov / 2) * 2;
    halfResX = resolutionX / 2;
    halfResY = resolutionY / 2;
    coeffX = (float) resolutionX / xzFactor;
    coeffY = (float) resolutionY / yzFactor;  
  }
  
  PVector convertDepthToWorld(float depthX, float depthY, float depthZ) {
    depthZ -= 255;
    float normalizedX = depthX / resolutionX - 0.5;
    float normalizedY = 0.5 - depthY / resolutionY;
 
    float pWorldX = normalizedX * depthZ * xzFactor * (((float)resolutionX/(float)resolutionY)*2);
    float pWorldY = normalizedY * depthZ * yzFactor;
    float pWorldZ = (depthZ / 255) * maxDepthVals;

    
    return new PVector(pWorldX, pWorldY, pWorldZ);
  }

  PVector convertWorldToDepth(float worldX, float worldY, float worldZ) {
    float pDepthX = coeffX * worldX / worldZ + halfResX;
    float pDepthY = halfResY - coeffY * worldY / worldZ;
    float pDepthZ = worldZ;
    
    return new PVector(pDepthX, pDepthY, pDepthZ);
  }

  void setModel(String model) {
    switch (model) {
      case "Kinect4_Narrow_Unbinned":
        resolutionX = 640;
        resolutionY = 576;
        horizontalFov = 75.0;
        verticalFov = 65.0;  
        maxDepthVals = 2047; // ?
      case "Kinect4_Narrow_Binned":
        resolutionX = 320;
        resolutionY = 288;
        horizontalFov = 75.0;
        verticalFov = 65.0; 
        maxDepthVals = 2047; // ?
      case "Kinect4_Wide_Unbinned":
        resolutionX = 1024;
        resolutionY = 1024;
        horizontalFov = 120.0;
        verticalFov = 120.0; 
        maxDepthVals = 2047; // ?
      case "Kinect4_Wide_Binned":
        resolutionX = 512;
        resolutionY = 512;
        horizontalFov = 120.0;
        verticalFov = 120.0; 
        maxDepthVals = 2047; // ?
      case "Kinect2":
        resolutionX = 512;
        resolutionY = 424;
        horizontalFov = 70.6;
        verticalFov = 60.0;  
        maxDepthVals = 8191; // 13-bit
      case "Xtion":
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 58.0;
        verticalFov = 45.0;   
        maxDepthVals = 2047; // ?      
      case "Structure":
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 58.0;
        verticalFov = 45.0; 
        maxDepthVals = 2047; // ?       
      case "StructureCore_4:3":
        resolutionX = 1280;
        resolutionY = 960;
        horizontalFov = 59.0;
        verticalFov = 46.0; 
        maxDepthVals = 2047; // ?
      case "StructureCore_16:10":
        resolutionX = 1280;
        resolutionY = 800;
        horizontalFov = 59.0;
        verticalFov = 46.0; 
        maxDepthVals = 2047; // ?
      case "Carmine1.09": // short range
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 57.5;
        verticalFov = 45.0; 
        maxDepthVals = 2047; // ?
      case "Carmine1.08":
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 57.5;
        verticalFov = 45.0; 
        maxDepthVals = 2047; // ?
      case "RealSense415":
        resolutionX = 1280;
        resolutionY = 720;
        horizontalFov = 64.0;
        verticalFov = 41.0;
        maxDepthVals = 2047; // ?
      case "RealSense435":
        resolutionX = 1280;
        resolutionY = 720;
        horizontalFov = 86.0;
        verticalFov = 57.0;        
        maxDepthVals = 2047; // ?
      default:  // Kinect
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 58.5;
        verticalFov = 46.6;
        maxDepthVals = 2047; // 11-bit
    }
  }

}


/*
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

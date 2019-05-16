// http://www.imaginativeuniversal.com/blog/2014/03/05/quick-reference-kinect-1-vs-kinect-2/
// https://smeenk.com/kinect-field-of-view-comparison/
// https://stackoverflow.com/questions/17832238/kinect-intrinsic-parameters-from-field-of-view

class KinectConverter {
  
  float horizontalFov;
  float verticalFov;
  int resolutionX;
  int resolutionY;
  
  float xzFactor;
  float yzFactor;
  float coeffX;
  float coeffY;
  int halfResX;
  int halfResY;

  KinectConverter() { // defaults to Kinect 1
    resolutionX = 640;
    resolutionY = 480;
    horizontalFov = 58.5;
    verticalFov = 46.6;
    
    init();
  }
  
  KinectConverter(String model) {
    switch (model) {
      case "Kinect 2":
        resolutionX = 512;
        resolutionY = 424;
        horizontalFov = 70.6;
        verticalFov = 60.0;       
      default:
        resolutionX = 640;
        resolutionY = 480;
        horizontalFov = 58.5;
        verticalFov = 46.6;
    }
    
    init();
  }
  
  KinectConverter(int _resolutionX, int _resolutionY, float _horizontalFov, float _verticalFov) {
    resolutionX = _resolutionX;
    resolutionY = _resolutionY;
    horizontalFov = _horizontalFov;
    verticalFov = _verticalFov;
    init();
  }
  
  void init() {
    xzFactor = tan(horizontalFov / 2) * 2;
    yzFactor = tan(verticalFov / 2) * 2;
    halfResX = resolutionX / 2;
    halfResY = resolutionY / 2;
    coeffX = resolutionX / xzFactor;
    coeffY = resolutionY / yzFactor;  
  }
}


/*
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

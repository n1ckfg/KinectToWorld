class WorldConversionCache {
  
  float xzFactor;
  float yzFactor;
  float coeffX;
  float coeffY;
  int resolutionX;
  int resolutionY;
  int halfResX;
  int halfResY;

  WorldConversionCache() {
    //
  }
  
}


/*
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

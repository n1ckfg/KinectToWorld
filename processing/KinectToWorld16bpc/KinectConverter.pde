class KinectConverter {
  
  String depthCameraListUrl = "../../common/depth_camera_list.json";
  
  // given
  float resolutionX, resolutionY;
  float horizontalFov, verticalFov;
  float maxBitDepth; // ?
  float minDepth, maxDepth; // ?11-bit

  // calculated
  float xzFactor, yzFactor;
  float halfResX, halfResY;
  float coeffX, coeffY;
  
  KinectUtil ku;
  
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
    ku = new KinectUtil();
    
    try {
      setModelFromJson(model, mode);
    } catch (Exception e) {
      println("Error reading camera list. " + e);
      setModelDefaults();
    }

    init();
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
  
  void init() {   
    xzFactor = tan(horizontalFov / 2) * 2;
    yzFactor = tan(verticalFov / 2) * 2;
    halfResX = resolutionX / 2;
    halfResY = resolutionY / 2;
    coeffX = resolutionX / xzFactor;
    coeffY = resolutionY / yzFactor;
  }
 
 // ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 
  // per pixel depth in mm
  PVector convertDepthToWorld(int x, int y, int z) {
    /*
    float normX = x / resolutionX - 0.5;
    float normY = 0.5 - y / resolutionY;
    
    //float worldZ = map(z, 0, 255, minDepth, maxDepth);
    float worldZ = abs(img16.maxVal - z);

    float worldX = normX * worldZ;
    float worldY = normY * worldZ;
    */
    PVector worldCoords = ku.convertMillisToWorld(x, y, z);
    PVector returns = new PVector(-worldCoords.x, -worldCoords.z, -worldCoords.y);
    
    return returns;
  }

  PImage depthFilter(PImage img) {
    PImage newImg = img.copy();
    newImg.filter(ERODE);
    newImg.filter(DILATE);
    return newImg;
  }
  
}

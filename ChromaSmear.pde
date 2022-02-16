import java.util.Arrays;

// Hue über Vektoren darstellen, Entfernung vom Zentrum dann mit Sättigung multiplizieren 

static String inPath = "/Users/patri/Dropbox/T7Backup/timelapse29022022_short/";
static String outPath = "out/";

ArrayList<File> files;

static int imageWidth = 4056;
static int imageHeight = 3040;

static int numFramesSmear = 70;

ArrayList<float[]> hueBuffers;
Vector2d[] hueAccumBuffer;

ArrayList<float[]> satBuffers;
double[] satAccumBuffer;

double avgBrightnessAccum = 0f;
double lastAvgBrightness = 0f;

ArrayList<Double> brightnessBuffers;

PImage currentImage;

int currentIndex = 3000;
int maxIndex = -1;
int numFiles;

static int bufferSize = imageWidth * imageHeight;

void setup() {
  
  size(1024, 768);
  
  files = new ArrayList<File>();
  
  hueBuffers = new ArrayList<float[]>();
  hueAccumBuffer = new Vector2d[bufferSize];
  
  for(int i = 0; i < bufferSize; i++) {
    hueAccumBuffer[i] = new Vector2d(0.0, 0.0);
  }
  
  satBuffers = new ArrayList<float[]>();
  satAccumBuffer = new double[bufferSize];
  
  brightnessBuffers = new ArrayList<Double>();
  
  File file = new File(inPath);
  File[] filesList = file.listFiles();
  Arrays.sort(filesList);
  for(File f : filesList) {
    if(f.getAbsolutePath().endsWith(".jpg")) {
      files.add(f);
    }
  }
  
  numFiles = files.size();
  if(maxIndex < 0) {
    maxIndex = files.size() - 1;
  }
  
  println("Number of files: " + numFiles);
}

String getOutPath(File f) {
  return outPath + f.getName().replace(".jpg", ".jpg");
}

void draw() {
  colorMode(HSB);
  
  println("Index: " + currentIndex);
  addFile(files.get(currentIndex));
  
  String path = getOutPath(files.get(currentIndex));
  
  // not working
  boolean exists = dataFile(path).isFile();
  
  if(hueBuffers.size() < numFramesSmear) {
    println("Not enough buffers collected ...");
  } else if(exists) {
     println("File already exists: " + path);
  } else {
    double brightnessCompensation = (avgBrightnessAccum / numFramesSmear) / lastAvgBrightness;
    println("Brightness Compensation: " + brightnessCompensation);
    
    for(int y = 0; y < imageHeight; y++) {
      for(int x = 0; x < imageWidth; x++) {
        int index = y * imageWidth + x;
        float sat = (float) (satAccumBuffer[index] / numFramesSmear);
        
        Vector2d hueVec = hueAccumBuffer[index];
        hueVec.div(numFramesSmear);
        
        float hue = hueVec.hue();
        sat = sat * hueVec.radius();
        
        float b = brightness(currentImage.pixels[index]) * (float) brightnessCompensation;
        
        currentImage.pixels[index] = color(hue, sat, b);
      } 
    }
    
    currentImage.updatePixels();
    
    image(currentImage, 0, 0, width, height);
    
    
    println("Saved: " + path);
    currentImage.save(path);
  }
  
    if(currentIndex >= maxIndex) {
      exit();
    }

  currentIndex++;
}

void addFile(File f) {
  println(f.getAbsolutePath());
  currentImage = loadImage(f.getAbsolutePath());
  currentImage.loadPixels();
  
  if(hueBuffers.size() >= numFramesSmear) {
    
    float[] remHueBuffer = hueBuffers.get(0);
    float[] remSatBuffer = satBuffers.get(0);
    
    for(int i = 0; i < hueAccumBuffer.length; i++) {
      hueAccumBuffer[i].sub(new Vector2d(remHueBuffer[i]));
      satAccumBuffer[i] = satAccumBuffer[i] - remSatBuffer[i];
    }
    
    avgBrightnessAccum = avgBrightnessAccum - brightnessBuffers.get(0);
    
    hueBuffers.remove(0);
    satBuffers.remove(0);
    brightnessBuffers.remove(0);
  }
  
  float[] hueBuffer = new float[bufferSize];
  float[] satBuffer = new float[bufferSize];
  
  lastAvgBrightness = 0.0;
  int bs = 0;
  for(bs = 0; bs < bufferSize; bs = bs + 77) {
    lastAvgBrightness = lastAvgBrightness + brightness(currentImage.pixels[bs]);
  }
  
  lastAvgBrightness = lastAvgBrightness / bs;
  
  
  for(int y = 0; y < imageHeight; y++) {
    for(int x = 0; x < imageWidth; x++) {
      int index = y * imageWidth + x;
      hueBuffer[index] = hue(currentImage.pixels[index]);
      satBuffer[index] = saturation(currentImage.pixels[index]);
    }
  }
  
  for(int i = 0; i < bufferSize; i++) {
    hueAccumBuffer[i].add(new Vector2d(hueBuffer[i]));
    satAccumBuffer[i] = satAccumBuffer[i] + satBuffer[i];
  }
  
  avgBrightnessAccum = avgBrightnessAccum + lastAvgBrightness;
  
  hueBuffers.add(hueBuffer);
  satBuffers.add(satBuffer);
  brightnessBuffers.add(lastAvgBrightness);
  
}

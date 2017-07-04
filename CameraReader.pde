import processing.video.*;

public class CameraReader {

  public static final boolean USE_CAMERA = true;

  public static final int MAX_ERROR = 0x09;

  private ArrayList<Integer> selectedColors = new ArrayList<Integer>();

  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, width, height);
    cam.start();
  }

  public boolean colorMatches(int toCheck, boolean strictModeDisabled) {
    for (Integer sc : selectedColors) {
      int hr = (sc & 0xFF0000) >> 16;
      int hg = (sc & 0x00FF00) >> 8;
      int hb = (sc & 0x0000FF);

      int r = (toCheck & 0xFF0000) >> 16;
      int g = (toCheck & 0x00FF00) >> 8;
      int b = (toCheck & 0x0000FF);

      int re = abs(r - hr) / (strictModeDisabled ? 2 : 1);
      int ge = abs(g - hg) / (strictModeDisabled ? 2 : 1);
      int be = abs(b - hb) / (strictModeDisabled ? 2 : 1);
      
      if(re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR) return true;
    }
    return false;
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();



    for (int i = 0; i < cam.width; i++) {
      boolean started = false;
      for (int j = 0; j < cam.height; j++) {
        int col = cam.pixels[i + j * cam.width];

        if (colorMatches(col, started)) {
          if (started) {
            cam.pixels[i + j * cam.width] = 0xFF000000;
          } else {
            started = true; 
            cam.pixels[i + j * cam.width] = 0xFFFF00FF;
          }
        } else {
          if (started) {
            cam.pixels[i + j * cam.width] = 0xFFFF00FF;
            started = false;
          }
        }
      }
    }
  }
}
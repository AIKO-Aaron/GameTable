import processing.video.*;

public class CameraReader {

  public static final boolean USE_CAMERA = true;

  public static final int MAX_ERROR = 0x01;
  public static final int ERROR_THRESHOLD = 0x2;

  private ArrayList<Integer> selectedColors = new ArrayList<Integer>();

  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, width, height);
    cam.start();
  }

  public boolean colorMatches(int toCheck, boolean strictModeDisabled) {
    int r = (toCheck & 0xFF0000) >> 16;
    int g = (toCheck & 0x00FF00) >> 8;
    int b = (toCheck & 0x0000FF);

    float h = 0; // degrees
    float s = 0; // percent
    float v = 0; // percent
    // RGB to HSV
    if (r >= g && r >= b) {
      v = (float) r / 255.0;
      float delta = v - (b < g ? (float) b / 255.0 : (float) g /255.0);
      s = v != 0 ? delta / v : 0;
      h = 60 * (((g - b) / (255.0 * delta)) % 6);
    } else if (g >= r && g >= b) {
      v = (float) g / 255.0;
      float delta = v - (b < r ? (float) b / 255.0 : (float) r /255.0);
      s = v != 0 ? delta / v : 0;
      h = 60 * (((b - r) / (255.0 * delta)) + 2);
    } else if (b >= r && b >= g) {
      v = (float) b / 255.0;
      float delta = v - (r < g ? (float) r / 255.0 : (float) g /255.0);
      s = v != 0 ? delta / v : 0;
      h = 60 * (((r - g) / (255.0 * delta)) + 4);
    }

    for (Integer sc : selectedColors) {
      int hr = (sc & 0xFF0000) >> 16;
      int hg = (sc & 0x00FF00) >> 8;
      int hb = (sc & 0x0000FF);

      float hh = 0; // degrees
      float hs = 0; // percent
      float hv = 0; // percent
      // RGB to HSV
      if (hr >= hg && hr >= hb) {
        hv = (float) hr / 255.0;
        float delta = hv - (hb < hg ? (float) hb / 255.0 : (float) hg /255.0);
        hs = hv != 0 ? delta / hv : 0;
        hh = 60 * (((hg - hb) / (255.0 * delta)) % 6);
      } else if (hg >= hr && hg >= hb) {
        hv = (float) hg / 255.0;
        float delta = hv - (hb < hr ? (float) hb / 255.0 : (float) hr /255.0);
        hs = hv != 0 ? delta / hv : 0;
        hh = 60 * (((hb - hr) / (255.0 * delta)) + 2);
      } else if (hb >= hr && hb >= hg) {
        hv = (float) hb / 255.0;
        float delta = hv - (hr < hg ? (float) hr / 255.0 : (float) hg /255.0);
        hs = hv != 0 ? delta / hv : 0;
        hh = 60 * (((hr - hg) / (255.0 * delta)) + 4);
      }

      /*int re = abs(r - hr);
      int ge = abs(g - hg);
      int be = abs(b - hb);*/

      /**int a1 = abs(re - ge);
      int a2 = abs(re - be);
      int a3 = abs(ge - re);
      int a4 = abs(ge - be);
      int a5 = abs(be - re);
      int a6 = abs(be - ge);*/
      
      if(abs(h - hh) <= MAX_ERROR * (strictModeDisabled ? ERROR_THRESHOLD : 1) && abs(s - hs) * 5 <= MAX_ERROR * (strictModeDisabled ? ERROR_THRESHOLD : 1)) {
        return true;
      }

      /**if (!strictModeDisabled) {
       if (a1 < MAX_ERROR && a2 < MAX_ERROR && a3 < MAX_ERROR && a4 < MAX_ERROR && a5 < MAX_ERROR && a6 < MAX_ERROR) return true;
       } else {
       if (a1 < MAX_ERROR * ERROR_THRESHOLD && a2 < MAX_ERROR * ERROR_THRESHOLD && a3 < MAX_ERROR * ERROR_THRESHOLD && a4 < MAX_ERROR * ERROR_THRESHOLD && a5 < MAX_ERROR * ERROR_THRESHOLD && a6 < MAX_ERROR * ERROR_THRESHOLD) return true;
       }*/

      /**if (!strictModeDisabled) {
       if (re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR) return true;
       } else {
       if (re < MAX_ERROR * ERROR_THRESHOLD && ge < MAX_ERROR * ERROR_THRESHOLD && be < MAX_ERROR * ERROR_THRESHOLD) return true;
       }*/
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
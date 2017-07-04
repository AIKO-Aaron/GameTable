import processing.video.*;

public class CameraReader {

  public static final boolean USE_CAMERA = false;

  public static final int MAX_ERROR = 0x10;

  private ArrayList<Integer> selectedColors = new ArrayList<Integer>();

  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, width, height);
    cam.start();
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();
    for (int i = 0; i < cam.pixels.length; i++) {
      int col = cam.pixels[i];

      int r = (col & 0xFF0000) >> 16;
      int g = (col & 0x00FF00) >> 8;
      int b = (col & 0x0000FF);

      for (Integer sc : selectedColors) {
        int hr = (sc & 0xFF0000) >> 16;
        int hg = (sc & 0x00FF00) >> 8;
        int hb = (sc & 0x0000FF);

        int re = abs(r - hr);
        int ge = abs(g - hg);
        int be = abs(b - hb);

        if (re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR) {
          cam.pixels[i] = 0xFFFF00FF;
        }
      }
    }
  }
}
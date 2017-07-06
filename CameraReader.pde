import processing.video.*;

public class CameraReader {

  // #00E8F2
  // #FA8508

  public static final int COLOR_START = 0xFFFF00FF;
  public static final int COLOR_END = 0xFFFF00FF;

  public static final int PIXEL_SIZE = 5;

  public static final boolean USE_CAMERA = true;

  public static final int MAX_ERROR = 0x10;

  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, width, height);
    if (cam != null) cam.start();
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();

    int sx = 0, sy = 0, ex = cam.width, ey = cam.height;

    for (int i = 0; i < cam.width; i++) {
      boolean started = false;
      for (int j = 0; j < cam.height; j++) {
        int col = cam.pixels[i + j * cam.width];
        int ctb = 0xFF2A53E0;

        int re = abs((col >> 16) & 0xFF - (ctb >> 16) & 0xFF);
        int ge = abs((col >> 8) & 0xFF - (ctb >> 8) & 0xFF);
        int be = abs((col) & 0xFF - (ctb) & 0xFF);

        if (re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR && !started) {
          started = true;
          sx = i;
          sy = j;
        } else if (started) {
          started = false;
          ex = i;
          ey = j;
        }
      }
    }

    for (int i = sx; i < ex; i++) {
      for (int j = sy; j < ey; j++) {
        cam.pixels[i + j * cam.width] = 0xFFFF00FF;
      }
    }
    cam.updatePixels();
  }

  public void render() {
    fill(COLOR_START);
    rect(0, 0, PIXEL_SIZE, PIXEL_SIZE);
    fill(COLOR_END);
    rect(handler.NORMAL_WIDTH - PIXEL_SIZE, height - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
  }
}
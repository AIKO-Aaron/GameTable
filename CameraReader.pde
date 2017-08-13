import processing.video.*;

public class CameraReader {

  // #00E8F2
  // #FA8508

  public static final int COLOR_START = 0xFFFFFF7F;
  public static final int COLOR_END = 0xFFFFFF7F;

  public static final int PIXEL_SIZE = 50;

  public static final boolean USE_CAMERA = false;

  public static final int MAX_ERROR = 0x30;

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
      int amount = 0;
      for (int j = 0; j < cam.height; j++) {
        int col = cam.pixels[i + j * cam.width];
        int ctb = 0xffffafb8; //0xff1628a4;

        int re = abs(abs((col >> 16) & 0xFF) - abs((ctb >> 16) & 0xFF));
        int ge = abs(abs((col >> 8) & 0xFF) - abs((ctb >> 8) & 0xFF));
        int be = abs(abs((col) & 0xFF) - abs((ctb) & 0xFF));

        if (ge < MAX_ERROR && be < MAX_ERROR) {
          started = true;
          ++amount;

          cam.pixels[i+ j * cam.width] = 0xFFFF00FF;
        } else if (started) {
          started = false;
          if (amount > 40) {            
            // println(startTime);

            if (sx == 0) sx = i;
            else ex = i;
            if (sy == 0) sy = j;
            else ey = j;
          }
          amount = 0;
        }
      }
    }

    /**for (int i = sx; i < ex; i++) {
     for (int j = sy; j < ey; j++) {
     cam.pixels[i + j * cam.width] = 0xFFFF00FF;
     }
     }*/

    cam.updatePixels();
  }

  public void render() {
    fill(COLOR_START);
    rect(0, 0, PIXEL_SIZE, PIXEL_SIZE);
    fill(COLOR_END);
    rect(handler.NORMAL_WIDTH - PIXEL_SIZE, height - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
  }
}
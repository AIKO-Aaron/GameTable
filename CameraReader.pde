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
  public PImage captured;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, width, height);
    if (cam != null) cam.start();
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();

    int start_pos = 0;
    int end_pos = cam.width * cam.height - 1;

    for (int i = 0; i < cam.width; i++) {
      for (int j = 0; j < cam.height; j++) {
        int col = cam.pixels[i + j * cam.width];
        if (col == COLOR_START && start_pos == 0) start_pos = i + j*cam.width;
        if (col == COLOR_END) end_pos = i * cam.width;
      }
    }

    int sx = start_pos % cam.width;
    int sy = start_pos / cam.width;

    int ex = end_pos % cam.width;
    int ey = end_pos / cam.width;

    captured = cam.get(sx, sy, ex, ey);
    captured.resize((int) handler.NORMAL_WIDTH, (int) height);

    captured.loadPixels();
    for (int i = 0; i < captured.width; i++) {
      for (int j = 0; j < captured.height; j++) {
        int col = captured.pixels[captured.width - 1 - i + j * captured.width];
        int ctb = get(i, j);

        int re = abs((col >> 16) & 0xFF - (ctb >> 16) & 0xFF);
        int ge = abs((col >> 8) & 0xFF - (ctb >> 8) & 0xFF);
        int be = abs((col) & 0xFF - (ctb) & 0xFF);

        /**if (re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR) {
         captured.pixels[captured.width - 1 - i + j * captured.width] = 0xFFFF00FF;
         }*/
      }
      captured.updatePixels();
    }
  }

  public void render() {
    fill(COLOR_START);
    rect(0, 0, PIXEL_SIZE, PIXEL_SIZE);
    fill(COLOR_END);
    rect(handler.NORMAL_WIDTH - PIXEL_SIZE, height - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
  }
}
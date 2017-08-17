import processing.video.*;
import java.util.Arrays;

public class CameraReader {

  public class Hand {
    public int x, y, count;
    public Hand(int x, int y, int count) {
      this.x = x;
      this.y = y;
      this.count = count;
    }
  }

  // #00E8F2
  // #FA8508

  public static final int PIXEL_SIZE = 50;
  public static final boolean USE_CAMERA = false;

  public int MAX_ERROR = 0x0A;
  

  public ArrayList<Hand> hands = new ArrayList<Hand>();
  public int[] lastPixels;
  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    cam = new Capture(self, 960, 544);
    if (cam != null) cam.start();
  }

  public int countSurrounding(boolean[] alive, int x, int y) {
    int count = 0;
    for (int i = 0; i < 9; i++) {
      int xoff = (i % 3) - 1;
      int yoff = (i / 3) - 1;
      if (xoff == yoff && xoff == 0) continue; // Prevent from counting itself
      if (x + xoff < 0 || y + yoff < 0 || x + xoff >= xmax - xmin || y + yoff >= ymax - ymin) continue;
      int index = (x + xoff) + (y + yoff) * (xmax - xmin);
      if (alive[index]) ++count;
    }
    return count;
  }

  // Essentially floodfill...
  public int searchRecursive(int[] colors, int x, int y, int depth) {
    int foundPixels = 0; // T
    if (depth > 10) return 0;
    if (colors[x + y * cam.width] == 0xFFFF00FF) {
      colors[x + y * cam.width] = 0x7FFF00FF; // Unset the first bit

      ++foundPixels; // We were found

      // recursion...
      if (x < xmax - 1) foundPixels += searchRecursive(colors, x + 1, y, depth + 1);
      if (x > xmin) foundPixels += searchRecursive(colors, x - 1, y, depth + 1);
      if (y < ymax - 1) foundPixels += searchRecursive(colors, x, y + 1, depth + 1);
      if (y > ymin) foundPixels += searchRecursive(colors, x, y - 1, depth + 1);
    }
    return foundPixels;
  }

  public void bringToLive() {
    boolean[] alive = new boolean[(ymax - ymin) * (xmax - xmin)];
    for (int i = xmin; i < xmax; i++) {
      for (int j = ymin; j < ymax; j++) {
        int col = cam.pixels[i + j * cam.width];
        int re = abs(abs((col >> 16) & 0xFF) - abs((colorToBe >> 16) & 0xFF));
        if (i == xmin || j == ymin || i == xmax - 1 || j == ymax -1) cam.pixels[i+ j * cam.width] = 0xFFFF00FF;
        if (re < MAX_ERROR) alive[(i - xmin)+ (j-ymin) * (xmax - xmin)] = true;
      }
    }

    for (int i = 0; i < xmax-xmin; i++) {
      for (int j = 0; j < ymax-ymin; j++) {
        int index = i + j * (xmax-xmin);
        int surrounding = countSurrounding(alive, i, j);
        if (!((alive[index] && surrounding >= 3) || surrounding >= 7)) {
          cam.pixels[(i + xmin) + (j + ymin) * cam.width] = 0xFFFF00FF;
        }
      }
    }
    hands.clear();
    for (int i = xmin; i < xmax; i++) {
      for (int j = ymin; j < ymax; j++) {
        if (cam.pixels[i + j * cam.width] == 0xFFFF00FF) {
          hands.add(new Hand((i - xmin) * width / (xmax-xmin), (j - ymin) * height / (ymax - ymin), searchRecursive(cam.pixels, i, j, 0)));
        }
      }
    }
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();
    
    bringToLive();

    lastPixels = Arrays.copyOf(cam.pixels, cam.pixels.length);

    cam.updatePixels();
  }

  public void render() {
    /**fill(COLOR_START);
     rect(0, 0, PIXEL_SIZE, PIXEL_SIZE);
     fill(COLOR_END);
     rect(handler.NORMAL_WIDTH - PIXEL_SIZE, height - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);*/
  }
}
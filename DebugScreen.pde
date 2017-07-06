public class DebugScreen extends Screen {

  public static final boolean INVERTED = false;

  public void render() {
    if (CameraReader.USE_CAMERA) {
      if (INVERTED) {
        pushMatrix();
        scale(-1.0, 1.0);
        image(handler.input.reader.captured.get(handler.NORMAL_WIDTH - width - getPos(), 0, width, height), -width, 0); //positioning is key
        popMatrix();
      } else {
        image(handler.input.reader.captured.get(getPos(), 0, width, height), 0, 0); //positioning is key
      }
    }
  }

  public void onClick(float x, float y) {
    int col = handler.input.reader.captured.get(handler.NORMAL_WIDTH - width - getPos(), 0, width, height).get((int)(width - x), (int) y);
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(col));
  }
}
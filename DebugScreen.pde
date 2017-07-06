public class DebugScreen extends Screen {

  public static final boolean X_INVERTED = false;
  public static final boolean Y_INVERTED = false;

  public void render() {
    if (CameraReader.USE_CAMERA) {
      pushMatrix();
      scale(X_INVERTED ? -1.0 : 1.0, Y_INVERTED ? -1.0 : 1.0);
      image(handler.input.reader.captured.get(X_INVERTED ? (handler.NORMAL_WIDTH - width - getPos()) : getPos(), 0, width, height), X_INVERTED ? -width : 0, Y_INVERTED ? -height : 0); //positioning is key
      popMatrix();
    }
  }

  public void onClick(float x, float y) {
    int col = handler.input.reader.captured.get(handler.NORMAL_WIDTH - width - getPos(), 0, width, height).get((int)(width - x), (int) y);
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(col));
  }
}
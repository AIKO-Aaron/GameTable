public class DebugScreen extends Screen {

  public static final boolean X_INVERTED = true;
  public static final boolean Y_INVERTED = true;

  public void render() {
    if (CameraReader.USE_CAMERA) {
      pushMatrix();
      scale(X_INVERTED ? -1.0 : 1.0, Y_INVERTED ? -1.0 : 1.0);
      image(handler.input.reader.cam.get(X_INVERTED ? (handler.NORMAL_WIDTH - width - getPos()) : getPos(), 0, width, height), X_INVERTED ? -width : 0, Y_INVERTED ? -height : 0); //positioning is key
      popMatrix();
      
      // image(handler.input.reader.cam, 0, 0, width, height);
    }
  }

  public void onClick(float x, float y) {
    int col = handler.input.reader.cam.get(X_INVERTED ? (handler.NORMAL_WIDTH - width - getPos()) : getPos(), 0, width, height).get(X_INVERTED ? (int)(width - x) : (int) x, Y_INVERTED ? (int)(height - y) : (int) y);
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(col));
  }
}
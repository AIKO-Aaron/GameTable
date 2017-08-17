public class DebugScreen extends Screen {

  public static final boolean X_INVERTED = false;
  public static final boolean Y_INVERTED = false;

  public void render() {
    if (CameraReader.USE_CAMERA) {
      /**pushMatrix();
      scale((X_INVERTED ? -1.0 : 1.0) * width / handler.input.reader.cam.width, (Y_INVERTED ? -1.0 : 1.0) * height / handler.input.reader.cam.height);
      image(handler.input.reader.cam.get(X_INVERTED ? (handler.NORMAL_WIDTH - width - getPos()) : getPos(), 0, width, height), X_INVERTED ? -width : 0, Y_INVERTED ? -height : 0); //positioning is key
      popMatrix();*/
      
      image(handler.input.reader.cam.get(xmin, ymin, xmax-xmin, ymax-ymin), 0, 0, width, height);
    }
  }

  public void onClick(float x, float y) {
    colorToBe = handler.input.reader.cam.get(X_INVERTED ? (handler.NORMAL_WIDTH - width - getPos()) : getPos(), 0, width, height).get(X_INVERTED ? (int)(width - x) : (int) x, Y_INVERTED ? (int)(height - y) : (int) y);
    xpos = (int) x;
    ypos = (int) y;
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(colorToBe));
  }
}
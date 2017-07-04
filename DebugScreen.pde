public class DebugScreen extends Screen {

  public void render() {
    pushMatrix();
    scale(-1.0, 1.0);
    if (CameraReader.USE_CAMERA) image(handler.input.reader.cam.get(handler.NORMAL_WIDTH - width - getPos(), 0, width, height), -width, 0); //positioning is key
    popMatrix();
  }

  public void onClick(float x, float y) {
    int col = handler.input.reader.cam.get(handler.NORMAL_WIDTH - width - getPos(), 0, width, height).get((int)(width - x), (int) y);
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(col));
    handler.input.reader.selectedColors.add(col);
  }
}
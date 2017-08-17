public class ColorScreen extends Screen {
 
  private int col = 0xFF000000;
  
  public void render() {
    fill(col);
    rect(0, 0, width, height);
    
    ++startTime;
  }
  
  public void onClick(float x, float y) {
    // closeScreen();
    col = 0xFFFFFFFF;
    startTime = 0;
  }
  
}
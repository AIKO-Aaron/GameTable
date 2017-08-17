import java.lang.reflect.*;

/**
 A button for the HomeScreen
 */
public class MenuButton {

  public static final int BUTTON_COLOR = 0xFF4444FF; // Color when the button is in its normal state
  public static final int BUTTON_BORDER = 0xFF006000;
  public static final int HOVER_COLOR = 0xFF9F0000; // Color when the mouse is over this button
  public static final int TEXT_COLOR = 0xFFFFFFFF; // The color of the text

  private float x, y, w, h, r; // The x, y, widht, height & radius of the button (radius --> corners)
  private String text; // The text this button contains
  private boolean inside = false; // if the mouse was over the button or not

  public float timeOver = 0;
  public Class<? extends Screen> toOpen;
  public Screen parent;

  public MenuButton(int x, int y, int w, int h, String text, Class<? extends Screen> toOpen, Screen parent) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.toOpen = toOpen;
    this.parent = parent;
    this.r = Math.min(w, h) / 2;
    this.text = text;
  }

  public void onClick() { // instance is equal to this
    try {      
      Screen s = toOpen.getConstructor(new Class[] {GameTable.class}).newInstance(new Object[] { self });
      parent.setScreen(s);
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  /**
   Renders this button
   */
  public void render(int sp) {
    textFont(createFont("Arial", h, false));
    textAlign(LEFT, LEFT);

    float percentage = timeOver / 100.0;

    if (percentage == 0) {
      fill(BUTTON_COLOR);
      stroke(BUTTON_BORDER);
      rect(x, y, w, h, r, r, r, r);
      rect(x, y + h, w, h, r, r, r, r);
    } else if (percentage <= 1.0) {
      fill(BUTTON_COLOR);
      stroke(BUTTON_BORDER);
      rect(x + (percentage * w), y, (1-percentage) * w, h, 0, r, r, 0);
      rect(x + (percentage * w), y + h, (1-percentage) * w, h, 0, r, r, 0);

      fill(HOVER_COLOR);
      stroke(BUTTON_BORDER);
      rect(x, y, (percentage * w), h, r, 0, 0, r);
      rect(x, y + h, (percentage *  w), h, r, 0, 0, r);
    } else onClick();

    if (inside) ++timeOver;
    else timeOver = 0;


    noStroke();

    float wi = textWidth(text); // Text width to center it

    fill(TEXT_COLOR);
    text(text, x + w / 2 - wi / 2, y + h - h / 5);

    pushMatrix();
    rotate(PI);
    text(text, -width + (x + w / 2 - wi / 2), -(y + h + h / 5));
    popMatrix();
  }

  /**
   Check if mouse is over the button 
   */
  public void handleUserInput(int x, int y) {
    inside = x >= this.x && x <= this.x + this.w && y >= this.y && y <= this.y + this.h * 2;
  }

  public boolean isInside(float x, float y) {
    return x >= this.x && x <= this.x + this.w && y >= this.y && y <= this.y + this.h * 2;
  }
}
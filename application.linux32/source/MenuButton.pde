import java.lang.reflect.*;

/**
 A button for the HomeScreen
 */
public class MenuButton {

  public static final int BUTTON_COLOR = 0xFF00A000; // Color when the button is in its normal state
  public static final int BUTTON_BORDER = 0xFF006000;
  public static final int HOVER_COLOR = 0xFF4444FF; // Color when the mouse is over this button
  public static final int TEXT_COLOR = 0xFFFFFFFF; // The color of the text

  public static final float STAY_OVER_TIME = 60 * 5.0;

  private int x, y, w, h, r; // The x, y, widht, height & radius of the button (radius --> corners)
  private String text; // The text this button contains
  private boolean inside = false; // if the mouse was over the button or not

  public int timeOver = 0;
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
    textAlign(LEFT, LEFT);
    fill(inside ? HOVER_COLOR : BUTTON_COLOR);
    stroke(BUTTON_BORDER);
    rect(x, y, w, h, r, r, r, r);

    for (PVector p : handler.input.getInside(sp)) {
      if (isInside(p.x, p.y)) {
        fill(0xFFFF00FF);
        arc(p.x, p.y, 20, 20, 0, TWO_PI * p.z / STAY_OVER_TIME);

        if (p.z == STAY_OVER_TIME) onClick(p.x, p.y);
      }
    }

    noStroke();

    float wi = textWidth(text); // Text width to center it

    fill(TEXT_COLOR);
    text(text, x + w / 2 - wi / 2, y + h / 2);
  }

  /**
   Check if mouse is over the button 
   */
  public void handleUserInput(int x, int y) {
    inside = x >= this.x && x <= this.x + this.w && y >= this.y && y <= this.y + this.h;
  }

  public boolean isInside(float x, float y) {
    return x >= this.x && x <= this.x + this.w && y >= this.y && y <= this.y + this.h;
  }

  /**
   If the button has been clicked
   */
  public void onClick(float x, float y) {
    if (x >= this.x && x <= this.x + this.w && y >= this.y && y <= this.y + this.h) {
      // TODO action
      onClick();
    }
  }
}
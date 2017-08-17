public class ScreenCredits extends Screen {

  /**
   Das isch de besti Screen im ganze Programm inne
   */

  String text = 
    "Created by:\n" +
    "Me, myself & I\n" +
    "\n" +
    "Für KantiBeiz\n" +
    "@ BadenerFahrt 2017\n" +
    "\n" + 
    "©2017\n" +
    "All rights reserved\n";

  public void render() {
    textAlign(TOP, CENTER);
    fill(0);
    rect(0, 0, width, height);
    fill(0xFF);
    text(text, width / 2 - textWidth(text) / 2, height / 2);
  }

  public void onClick(float x, float y) {
    closeScreen();
  }
}
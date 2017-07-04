/**
 Basic screen with function render & onclick
 */
public abstract class Screen implements ReceiveEventHandler {

  public int id;

  public Screen() {
    id = (int) random(9000) + 1000;
    while (handler != null && handler.idInUse(id)) id = (int) random(9000) + 1000; // NEW random id
  }

  /**
   Replaces the current screen with another one
   */
  public void setScreen(Screen s) {
    handler.setScreen(this, s);
  }

  /**
   Closes this screen --> replaces it with a homescreen
   */
  public void closeScreen() {
    handler.removeScreen(this);
  }

  /**
   Creates particles on this screen at the position x | y
   */
  public void createParticles(int amount, float x, float y, int min, int max) {
    handler.createParticles(amount, x + handler.getPos(this), y, min, max);
  }

  public int getPos() {
    return handler.getPos(this);
  }

  public void onReceive(ServerClient client, String data) {
    // Only called when data was received after the initial connection was established without closing the socket
    println("norm: " + data);
  }

  public boolean onConnect(ServerClient client, String data) {
    println(data);
    return true; // If true disconnect the socket
  }

  public void onClose() {}


  /**
   Renders stuff on this screen
   */
  public abstract void render();

  /**
   Called when the mouse button has been clicked
   */
  public abstract void onClick(float x, float y);
}
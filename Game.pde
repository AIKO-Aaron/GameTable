/**
  Extension of the screen with input & update methods (update just to separate code)
*/
public abstract class Game extends Screen {

  public int userCount = 0;

  /**
    Why do I have a variable userCount? I don't know.
  */
  public Game(int users) {
    userCount = users;    
  }
  
  public Game() {
    userCount = 1; // default is one user 
  }
  
  /**
    Handles the user input
  */
  public abstract void handleUserInput(int x, int y);
  
  /**
    Called when the game should be updated
  */
  public abstract void update();
}
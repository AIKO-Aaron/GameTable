/**
 Extends game because we need the handleUserInput function
 */
public class HomeScreen extends Game {
  public static final int GAMES_PER_LINE = 5; // TODO

  private ArrayList<PImage> gameImages = new ArrayList<PImage>(); // Should replace the buttons, or the images on the buttons
  private ArrayList<MenuButton> buttons = new ArrayList<MenuButton>(); // The buttons rendered in the menu

  public static final int AMOUNT_BUTTONS = 5;

  public HomeScreen() {
    // gameImages.add(loadImage("/hhh"));
    super(0);

    updateGames();
  }

  public void update() {
  }

  public void updateGames() {
    if (handler == null || handler.registeredGames == null || handler.registeredNames == null) return;
    buttons.clear();
    int size = handler.registeredGames.size();
    for (int i = 0; i < size; i++) {
      Class<? extends Screen> screenClass = handler.registeredGames.get(i);
      String name = handler.registeredNames.get(i);
      if (screenClass == null || name == null) continue;
      buttons.add(new MenuButton(0, (int)((i + (float) size / 2.0) * height / (size * 2)), width, height / (size * 2), name, screenClass, this));
    }
  }

  public void handleUserInput(int x, int y) {
    for (MenuButton button : buttons) button.handleUserInput(x, y);
  }

  public void render() {
    fill(0);
    rect(0, 0, width, height);

    int index = 0;
    for (PImage img : gameImages) {
      int xPosition = (index % GAMES_PER_LINE) * width / GAMES_PER_LINE;
      int yPosition = (index / GAMES_PER_LINE) * height / GAMES_PER_LINE;

      image(img, xPosition, yPosition, width / GAMES_PER_LINE, height / GAMES_PER_LINE);
    }

    for (MenuButton button : buttons) button.render(handler.indexOf(this));
  }

  void onClick(float x, float y) {
    // setScreen(y < height / 2 ? new GamePianoTiles() : new GamePong());
    // setScreen(new GamePianoTiles(height / width));
    for (MenuButton button : buttons) button.onClick(x, y);
  }
}
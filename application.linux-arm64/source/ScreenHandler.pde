/**
 Handles the screen
 */

public class ScreenHandler implements ReceiveEventHandler {

  public static final int MAX_SIMULT_SCREENS = 3; // How many games are simoultanously run
  public int NORMAL_WIDTH = 0; // The width the whole screen has
  private Screen[] currentScreens = new Screen[MAX_SIMULT_SCREENS]; // The screens which are displayed
  private ArrayList<ParticleGenerator> particleGenerators = new ArrayList<ParticleGenerator>(); // All the particles on the displays
  private ArrayList<Class<? extends Screen>> registeredGames = new ArrayList<Class<? extends Screen>>();
  private ArrayList<String> registeredNames = new ArrayList<String>();

  public CameraInput input = new CameraInput();

  /**
   Sets up the screen
   */
  public ScreenHandler() {
    NORMAL_WIDTH = width;
    width /= MAX_SIMULT_SCREENS;
    for (int i = 0; i < MAX_SIMULT_SCREENS; i++) currentScreens[i] = new HomeScreen();
  }

  public void registerGame(Class<? extends Screen> gameToAdd, String name) {
    registeredGames.add(gameToAdd);
    registeredNames.add(name);
    for (Screen s : currentScreens) {
      if (s instanceof HomeScreen) {
        ((HomeScreen) s).updateGames();
      }
    }
  }

  public void onReceive(ServerClient client, String data) {
    // Only called when data was received after the initial connection was established without closing the socket
    println("norm: " + data);
  }

  public boolean idInUse(int id) {
    for (Screen s : currentScreens) if (s.id == id) return true;
    return false;
  }

  public Screen getScreenById(int id) {
    for (Screen s : currentScreens) if (s.id == id) return s;
    return null;
  }

  public boolean onConnect(ServerClient client, String data) {
    if (data.startsWith("!")) {
      String code = data.substring(1, 3);
      String[] args = data.substring(data.indexOf("<") + 1, data.lastIndexOf(">")).split(",");

      switch(code) {
      case "cg":
        println("Connecting to game: " + args[0]);
        try {
          for (Screen s : currentScreens) if (s.id == Integer.parseInt(args[0])) s.onConnect(client, "connect");
        } 
        catch(Exception e) {
        }
        break;
      case "gc":
        int id = Integer.parseInt(args[0]);
        String nc = args[1];
        for (Screen s : currentScreens) if (s.id == id) return s.onConnect(client, nc);
        break;
      }
    }
    return true; // If true disconnect the socket
  }

  /**
   Render all the particles
   */
  public void renderParticles() {
    for (int i = 0; i < particleGenerators.size(); i++) { // YAY Particles!
      ParticleGenerator pg = particleGenerators.get(i); 
      if (pg == null) continue; 
      if (pg.render()) particleGenerators.remove(pg);
    }
  }

  /**
   Render all the screens.
   Set width to the actual width of one screen
   And reset it to the normal size
   */
  public void renderScreens() {
    input.update();

    for (int i = 0; i < MAX_SIMULT_SCREENS; i++) {
      Screen cs = currentScreens[i];
      if (cs == null) cs = currentScreens[i] = new HomeScreen();

      //pushMatrix(); 
      translate(width * i, 0); // Move to side --> offset
      clip(0, 0, width, height); // Only allow drawing in this rectangle --> no more particles in other screens?
      // TODO handle hand input

      input.updateScreen(cs, i);

      if (cs instanceof Game) {
        ((Game) cs).update();
      }


      cs.render(); 

      noClip(); // remove clipping
      translate(-width * i, 0); // Move back
      //popMatrix();
    }
  }  

  /**
   Render all the things
   */
  public void render() {
    renderScreens();
    renderParticles();
  }

  /**
   When the mouse has been clicked
   */
  public void onClick(float x, float y) {
    int screenClicked = (int)(x / width);
    if (screenClicked > MAX_SIMULT_SCREENS) return;
    Screen cs = currentScreens[screenClicked];
    if (cs != null) cs.onClick(x - screenClicked * width, y);
  }

  public int indexOf(Screen s) {
    int i = 0;
    for (; i < MAX_SIMULT_SCREENS; i++) if (currentScreens[i] == s) break;
    return i;
  }

  /** Only to be called when width is the width of one screen
   */
  public int getPos(Screen s) {
    return indexOf(s) * width;
  }

  public void removeScreen(int i) {
    currentScreens[i].onClose();
    currentScreens[i] = new HomeScreen();
  }

  /**
   Creates particles
   */
  public void createParticles(int amount, float x, float y, int min, int max) {
    particleGenerators.add(new ParticleGenerator(amount, x, y, min, max));
  }

  /**
   Sets the screen to a homescreen
   */
  public void removeScreen(Screen s) {
    s.onClose();
    currentScreens[indexOf(s)] = new HomeScreen();
  }

  /**
   Replaces the screen o with n
   */
  public void setScreen(Screen o, Screen n) {
    o.onClose();
    currentScreens[indexOf(o)] = n;
  }
}
ScreenHandler handler;
WebProcess web;

int lastTime = 0, fps = 0, lastFPS = 0; // FPS counter xD
PApplet self = this;

public static final Thread.UncaughtExceptionHandler eh = new Thread.UncaughtExceptionHandler() {
  @Override
    public void uncaughtException(Thread t, Throwable e) {
    println("Thread crashed");
    println(t);
    e.printStackTrace();
    // System.exit(0);
  }
};

/**

  WICHTIG:
  ALLI SPIEL BRUUCHED EN CONSTRUCTOR OHNI PARAMETER!
  ALLES WO MER MUES MACHE ISCH NOCHHER handler.register(SPIEL.class, "SPIELNAME"); IM SETUP O.Ä.
  JAVA.LANG.REFLECT FOR THE WIN

*/

//
// raumhöhe --> 2.5m
// Dach --> 50cm
// 

/**
 
 - Airhockey
 - Doodle Jump
 - Tetris --> WIP
 - Beer pong
 - Fruit ninja --> WIP
 - 
 
 */

/**
 Verbesserungen:
 
 - Handy --> Webinterface --> Steuerung? --> Done
 */

void settings() {
  size(960, 540);
  Thread.setDefaultUncaughtExceptionHandler(eh); // Redirect errors to the exceptionhandler right?
}

void setup() {
  //fullScreen();
  noStroke();


  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run() {
      for (Screen s : handler.currentScreens) s.onClose();
    }
  }
  ));

  handler = new ScreenHandler();
  web = new WebProcess("base/index_base.html", handler);

  handler.registerGame(GameTetris.class, "Tetris");
  handler.registerGame(GamePong.class, "Pong");
  handler.registerGame(GamePianoTiles.class, "Piano Tiles");
  handler.registerGame(GameFruitNinja.class, "FruitNinja");
  handler.registerGame(ScreenCredits.class, "Credits");
  handler.registerGame(DebugScreen.class, "Debug");

  frameRate(60); // 60 FPS
}

void draw() {
  handler.render();
  if (millis() >= lastTime + 1000) {
    // println(fps);
    lastTime = millis();
    lastFPS = fps;
    fps = 0;
  } else ++fps;
  text("Hello World", 0, -10); // S'erschte mal text zeichne goht echli länger drum machemers do.
}

void mousePressed() {
  // handler.onClick(mouseX, mouseY);
}
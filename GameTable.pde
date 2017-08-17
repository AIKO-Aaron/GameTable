ScreenHandler handler;
WebProcess web;

int lastTime = 0, fps = 0, lastFPS = 0; // FPS counter xD
PApplet self = this;
boolean rendering = true;
int startTime = 0;
boolean setup = !CameraReader.USE_CAMERA;
int lastMouse = 0;
int xmin, ymin, xmax, ymax;
int colorToBe = 0xFFFFFFFF, xpos, ypos;

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
  size(960, 544);
  fullScreen();
  Thread.setDefaultUncaughtExceptionHandler(eh); // Redirect errors to the exceptionhandler right?
}

void setup() {
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
  fill(0xFFFFFFFF);
  rect(0, 0, width, height);

  text("Hello World", 0, -10); // S'erschte mal text zeichne goht echli länger drum machemers do.
}

void draw() {
  if (setup) {
    clear();
    if (rendering) handler.render();
    if (millis() >= lastTime + 1000) {
      // println(fps);
      lastTime = millis();
      lastFPS = fps;
      fps = 0;
    } else ++fps;
    handler.input.render();
  } else if(CameraReader.USE_CAMERA) {
    clear();
    handler.input.reader.cam.read();
    image(handler.input.reader.cam, 0, 0, width, height);
    fill(0xFFFF00FF);
    rect(xmin * width / handler.input.reader.cam.width, ymin * height / handler.input.reader.cam.height, (xmax - xmin) * width / handler.input.reader.cam.width, (ymax - ymin) * height / handler.input.reader.cam.height);
   
    if (mouseButton == 37 && lastMouse == 0) {
      lastMouse = 37;
      xmin = mouseX * handler.input.reader.cam.width / width;
      ymin = mouseY * handler.input.reader.cam.height / height;
    } else if (mouseButton == 0 && lastMouse == 37) {
      lastMouse = 0;
      xmax = mouseX * handler.input.reader.cam.width / width;
      ymax = mouseY * handler.input.reader.cam.height / height;
      println("Setup done");
      setup = true;
    } else if(mouseButton == 37) {
      xmax = mouseX * handler.input.reader.cam.width / width;
      ymax = mouseY * handler.input.reader.cam.height / height;
    }
  }
}

void mouseReleased() {
  if(mouseButton == 37) setup = true;
}

void mousePressed() {
  // handler.onClick(mouseX, mouseY);
  //if(keyCode == VK_ESCAPE) System.exit(0);
}
import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import java.lang.reflect.*; 
import java.io.*; 
import java.net.*; 
import java.util.regex.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GameTable extends PApplet {

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
  ALLES WO MER MUES MACHE ISCH NOCHHER handler.register(SPIEL.class, "SPIELNAME"); IM SETUP O.\u00c4.
  JAVA.LANG.REFLECT FOR THE WIN

*/

//
// raumh\u00f6he --> 2.5m
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

public void settings() {
  size(960, 540);
  Thread.setDefaultUncaughtExceptionHandler(eh); // Redirect errors to the exceptionhandler right?
}

public void setup() {
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
  handler.registerGame(DebugScreen.class, "Debug");

  frameRate(60); // 60 FPS
}

public void draw() {
  handler.render();
  if (millis() >= lastTime + 1000) {
    // println(fps);
    lastTime = millis();
    lastFPS = fps;
    fps = 0;
  } else ++fps;
  text("Hello World", 0, -10); // S'erschte mal text zeichne goht echli l\u00e4nger drum machemers do.
}

public void mousePressed() {
  // handler.onClick(mouseX, mouseY);
}
public class CameraInput {
  private ArrayList<PVector> lastTrackedHands = new ArrayList<PVector>();
  private ArrayList<Integer> clicking = new ArrayList<Integer>(); // How long the same hand is on the same spot

  public static final int NOT_PRESSED = 0;
  public static final int PRESSED = 1;
  public static final int PULLED = 2;

  public static final int MAX_MOTION = 4;

  public CameraReader reader = new CameraReader();

  public void update() {
    reader.update();

    if (lastTrackedHands.size() < 1) lastTrackedHands.add(new PVector(mouseX, mouseY, 0));
    if (clicking.size() < 1) clicking.add(mousePressed ? PRESSED : NOT_PRESSED);
    // if(timeOut.size() < 1) timeOut.add(new PVector(mouseX, mouseY, 0));

    PVector p = lastTrackedHands.get(0);
    if (abs(p.x - mouseX) <= MAX_MOTION && abs(p.y - mouseY) <= MAX_MOTION) {
      p.z++;
      p.x = mouseX;
      p.y = mouseY;
    } else {
      p.z = 0;
      p.x = mouseX;
      p.y = mouseY;
    }
    if (p.z > 15 * 60) handler.removeScreen(mouseX / width); // onClose gets called right?

    lastTrackedHands.set(0, p);

    // lastTrackedHands.set(0, new PVector(mouseX, mouseY));
    if (clicking.get(0) != PULLED || !mousePressed) clicking.set(0, mousePressed ? PRESSED : NOT_PRESSED);

    for (int j = 0; j < clicking.size(); j++) {
      if (clicking.get(j) == PRESSED) {
        handler.onClick((int) lastTrackedHands.get(j).x, (int) lastTrackedHands.get(j).y);
        clicking.set(0, PULLED);
      }
    }
  }

  public void resetTimer() {
    for (int i = 0; i < lastTrackedHands.size(); i++) lastTrackedHands.set(i, new PVector(lastTrackedHands.get(i).x, lastTrackedHands.get(i).y, 0));
  }

  public void updateGame(Game g, int i) {
    if (g != null) {
      for (int j = 0; j < lastTrackedHands.size(); j++) {
        PVector hand = lastTrackedHands.get(j);
        if (hand != null && hand.x > i * width && hand.x < (i + 1) * width) {
          g.handleUserInput((int) hand.x - i * width, (int) hand.y);
        }
      }
    }
  }

  public ArrayList<PVector> getInside(int screenNum) {
    ArrayList<PVector> l = new ArrayList<PVector>();
    for (PVector p : lastTrackedHands) {
      if (p.x > screenNum * width && p.x < (screenNum + 1) * width) l.add(new PVector(p.x - screenNum * width, p.y, p.z));
    }
    return l;
  }

  public void updateScreen(Screen s, int i) {
    if (s instanceof Game) {
      updateGame((Game) s, i);
    }
  }
}


public class CameraReader {

  public static final boolean USE_CAMERA = true;

  public static final int MAX_ERROR = 0x10;

  private ArrayList<Integer> selectedColors = new ArrayList<Integer>();

  public Capture cam;

  public CameraReader() {
    if (!USE_CAMERA) return;

    String toUse = null;

    for (String s : Capture.list()) {
      if (!s.startsWith("FaceTime HD")) {
        println(s); 
        toUse = s;
      }
    }

    if (Capture.list().length == 0) return;

    if (toUse == null) toUse = "FaceTime HD Camera";

    cam = new Capture(self, 960, 540, toUse, 30);
    cam.start();
  }

  public void update() {
    if (cam == null || !cam.available()) return;

    cam.read();

    cam.loadPixels();
    for (int i = 0; i < cam.pixels.length; i++) {
      int col = cam.pixels[i];

      int r = (col & 0xFF0000) >> 16;
      int g = (col & 0x00FF00) >> 8;
      int b = (col & 0x0000FF);

      for (Integer sc : selectedColors) {
        int hr = (sc & 0xFF0000) >> 16;
        int hg = (sc & 0x00FF00) >> 8;
        int hb = (sc & 0x0000FF);

        int re = abs(r - hr);
        int ge = abs(g - hg);
        int be = abs(b - hb);

        if (re < MAX_ERROR && ge < MAX_ERROR && be < MAX_ERROR) {
          cam.pixels[i] = 0xFFFF00FF;
        }
      }
    }
  }
}

public class DebugScreen extends Screen {

  public void render() {
    pushMatrix();
    scale(-1.0f, 1.0f);
    if (CameraReader.USE_CAMERA) image(handler.input.reader.cam.get(960 - width - getPos(), 0, width, height), -width, 0); //positioning is key
    popMatrix();
  }

  public void onClick(float x, float y) {
    int col = handler.input.reader.cam.get(960 - width - getPos(), 0, width, height).get((int)(width - x), (int) y);
    println("color @pos " + x + "|" + y + ": " + Integer.toHexString(col));
    handler.input.reader.selectedColors.add(col);
  }
}
/**
  Extension of the screen with input & update methods (update just to separate code)
*/
public abstract class Game extends Screen {

  protected int userCount = 0;

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
public class GameFruitNinja extends Game {

  public static final int MAX_POSITIONS = 10;
  public static final int BLADE_GROESSE = 2;
  public static final int BLADE_COLOR = 0xFF5050FF;
  public static final int FRUITE_FREQ = 0;
  public static final int FRUITE_MAXAMOUNT = 2;

  private ArrayList<PVector> lastPositions = new ArrayList<PVector>();
  private PImage bg;
  private ArrayList<PVector> Fruits = new ArrayList<PVector>();
  private ArrayList<PVector> FruitsPos = new ArrayList<PVector>();
  private int timer = 0;
  private int counter = 0;

  public GameFruitNinja() {
    super(1);

    bg = loadImage("textures/FruitNinja/fruitNinja_bg.jpg");
  }


  public void render() {
    image(bg, 0, 0, width, height);
    Blade_render();
  }
  public void update() {
    timer++;
    if (timer > 30 && lastPositions.size() > 0) lastPositions.remove(0); // Outofbounds!


    if (frameRate * FRUITE_FREQ > counter) {
      counter++;
    } else {
      if (Fruits.size() < FRUITE_MAXAMOUNT) {
        //FruitsPos(x pos, y pos, type)
        FruitsPos.add(new PVector(50, 0));
        //Fruits(X vector, Y vector);
        Fruits.add(new PVector(5, 5));
        counter = 0;
      }
    }
    //add Vector to pos
    for (int f = 0; f < Fruits.size(); f++) {
      (FruitsPos.get(f)).add(Fruits.get(f));
    }
    //Modify Vector, gravity

    //remove Fruits out of bound
    for (int f = 0; f < Fruits.size(); f++) {
      if  (FruitsPos.get(f).x<0) {
        Fruits.remove(f);
        FruitsPos.remove(f);
      }
    }
  }

  public void handleUserInput(int x, int y) {
    lastPositions.add(new PVector(x, y));
    if (lastPositions.size() > MAX_POSITIONS) lastPositions.remove(0);
    timer = 0;
  }

  public void onClick(float x, float y) {
  }

  public void Blade_render() {
    stroke(0xFFF0F0FF);
    rectMode(CENTER);
    fill(BLADE_COLOR);
    for (int j = 0; j <= lastPositions.size() - 1; j++) {
      PVector p = lastPositions.get(j);
      int i = j;
      rect(p.x, p.y, BLADE_GROESSE * i, BLADE_GROESSE* i);
    }

    rectMode(CORNER);
    noStroke();
  }

  public void Fruit_render() {
    for (int f = 0; f < Fruits.size(); f++) {
      ellipse(FruitsPos.get(f).x, FruitsPos.get(f).y, 40, 40);
    }
  }
}
// LOL fehlt nur no Geometry dash xD

public class GamePianoTiles extends Game {

  private static final float STARTING_SPEED = 2;
  // private static final float ASPECT_RATIO = 540.0 / 240.0; // height / width --> on setup maybe
  private static final int FIELDS = 6;

  private int offset;
  private int nextPressed;
  private float w, h, xStart;
  private float speed;
  private boolean running = false;
  private ArrayList<Integer> nextTiles = new ArrayList<Integer>();
  private float aspectRatio = 0.0f;

  public GamePianoTiles() {
    super(1);
    aspectRatio = (float) height / (float) width;
    begin();
  }

  public void begin() {
    h = height / FIELDS;
    w = h / aspectRatio;
    xStart = (width - FIELDS * w) / 2;

    speed = STARTING_SPEED; // Default speed
    offset = -height; // Vorbereitungszeit

    nextPressed = FIELDS + 1;
    nextTiles.clear();
    for (int i = 0; i <= FIELDS; i++) createNext();

    running = true;
  }

  public void createNext() {
    nextTiles.add((int) random(FIELDS));
    if (--nextPressed < 0) {
      running = false;
      fill(0xFF);
      rect(0, 0, width, height);

      stroke(0);
      fill(0);
      text("Verlor\u00e4", 100, 100);
      text("P\u00fcnkt: " + speed, 80, 120);
      println("Lost");
      speed = 0;
    }
    if (nextTiles.size() > FIELDS + 1) nextTiles.remove(0);
  }

  public void render() {
    if (!running) return;

    fill(0xFF);
    rect(0, 0, width, height);

    stroke(0);

    fill(0xFF, 0x0, 0xFF);
    text("Speed: " + speed + ", offset:" + offset, 50, 50);

    for (int i = 0; i <= FIELDS; i++) {
      line(xStart + w * i, 0, xStart + w * i, height);
      line(xStart, h * i - offset, xStart + w * FIELDS, h * i - offset);

      int p = nextTiles.get(i);
      fill(i < nextPressed ? 0x7F : 0);
      rect(xStart + w * p, h * i - offset, w, h);
      //println(xStart);
    }
    noStroke();
  }

  public void update() {
    offset += speed;
    if (offset >= h) {
      createNext();
      offset = 0; // % h
    }

    if (running) speed += (1.0f / 60.0f) / 5.0f;
  }

  public void handleUserInput(int x, int y) {
    if (nextPressed < FIELDS && nextPressed >= 0 && x > xStart + w * nextTiles.get(nextPressed) && x < xStart + w * nextTiles.get(nextPressed) + w) {
      if (y + offset > h * nextPressed && y + offset < h * nextPressed + h) {
        ++nextPressed;
      }
    }
  }

  public void onClick(float x, float y) {
    begin();
  }
}
/**
 
 Vellecht no en chnopf zum s'Spiel z'starte & be doppelklick is home z'cho? --> 1 pro 'screen'
 
 */

public class GamePong extends Game {

  public static final int MAX_START_SPEED = 4;

  private int topPlayerX = 0;
  private int botPlayerX = 0;

  private PVector ball = new PVector(width / 2, height / 2);
  private PVector speed = new PVector(0, 0);

  private int topPlayerScore = 0;
  private int botPlayerScore = 0;

  private int pong_width = 0;

  public GamePong() {
    super(2);
    pong_width = (int)(width / 2);
  }

  public void render() {
    fill(0xFF);
    rect(0, 0, width, height);

    fill(0x00);
    rect(topPlayerX, 20, pong_width, 20);
    rect(botPlayerX, height - 40, pong_width, 20);

    ellipse(ball.x, ball.y, 20, 20);

    textAlign(CENTER);
    text(topPlayerScore + ":" + botPlayerScore, width / 2, height / 2 - 20);
  }

  public void update() {
    if (speed.mag() == 0) speed = PVector.random2D().mult(2);
    if (speed.mag() < 2) speed = speed.normalize().mult(2); // min speed
    else speed = speed.mult(1.001f);

    ball.add(speed);

    if (ball.x < 10 || ball.x > width - 10) speed.x *= -1;

    if (ball.y - 30 < 20 || ball.y + 20 > height - 30) {
      int xPos = topPlayerX;
      if (ball.y > height / 2) xPos = botPlayerX;

      if (ball.x + 10 > xPos && ball.x - 10 < xPos + pong_width) {
        createParticles(20, ball.x, ball.y, 2 * 60, 3 * 60); // because 60 fps

        float angle = speed.heading();
        if (ball.y > height / 2) speed.rotate(PI / 3.0f * 2.0f * (ball.x - xPos - pong_width / 2) / pong_width - PI / 2 - angle);
        else speed.rotate(PI / 3.0f * 2.0f * (ball.x - xPos - pong_width / 2) / pong_width + PI / 2 - angle);
      } else if (ball.y < 10 || ball.y - 10 > height) {
        speed.set(0, 0);
        if (ball.y < height / 2) ++botPlayerScore;
        else ++topPlayerScore;
        ball.set(width / 2, height / 2);
      }
    }
  }

  public void handleUserInput(int x, int y) {
    x -= pong_width / 2;
    if (y < height / 2) {
      topPlayerX = x;
      topPlayerX = topPlayerX > width - pong_width ? width - pong_width : topPlayerX < 0 ? 0 : topPlayerX;
    } else {
      botPlayerX = x;
      botPlayerX = botPlayerX > width - pong_width ? width - pong_width : botPlayerX < 0 ? 0 : botPlayerX;
    }
  }

  public void onClick(float x, float y) {
    speed.x = random(MAX_START_SPEED * 2) - MAX_START_SPEED; 
    speed.y = random(MAX_START_SPEED * 2) - MAX_START_SPEED;
    //setScreen(new GameNinJump());
  }
}
// WebInterface @ ip:5415

private class TetrisBricks {
  private PVector location;
  private int rotation = 0;
  private PVector[] places;
  private int col;

  public void rotateRight() {
    for (int i = 0; i < places.length; i++) places[i] = new PVector(-places[i].y, places[i].x);
    rotation = (rotation + 1) % 4;
  }

  public void rotateLeft() {
    for (int i = 0; i < places.length; i++) places[i] = new PVector(places[i].y, -places[i].x);
    if (--rotation < 0) rotation += 4;
  }

  public TetrisBricks(PVector[] places, int x, int y) {
    this.places = places.clone();
    location = new PVector(x, y);
    this.col = (int) random(0xFFFFFF);
  }

  public TetrisBricks(PVector[] places, int x, int y, int col, int rotation) {
    this.places = places.clone();
    location = new PVector(x, y);
    this.col = col;
    rotation = 4 - (rotation % 4);
    while(--rotation >= 0) rotateRight();
  }

  public void render(int off) {
    fill(col | 0xFF111111);
    for (PVector p : places) {
      rect((int) (p.x + location.x) * GameTetris.RECT_SIZE, (int) (p.y + location.y) * GameTetris.RECT_SIZE - off, GameTetris.RECT_SIZE, GameTetris.RECT_SIZE);
    }
  }

  public boolean collides(TetrisBricks other) {
    PVector sub = new PVector(location.x - other.location.x, location.y - other.location.y);

    // location + local - (other.location + remote)
    // == (location - other.location) + (local - remote)

    // this - other == 0? --> if yes ---> collision

    for (PVector local : places) {
      if (local.x == -100 && local.y == -100) continue;
      for (PVector remote : other.places) {
        if (remote.x == -100 && remote.y == -100) continue;
        if (local.x - remote.x + sub.x == 0 && local.y - remote.y + sub.y == 0) return true;
      }
    }

    return false;
  }
}

public class GameTetris extends Game implements ReceiveEventHandler {

  public static final int RECT_SIZE = 40; // 540 = 2 * 2 * 3 * 3 * 5

  public final PVector[] SQUARE = new PVector[] { new PVector(0, 0), new PVector(0, 1), new PVector(1, 0), new PVector(1, 1) };
  public final PVector[] LEFT_L = new PVector[] { new PVector(0, 0), new PVector(0, 1), new PVector(0, 2), new PVector(-1, 2) };
  public final PVector[] RIGHT_L = new PVector[] { new PVector(0, 0), new PVector(0, 1), new PVector(0, 2), new PVector(1, 2) };
  public final PVector[] LINE = new PVector[] { new PVector(0, 0), new PVector(0, 1), new PVector(0, 2), new PVector(0, 3) };
  public final PVector[] T_SHAPE = new PVector[] { new PVector(0, 0), new PVector(1, 0), new PVector(2, 0), new PVector(1, 1) };
  public final PVector[] Z_SHAPE = new PVector[] { new PVector(0, 0), new PVector(1, 0), new PVector(1, 1), new PVector(2, 1) };
  public final PVector[] REVERSE_Z = new PVector[] { new PVector(0, 0), new PVector(1, 0), new PVector(1, -1), new PVector(2, -1) };

  private ArrayList<TetrisBricks> placedBricks = new ArrayList<TetrisBricks>();
  private ServerClient connected = null;
  private TetrisBricks currentBrick;
  private int timer = 0, speed = 30; // every 30 frames (timer) drop brick by one --> the lower the speed the faster it goes. Contradictory isn't it?
  private int offset;

  public GameTetris() {
    super(1);
    offset = height % RECT_SIZE;

    // 7 pieces because w = 8

    currentBrick = new TetrisBricks(LEFT_L, (int) (width / RECT_SIZE) / 2, 0, 0xFFFFFF, 2);
    // createNewBrick();
  }

  public void onReceive(ServerClient client, String data) {
    // Only called when data was received after the initial connection was established without closing the socket
    println("norm: " + data);
  }

  public boolean onConnect(ServerClient client, String data) {
    if (data.equals("connect")) {
      client.sendAnswer("/tetris/index_tetris.html");
    } else if (data.equals("right")) {
      currentBrick.rotateRight();
      for (int i = 0; i < placedBricks.size(); i++) { // ConcurrentModification Errors are shit
        TetrisBricks b = placedBricks.get(i);
        if (b != null && b.collides(currentBrick)) {
          currentBrick.rotateLeft(); // rotation was blocked
          break;
        }
      }
      for (PVector p : currentBrick.places) {
        if (p.x + currentBrick.location.x > width / RECT_SIZE) --currentBrick.location.x;
        if (p.x + currentBrick.location.x < 0) ++currentBrick.location.x;
      }
    } else if (data.equals("left")) {
      currentBrick.rotateLeft();
      for (int i = 0; i < placedBricks.size(); i++) { // ConcurrentModification Errors are shit
        TetrisBricks b = placedBricks.get(i);
        if (b != null && b.collides(currentBrick)) {
          currentBrick.rotateRight(); // rotation was blocked
          break;
        }
      }
      for (PVector p : currentBrick.places) {
        if (p.x + currentBrick.location.x >= width / RECT_SIZE) --currentBrick.location.x;
        if (p.x + currentBrick.location.x < 0) ++currentBrick.location.x;
      }
    } else if (data.equals("down")) {
      timer = speed; // moves the piece one down in the next frame
    } else if (data.equals("stop")) closeScreen();
    else if (data.equals("listener")) {
      println("Found listener. Starting game");
      handler.input.resetTimer();
      connected = client;
      return false; // dont close connection so we can send when the game closes down
    } else println(data);

    return true; // If true disconnect the socket
  }


  public void render() {
    if (connected == null) {
      fill(0);
      rect(0, 0, width, height);
      fill(0xFF);
      textAlign(CENTER, CENTER);
      text("Spiel: " + id, width / 2, height / 2);
    } else {
      fill(0);
      rect(0, 0, width, height);
      currentBrick.render(offset);

      for (TetrisBricks b : placedBricks) b.render(offset);

      stroke(0xFF);
      line(width - 1, 0, width - 1, height);
      noStroke();
    }
  }

  public ArrayList<PVector> getNeighbours(TetrisBricks brick, ArrayList<PVector> alreadyFound, PVector startingNode) {
    alreadyFound.add(startingNode);
    for (int j = 0; j < brick.places.length; j++) {
      PVector second = brick.places[j];
      if (new PVector(startingNode.x, startingNode.y).sub(second).mag() == 1.0f) { // Just one away --> not sqrt(2)
        if (!alreadyFound.contains(second)) {
          alreadyFound.addAll(getNeighbours(brick, alreadyFound, second));
        }
      }
    }
    return alreadyFound;
  }

  public ArrayList<PVector[]> getPieces(TetrisBricks brick) {
    ArrayList<PVector[]> broken = new ArrayList<PVector[]>();
    ArrayList<PVector> fo = new ArrayList<PVector>();
    ArrayList<PVector> foundPieces = new ArrayList<PVector>();

    int index = 0;
    while (index < brick.places.length && brick.places[index].x == -100 && brick.places[index].y == -100) index++;
    if (index == brick.places.length) return broken;

    while (foundPieces.size() != brick.places.length) {
      for (int i = index + 1; i < brick.places.length; i++) {
        if (brick.places[i].x == -100 && brick.places[i].y == -100) fo.add(brick.places[i]);
        if (!fo.contains(brick.places[i])) {
          index = i; 
          break;
        }
      }
      foundPieces.clear();
      foundPieces = getNeighbours(brick, foundPieces, brick.places[index]);
      broken.add(foundPieces.toArray(new PVector[foundPieces.size()]));
      fo.addAll(foundPieces);
    }
    return broken;
  }

  public void checkLines() {
    int w = width / RECT_SIZE;
    int h = height / RECT_SIZE + 4;

    println(w);
    TetrisBricks[] field = new TetrisBricks[w * h];
    for (TetrisBricks b : placedBricks) {
      for (PVector p : b.places) {
        if (p.x == - 100 && p.y == -100) continue; // Prevent out of bounds for the missing ones
        
        int index = (int) p.x + (int) b.location.x + (int) (p.y + b.location.y) * w;
        if (index < 0 || index >= field.length) continue; // Game over?
        field[index] = b;
      }
    }

    ArrayList<TetrisBricks> toMoveDown = new ArrayList<TetrisBricks>();

    for (int i = 0; i < h; i++) {
      boolean lc = true;
      for (int j = 0; j  < w; j++) {
        if (field[i * w + j] == null) lc = false;
      }

      if (lc) {
        println("Clearing line!");
        for (int j = 0; j < w; j++) {
          TetrisBricks b = field[i * w + j];
          for (int k = 0; k < b.places.length; k++) {
            if (b.places[k].x + b.location.x == j && b.places[k].y + b.location.y == i) {
              b.places[k] = new PVector(-100, -100);
              if (!toMoveDown.contains(b)) toMoveDown.add(b);
              break;
            }
          }
        }
      }
    }
    println("Moving everything down");
    // TODO create new tetrisbricks for each part that can fall down, if the piece was sperated
    for (TetrisBricks piece : toMoveDown) {
      ArrayList<PVector[]> p = getPieces(piece);
      if (p.size() > 1) {
        // Split up into two pieces
        println("Splitting up: ");
        placedBricks.remove(piece);
        for (int k = 0; k < p.size(); k++) {
          TetrisBricks b = new TetrisBricks(p.get(k), (int) piece.location.x, (int) piece.location.y, piece.col, 0);
          b = applyGravity(b);
          placedBricks.add(b);
        }
      } else if (p.size() == 1) {
        placedBricks.set(placedBricks.indexOf(piece), applyGravity(piece));
      } else {
        println("Piece removed entirely");
        placedBricks.remove(piece);
      }
    }
  }

  public TetrisBricks applyGravity(TetrisBricks bricks) {
    while (true) {
      ++bricks.location.y;

      for (PVector v : bricks.places) {
        if (bricks.location.y + v.y > (height / RECT_SIZE)) {
          --bricks.location.y;
          return bricks;
        }
      }
      // TODO check every position in the brick if a brick is below & if yes fix it & spawn a new brick --> done maybe

      for (int i = 0; i < placedBricks.size(); i++) { // ConcurrentModification Errors are shit
        TetrisBricks b = placedBricks.get(i);
        if (b != null && b != bricks && b.collides(bricks)) {
          --bricks.location.y;
          return bricks;
        }
      }
    }
  }

  public void createNewBrick() {
    --currentBrick.location.y;
    println(currentBrick.location.y);
    placedBricks.add(currentBrick);

    checkLines();

    PVector[] places = SQUARE; // default object (greater than 6)
    switch((int) random(7)) {
    case 0:
      places = LINE;
      break;
    case 1:
      places = LEFT_L;
      break;
    case 2:
      places = RIGHT_L;
      break;
    case 3:
      places = T_SHAPE;
      break;
    case 4:
      places = Z_SHAPE;
      break;
    case 5:
      places = REVERSE_Z;
      break;
    }
    currentBrick = new TetrisBricks(places, (int) random(width / RECT_SIZE) * RECT_SIZE, 0);
  }

  public void onClose() {
    println("Closing");
    if (connected == null) return;
    connected.sendAnswer("close");
    connected.close();
  }

  public void update() {
    if (connected != null) {
      if (++timer >= speed) {
        timer = 0;
        currentBrick.location.y++;

        for (PVector v : currentBrick.places) {
          if (currentBrick.location.y + v.y > (height / RECT_SIZE)) {
            createNewBrick();
            break;
          }
        }
        // TODO check every position in the brick if a brick is below & if yes fix it & spawn a new brick --> done maybe

        for (int i = 0; i < placedBricks.size(); i++) { // ConcurrentModification Errors are shit
          TetrisBricks b = placedBricks.get(i);
          if (b != null && b.collides(currentBrick)) {
            createNewBrick();
            break;
          }
        }
      }
    }
  }

  public void handleUserInput(int x, int y) {
    int mod = currentBrick.location.x < x / RECT_SIZE ? 1 : (currentBrick.location.x > x / RECT_SIZE ? -1 : 0);

    if (mod != 0) {
    cd: 
      while (currentBrick.location.x != x / RECT_SIZE) {
        for (int i = 0; i < placedBricks.size(); i++) { // ConcurrentModification Errors are shit
          TetrisBricks b = placedBricks.get(i);
          if (b == null) continue;
          b.location.x-=mod;
          if (b.collides(currentBrick)) {
            // createNewBrick();
            // TODO colliding code
            b.location.x+=mod;
            break cd;
          }
          b.location.x+=mod;
        }
        // no collision --> move
        currentBrick.location.add(mod, 0);
      }
    }

    // currentBrick.location.x = x / RECT_SIZE;
    for (PVector p : currentBrick.places) {
      if (p.x + currentBrick.location.x >= width / RECT_SIZE) --currentBrick.location.x;
      if (p.x + currentBrick.location.x < 0) ++currentBrick.location.x;
    }
  }

  public void onClick(float x, float y) {
    connected =  new ServerClient(null, null); // start game with console in/output
  }
}
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
      buttons.add(new MenuButton(0, (int)((i + (float) size / 2.0f) * height / (size * 2)), width, height / (size * 2), name, screenClass, this));
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

  public void onClick(float x, float y) {
    // setScreen(y < height / 2 ? new GamePianoTiles() : new GamePong());
    // setScreen(new GamePianoTiles(height / width));
    for (MenuButton button : buttons) button.onClick(x, y);
  }
}


/**
 A button for the HomeScreen
 */
public class MenuButton {

  public static final int BUTTON_COLOR = 0xFF00A000; // Color when the button is in its normal state
  public static final int BUTTON_BORDER = 0xFF006000;
  public static final int HOVER_COLOR = 0xFF4444FF; // Color when the mouse is over this button
  public static final int TEXT_COLOR = 0xFFFFFFFF; // The color of the text

  public static final float STAY_OVER_TIME = 60 * 5.0f;

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
/**
 Creates a handful of particles to fly around
 */
public class ParticleGenerator {
  public static final int PARTICLE_WIDTH = 4; // Width of a particle
  public static final int PARTICLE_HEIGHT = 2; // Height of a particle

  /**
   One particle
   */
  private class Particle {

    public PVector position, direction; // Position & direction of the particles stored in 2D vectors
    public float rotation; // Direction of the Particle (0 - 2*PI)
    public int timeout; // The time until the particle will disappear

    public Particle(float x, float y, int minTime, int maxTime) { // Creates a new 
      position = new PVector(x, y); // The current position of the particle
      direction = PVector.random2D().mult(random(1)); // Unit vector * a random number between 0 & 1
      rotation = random(2 * PI);
      timeout = (int) random(maxTime - minTime) + minTime; // Create a random time between min & max for this particle
    }
  }

  private ArrayList<Particle> particles = new ArrayList<Particle>(); // All the particles this generator contains

  /**Create particles around a point
   */
  public ParticleGenerator(int amount, float x, float y, int minTime, int maxTime) {
    while (amount-- > 0) particles.add(new Particle(x, y, minTime, maxTime)); // Create amount times a new particle
  }

  public boolean render() { // Render all the particles
    fill(0);
    for (int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      if (p == null) continue;
      p.position.add(p.direction); // Vector addition x += px, y += py
      pushMatrix(); // Save the current postition & rotation
      translate(p.position.x + PARTICLE_WIDTH / 2, p.position.y + PARTICLE_HEIGHT / 2); // Move position of 0|0 to the center of the particle
      rotate(p.rotation); // Rotate with the rotation from the particle around (new) 0|0

      rect(0, 0, PARTICLE_WIDTH, PARTICLE_HEIGHT); // Draw the particle

      // translate(-p.position.x - PARTICLE_WIDTH / 2, -p.position.y - PARTICLE_HEIGHT / 2); // Move position back to where it was --> popMatrix does the same

      popMatrix(); // Restore the position & rotation from previously
      if (--p.timeout <= 0) particles.remove(p); // Reduce the time by one & remove the particle if less than 0
    }
    return particles.isEmpty(); // returns true when the particles have all disappeared
  }
}
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
public class ScreenCredits extends Screen {

  /**
   Das isch de besti Screen im ganze Programm inne
   */

  String text = 
    "Created by:\n" +
    "Me, myself & I\n" +
    "\n" +
    "F\u00fcr KantiBeiz\n" +
    "@ BadenerFahrt 2017\n" +
    "\n" + 
    "\u00a92017\n" +
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




// Wieso schrieb ich das ganze zeugs und benutze ned eifach en library? Ich weiss es N\u00f6d!

public interface ReceiveEventHandler {
  public boolean onConnect(ServerClient client, String initialData); // return true to close the socket
  public void onReceive(ServerClient client, String data);
}

/**
 A single client
 */
public class ServerClient extends Thread {

  private Socket socket;
  private BufferedReader reader;
  private PrintWriter writer;
  private WebProcess parent;

  public ServerClient(WebProcess p, Socket s) {
    socket = s;
    parent = p;
    try {
      if (s != null) reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
      else reader = new BufferedReader(new InputStreamReader(System.in));
      if (s!= null) writer = new PrintWriter(s.getOutputStream(), true);
      else writer = new PrintWriter(System.out, true);
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
    start();
  }

  public void clearInBuffer() {
    try {
      while (reader.ready()) reader.readLine();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
  }

  public String readNextLine() {
    try {
      return reader.readLine() + "\r\n";
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
    return null;
  }

  public byte[] readData(int length) {
    byte[] db = new byte[length];
    int i = 0;
    try {

      while (i++ > 0) {
        db[i] = (byte) reader.read();
      }
    }
    catch(IOException e) {
      e.printStackTrace();
    }
    return db;
  }

  public void send(String s) {
    writer.write(s);
  }

  public void send(byte[] data) {
    writer.write(new String(data));
  }

  public void sendLine(String s) {
    send(s + "\r\n");
  }

  public void sendLine(byte[] s) {
    send(new String(s) + "\r\n");
  }

  public void sendAnswer(String data) {
    sendLine("HTTP/1.0 200 OK");
    sendLine("Content-Type: text/plain");
    sendLine("");
    sendLine(data);
  }

  public void close() {
    try {
      interrupt(); // Interrupt the reader to read --> join would hang, because reader blocks

      writer.close();
      reader.close();
      socket.close();
      parent.clients.remove(this);
    } 
    catch(Exception e) {
    }
  }

  public void run() {
    try {
      while (true) {
        parent.onReceive(this, reader.readLine() + "\r\n");
      }
    } 
    catch(IOException e) {
    }
  }
}

public class WebProcess extends Thread {

  public static final int PORT = 5415;

  private ServerSocket server;
  private ArrayList<ServerClient> clients = new ArrayList<ServerClient>();
  private String defaultIndex;
  private ReceiveEventHandler receiveHandler;

  public WebProcess(String defaultIndex, ReceiveEventHandler evtHandler) {
    this.defaultIndex = defaultIndex;
    receiveHandler = evtHandler;
    start(); // Autostart
  }

  public void run() {
    try {
      server = new ServerSocket(PORT);

      while (true) {
        clients.add(new ServerClient(this, server.accept()));
      }
    } 
    catch(IOException e) {
      e.printStackTrace();
      println(e);
    }
  }

  public void onReceive(ServerClient s, String message) {
    //TODO do something when we receive something...
    if (message.startsWith("GET")) { // Handle web-requests
      String path = message.substring(4).split(" ")[0];

      if (path.contains("?")) path = path.split("\\?")[0];

      if (path.equalsIgnoreCase("/")) path = defaultIndex;
      else if (path.startsWith("/")) path = path.substring(1);

      path = "web/" + path;

      println("GET --> " + path);

      String[] lines = loadStrings(path); // Load file at that path

      if (lines == null) {
        s.sendLine("HTTP/1.1 404 NOT_FOUND");
        s.close();
        return;
      }

      s.sendLine("HTTP/1.0 200 OK");
      s.sendLine("Content-Type: text/html");
      s.sendLine("\r\n");
      // s.sendLine("<html><button>Click me</button></html>");
      for (String data : lines) {
        s.sendLine(data);
      }

      s.close();
    } else if (message.startsWith("POST")) {
      // print(message);
      int length = 0;
      String l = s.readNextLine();
      while (!l.replace("\r", "").replace("\n", "").equals("")) {
        if (l.startsWith("Content-Length: ")) length = Integer.parseInt(l.substring(16).replace("\r\n", ""));
        l = s.readNextLine();
      }

      String data = s.readNextLine();
      while (data.length() < length) data += s.readNextLine();

      if (receiveHandler.onConnect(s, data.substring(0, data.length() - 2))) s.close();
    } else receiveHandler.onReceive(s, message);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GameTable" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

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
  private float aspectRatio = 0.0;

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
      text("Verlorä", 100, 100);
      text("Pünkt: " + speed, 80, 120);
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
      fill(i < nextPressed ? 0xFF00009F : 0xFF0000FF);
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

    if (running) speed += (1.0 / 60.0) / 5.0;
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
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
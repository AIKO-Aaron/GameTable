public class GameFruitNinja extends Game {

  public static final int MAX_POSITIONS = 10;
  public static final int BLADE_GROESSE = 2;
  public static final int BLADE_COLOR = 0xFF5050FF;
  public static final float FRUITE_FREQ = 5;
  public static final int FRUITE_MAXAMOUNT = 5;

  private ArrayList<PVector> lastPositions = new ArrayList<PVector>();
  private PImage bg;
  private PImage laebeimg;
  private PImage fruit_apple;
  private PImage fruit_Melon;
  private ArrayList<PVector> Fruits = new ArrayList<PVector>();
  private ArrayList<PVector> FruitsPos = new ArrayList<PVector>();
  private ArrayList<PVector> FruitTimes = new ArrayList<PVector>();
  private int timer = 0;
  private int counter = 0;
  private PVector gravity = new PVector(0, 0.5);
  private int Fruit_Radius1 = 40;
  private int Fruit_Radius2 = 60;
  private float random = random(0.5, 1);
  private int laebe = 3;
  private int score = 1;


  public GameFruitNinja() {
    super(1);
    laebeimg = loadImage("textures/FruitNinja/fruitNinja_Live.png");
    bg = loadImage("textures/FruitNinja/fruitNinja_bg.jpg");
    fruit_apple = loadImage("textures/FruitNinja/fruitNinja_apple.png");
    fruit_Melon = loadImage("textures/FruitNinja/fruitNinja_melon.png");
  }


  public void render() {
    image(bg, 0, 0, width, height);
    fill(0);
    textSize(32);
    textOutlined(60, 30, "Läbe:");
    textOutlined(width - 80, 30, "Score: " + (score - 1));
    textSize(12);
    //anzeige Leben
    imageMode(CENTER);
    for (int i = 0; 3 - i > laebe; i++) {
      image(laebeimg, 120 + i * 40, 30, 30, 30);
    }
    imageMode(CORNER);
   // Blade_render();
    Fruit_render();
  }

  public void update() {
    timer++;
    if (timer > 30 && lastPositions.size() > 0) lastPositions.remove(0); // Outofbounds!


    if (frameRate * FRUITE_FREQ * random / (1+(score/5)) > counter) {
      counter++;
      random = random(0.5, 1);
    } else {
      if (Fruits.size() < FRUITE_MAXAMOUNT) {
        //FruitsPos(x pos, y pos, type)
        FruitsPos.add(new PVector(0, random(height/2, height), int(random(0, 2))));
        //Fruits(X vector, Y vector);
        Fruits.add(new PVector(7 * random(0.75, 1), -1 * random(12, 15)));
        FruitTimes.add(new PVector(0, Fruits.get(Fruits.size() - 1).mag()));
        counter = 0;
      }
    }

    for (int f = 0; f < Fruits.size(); f++) {
      float fPosx = FruitsPos.get(f).x;
      float fPosy = FruitsPos.get(f).y;
      float Posx = mouseX;
      float Posy = mouseY;
      int Fruit_Radius = 0;
      //add Vector to pos
      (FruitsPos.get(f)).add(Fruits.get(f));

      //Modify Vector, gravity
      Fruits.get(f).add(gravity);
      FruitTimes.get(f).x++;

      switch (int(FruitsPos.get(f).z)) {
      case 0:
        Fruit_Radius = Fruit_Radius1;
        break;
      case 1:
        Fruit_Radius = Fruit_Radius2;
        break;
      }
      //Aaron frage , Check if hit
      if (abs(fPosx - Posx) < Fruit_Radius / 2 && abs(fPosy - Posy) < Fruit_Radius / 2) {
        createParticles(10, fPosx, fPosy, 30, 60, 0xFFFF0000, 10, 5);
        score++;
        Fruits.remove(f);
        FruitsPos.remove(f);
        FruitTimes.remove(f);
      }

      //remove Fruits out of bound
      else if  (FruitsPos.get(f).y > height) {
        Fruits.remove(f);
        FruitsPos.remove(f);
        FruitTimes.remove(f);
        laebe--;
      }
    }
    if (laebe == 0) {
      closeScreen();
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
    imageMode(CENTER);
    for (int f = 0; f < Fruits.size(); f++) {
      pushMatrix();
      translate(FruitsPos.get(f).x, FruitsPos.get(f).y);
      rotate(FruitTimes.get(f).x * FruitTimes.get(f).y / 100);
      switch (int(FruitsPos.get(f).z)) {
      case 0:
        image(fruit_apple, 0, 0, Fruit_Radius1 * 2, Fruit_Radius1 * 2);
        break;
      case 1:
        image(fruit_Melon, 0, 0, Fruit_Radius2 * 1.5, Fruit_Radius2 * 2);
        break;
      }
      popMatrix();
    }
    imageMode(CORNER);
  }
  public void textOutlined(int x, int y, String text) {
    textAlign(CENTER, CENTER);
    fill(122);
    pushMatrix();
    translate(x, y);
    for (int i = -1; i < 2; i++) {
      text(text, i, 0);
      text(text, 0, i);
    }
    fill(0);
    text(text, 0, 0);
    popMatrix();
  }
}
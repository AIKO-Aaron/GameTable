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
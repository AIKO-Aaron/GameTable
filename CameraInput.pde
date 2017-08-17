import java.util.Comparator;

public class CameraInput {
  private ArrayList<PVector> lastTrackedHands = new ArrayList<PVector>();
  private long noHandsThere = 0;

  public static final int NOT_PRESSED = 0;
  public static final int PRESSED = 1;
  public static final int PULLED = 2;

  public static final int MAX_MOTION = 4;
  public static final int MIN_PIXELS_FOR_HAND = 5;

  public CameraReader reader = new CameraReader();

  // Punkte am nächsten in der Mitte = Hände? --> Für Mehrspieler 2, für Einzelspieler die Punkte am weitesten oben (Mehrere, falls messfehler auftreten...)

  public void update() {
    reader.update();

    /**if (clicking.size() < 1) clicking.add(mousePressed ? PRESSED : NOT_PRESSED);*/

    lastTrackedHands.clear();

    if (!CameraReader.USE_CAMERA && lastTrackedHands.size() < 1) lastTrackedHands.add(new PVector(mouseX, mouseY, 0));

    for (int i = 0; i < reader.hands.size(); i++) {
      CameraReader.Hand h = reader.hands.get(i);
      if (h == null || h.count < 30) continue;

      lastTrackedHands.add(new PVector(h.x, h.y, 0));
    }


    if (noHandsThere != 0 && System.nanoTime() - noHandsThere >= 10 * 1000000000) handler.removeScreen(0);

    if (lastTrackedHands.size() == 0 && noHandsThere == 0) {
      noHandsThere = System.nanoTime();
      return;
    } else for (int i = 0; i < lastTrackedHands.size(); i++) {
      fill(0xFF00FFFF);
      rect(lastTrackedHands.get(i).x - 2, lastTrackedHands.get(i).y - 2, 5, 5);
    }

    noHandsThere = 0;

    lastTrackedHands.sort(new Comparator<PVector>() {
      public int compare(PVector p1, PVector p2) {
        return p1.y < p2.y ? -1 : p1.y == p2.y ? 0: 1;
      }
    }
    );
  }

  public void resetTimer() {
    for (int i = 0; i < lastTrackedHands.size(); i++) lastTrackedHands.set(i, new PVector(lastTrackedHands.get(i).x, lastTrackedHands.get(i).y, 0));
  }

  public void updateGame(Game g, int i) {
    if (g != null) {
      if (handler.getPlayerCount() != 2 || lastTrackedHands.size() < 2) {
        for (int j = 0; j < lastTrackedHands.size() && j < 3; j++) {
          PVector hand = lastTrackedHands.get(j);
          if (hand != null && hand.x > i * width && hand.x < (i + 1) * width) {
            g.handleUserInput((int) hand.x - i * width, (int) hand.y);
          }
        }
      } else {
        int mid = height / 2;
        int y1 = 0, ydif1 = height + 1, y2 = 0, ydif2 = height + 1;
        for (int j = 0; j<  lastTrackedHands.size(); j++) {
          PVector hand = lastTrackedHands.get(j);
          if (ydif1 > abs(hand.y - mid)) {
            ydif1 = (int) abs(hand.y - mid);
            y1 = j;
          } else if (ydif2 > abs(hand.y - mid)) {
            ydif2 = (int) abs(hand.y - mid);
            y2 = j;
          }
        }
        g.handleUserInput((int) lastTrackedHands.get(y1).x - i * width, (int) lastTrackedHands.get(y1).y);
        g.handleUserInput((int) lastTrackedHands.get(y2).x - i * width, (int) lastTrackedHands.get(y2).y);
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

  public void render() {
    reader.render();
    for (int i = 0; i < lastTrackedHands.size() && i < 2; i++) {
      fill(0xFF00FFFF);
      rect(lastTrackedHands.get(i).x - 2, lastTrackedHands.get(i).y - 2, 5, 5);
    }
  }

  public void updateScreen(Screen s, int i) {
    if (s instanceof Game) {
      updateGame((Game) s, i);
    }
  }
}
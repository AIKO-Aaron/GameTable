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
      if (new PVector(startingNode.x, startingNode.y).sub(second).mag() == 1.0) { // Just one away --> not sqrt(2)
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
// WebInterface @ ip:5415
public class GameTetris extends Game implements ReceiveEventHandler {

  private ServerClient connected = null;
  private int timer = 0, speed = 30; // every 30 frames (timer) drop brick by one --> the lower the speed the faster it goes. Contradictory isn't it?

  public static final int FIELD_WIDTH = 7;
  public static final int FIELD_HEIGHT = 14;

  public int[][] SHAPES = new int[][] {
    { 
      0 * FIELD_WIDTH + 0, 1 * FIELD_WIDTH + 0, 1 * FIELD_WIDTH + 1, 0 * FIELD_WIDTH + 1
    }, 
    {
      0 * FIELD_WIDTH + 0, 1 * FIELD_WIDTH + 0, 2 * FIELD_WIDTH + 0, 2 * FIELD_WIDTH + 1
    }, 
    {
      0 * FIELD_WIDTH + 1, 1 * FIELD_WIDTH + 1, 2 * FIELD_WIDTH + 1, 2 * FIELD_WIDTH + 0
    }, 
    {
      1 * FIELD_WIDTH + 0, 1 * FIELD_WIDTH + 1, 1 * FIELD_WIDTH + 2, 2 * FIELD_WIDTH + 1
    }, 
    {
      0 * FIELD_WIDTH + 0, 1 * FIELD_WIDTH + 0, 2 * FIELD_WIDTH + 0, 3 * FIELD_WIDTH + 0
    }, 
    {
      0 * FIELD_WIDTH + 0, 0 * FIELD_WIDTH + 1, 1 * FIELD_WIDTH + 1, 1 * FIELD_WIDTH + 2
    }, 
    {
      1 * FIELD_WIDTH + 0, 0 * FIELD_WIDTH + 1, 1 * FIELD_WIDTH + 1, 0 * FIELD_WIDTH + 2
    }
  };

  public static final int SHAPE_RECTANGLE = 0;
  public static final int SHAPE_L = 1;
  public static final int SHAPE_REV_L = 2;
  public static final int SHAPE_T = 3;
  public static final int SHAPE_LINE = 4;
  public static final int SHAPE_Z = 5;
  public static final int SHAPE_REV_Z = 6;

  public static final int NO_BLOCK = -1;

  public int[] blockIDs = new int[FIELD_WIDTH * FIELD_HEIGHT];
  public HashMap<Integer, Integer[]> blockIndexes = new HashMap<Integer, Integer[]>();
  public ArrayList<Integer> blockColors = new ArrayList<Integer>();
  private int currentID = NO_BLOCK; // First block must have id 0

  public GameTetris() {
    stroke(0xFF);

    for (int i = 0; i < blockIDs.length; i++) {
      blockIDs[i] = NO_BLOCK; // No block present
    }

    //addBlock(SHAPE_L, 0, 11);
    //addBlock(SHAPE_L, 2, 11);

    addBlock(SHAPE_LINE, 0, 0);
  }

  // returns how many times the block could be moved down
  public int applyGravity(int blockID) {
    int maxAmount = FIELD_HEIGHT;
    Integer[] indexes = blockIndexes.get(blockID);
    if (indexes == null) return 0;

    for (int index = 0; index < indexes.length; index++) {
      int i = indexes[index];
      if (i < 0) continue;
      int amount = 0;
      for (; i + amount * FIELD_WIDTH < blockIDs.length; amount++) {
        int idToPlaceAt = blockIDs[i + amount * FIELD_WIDTH];
        if (idToPlaceAt != blockID && idToPlaceAt != NO_BLOCK) break;
      }
      maxAmount = min(amount - 1, maxAmount);
    }

    for (int i = 0; i < indexes.length; i++) if (indexes[i] >= 0) blockIDs[indexes[i]] = NO_BLOCK;
    for (int index = 0; index < indexes.length; index++) {
      int i = indexes[index];

      if (i < 0) continue;


      i += maxAmount * FIELD_WIDTH; // new index
      indexes[index] = i; // arrays passed via pointer --> modify this array = modifying original

      if (i >= 0 && i < FIELD_WIDTH * FIELD_HEIGHT) blockIDs[i] = blockID;
    }

    return maxAmount;
  }

  public boolean moveDown() {
    boolean canMoveDown = true;
    Integer[] indexes = blockIndexes.get(currentID);
    if (indexes == null) return false;
    for (int index = 0; index < indexes.length; index++) {
      int i = indexes[index];
      int amount = 0;
      for (; i + amount * FIELD_WIDTH < blockIDs.length; amount++) {
        if (blockIDs[i + amount * FIELD_WIDTH] != currentID && blockIDs[i + amount * FIELD_WIDTH] != NO_BLOCK) break;
      }
      canMoveDown &= amount >= 2;
    }

    if (canMoveDown) {
      for (int i = 0; i < indexes.length; i++) blockIDs[indexes[i]] = NO_BLOCK;
      for (int index = 0; index < indexes.length; index++) {
        indexes[index] += FIELD_WIDTH; // arrays passed via pointer --> modify this array = modifying original
        blockIDs[indexes[index]] = currentID;
      }
    }

    return canMoveDown;
  }

  public void addBlock(int shape, int xOff, int yOff) {
    int id = ++currentID;
    int[] shapeIndicies = SHAPES[shape];
    Integer[] indexes = new Integer[shapeIndicies.length];
    for (int i = 0; i < shapeIndicies.length; i++) {
      int index =  xOff + yOff * FIELD_WIDTH + shapeIndicies[i];
      indexes[i] = index;
      blockIDs[index] = id;
    }
    blockColors.add(id, int(random(0xEEEEEE)) | 0xFF111111);
    blockIndexes.put(id, indexes);
  }

  public void rotateBlock(int blockID, boolean left) {
    Integer[] indexes = blockIndexes.get(blockID);

    // Point to rotate around: position of first block

    int rotationIndex = indexes[0];
    int rx = rotationIndex % FIELD_WIDTH;
    int ry = rotationIndex / FIELD_WIDTH;

    Integer[] newIndexes = new Integer[indexes.length];

    for (int i = 0; i < indexes.length; i++) {
      int pos = indexes[i];
      int ox = pos % FIELD_WIDTH;
      int oy = pos / FIELD_WIDTH;
      int nx = 0;
      int ny = 0;

      if (left) {
        nx = oy - ry + rx;
        ny = rx - ox + ry;
      } else {
        nx = ry - oy + rx;
        ny = ox - rx + ry;
      }

      if (nx < 0 || ny < 0 || nx >= FIELD_WIDTH || ny >= FIELD_HEIGHT || (blockIDs[nx + ny * FIELD_WIDTH] != NO_BLOCK && blockIDs[nx + ny * FIELD_WIDTH] != blockID)) return;
      newIndexes[i] = nx + ny * FIELD_WIDTH;
    }

    for (int i = 0; i<  indexes.length; i++) blockIDs[indexes[i]] = NO_BLOCK;
    for (int i = 0; i < indexes.length; i++) {
      indexes[i] = newIndexes[i];
      blockIDs[indexes[i]] = blockID;
    }
  }

  public void setXPosition(int x) {
    Integer[] indexes = blockIndexes.get(currentID);
    if (indexes == null) return;
    int amount = x - (indexes[0] % FIELD_WIDTH);

    boolean trying = true;
    while (trying) {
      boolean couldMove = true;

      for (int index = 0; index < indexes.length; index++) {
        int ox = indexes[index] % FIELD_WIDTH;
        int nx = ox + amount;
        if (nx < 0 || nx >= FIELD_WIDTH || (blockIDs[indexes[index] + amount] != NO_BLOCK && blockIDs[indexes[index] + amount] != currentID)) { // TODO or collision
          couldMove = false;
          break;
        }
      }

      if (couldMove || amount == 0) {
        trying = false;
      } else {
        amount += (amount > 0 ? -1 : 1);
      }
    }

    if (amount != 0) {
      for (int i = 0; i < indexes.length; i++) blockIDs[indexes[i]] = NO_BLOCK;
      for (int index = 0; index < indexes.length; index++) {
        int i = indexes[index] + amount;
        indexes[index] = i; // arrays passed via pointer --> modify this array = modifying original
        blockIDs[i] = currentID;
      }
    }
  }

  public void render() {
    if (connected == null) {
      fill(0);
      rect(0, 0, width, height);
      fill(0xFF);
      textAlign(CENTER, CENTER);
      text("Spiel: " + id, width / 2, height / 2);
    } else {
      int w = width / FIELD_WIDTH;
      int h = height / FIELD_HEIGHT;

      fill(0xFF);
      rect(FIELD_WIDTH * w, 0, width - 1, height);
      
      noStroke();

      int yOffset = height - FIELD_HEIGHT * h;

      // setXPosition(mouseX * FIELD_WIDTH / width);

  
      stroke(0xAA);
      for (int xx = 0; xx < FIELD_WIDTH; xx++) {
        for (int yy = 0; yy < FIELD_HEIGHT; yy++) {
          int index = blockIDs[xx + yy * FIELD_WIDTH];
          fill(index == -1 || blockColors.size() <= index ? 0xFF000000 : blockColors.get(index));
          rect(xx * w, yy * h + (yy != 0 ? yOffset : 0), w, h + (yy != 0 ? 0 : yOffset));
        }
      }
    }
  }

  public void update() {
    if (connected == null) return;
    ++timer;

    if (timer >= 30) {
      timer = 0;
      if (!moveDown()) {
        boolean couldDeleteLine = true; // needed because falling blocks can build new lines
        while (couldDeleteLine) {
          couldDeleteLine = false;
          // TODO clear lines
          for (int i = 0; i < FIELD_HEIGHT; i++) {
            boolean clearLine = true;
            for (int j = 0; j < FIELD_WIDTH; j++) {
              if (blockIDs[i * FIELD_WIDTH + j] == NO_BLOCK) {
                clearLine = false;
                break;
              }
            }

            if (clearLine) {
              couldDeleteLine = true;

              println("Clearing line...");
              for (int j = 0; j < FIELD_WIDTH; j++) {
                int id = blockIDs[i * FIELD_WIDTH + j];
                if (id == NO_BLOCK) continue; // already removed
                Integer[] indexes = blockIndexes.get(id);

                for (int l = 0; l < indexes.length; l++) {
                  if (indexes[l] / FIELD_WIDTH == i) {
                    blockIDs[indexes[l]] = NO_BLOCK;
                    indexes[l] = -100000; // Away from everything, TODO fix outofboundexcpetions
                  }
                }
              }
            }
          }

          for (int i = blockIDs.length  - 1; i >= 0; i--) {
            int id = blockIDs[i];
            applyGravity(id);
          }
        }

        addBlock(int(random(7)), 0, 0);
      }
    }
  }

  public void onReceive(ServerClient client, String data) {
    // Only called when data was received after the initial connection was established without closing the socket
    println("norm: " + data);
  }

  public boolean onConnect(ServerClient client, String data) {
    if (data.equals("connect")) {
      client.sendAnswer("/tetris/index_tetris.html");
    } else if (data.equals("right")) {
      rotateBlock(currentID, false);
    } else if (data.equals("left")) {
      rotateBlock(currentID, false);
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

  public void onClose() {
    println("Closing");
    if (connected == null) return;
    connected.sendAnswer("close");
    connected.close();
  }

  public void handleUserInput(int x, int y) {
    setXPosition(x * FIELD_WIDTH / width);
  }

  public void onClick(float x, float y) {
    connected =  new ServerClient(null, null); // start game with console in/output
  }
}
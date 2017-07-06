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
    else speed = speed.mult(1.001);

    ball.add(speed);

    if (ball.x < 10 || ball.x > width - 10) speed.x *= -1;

    if (ball.y - 30 < 20 || ball.y + 20 > height - 30) {
      int xPos = topPlayerX;
      if (ball.y > height / 2) xPos = botPlayerX;

      if (ball.x + 10 > xPos && ball.x - 10 < xPos + pong_width) {
        createParticles(20, ball.x, ball.y, 2 * 60, 3 * 60, 0xFF000000, 4, 2); // because 60 fps

        float angle = speed.heading();
        if (ball.y > height / 2) speed.rotate(PI / 3.0 * 2.0 * (ball.x - xPos - pong_width / 2) / pong_width - PI / 2 - angle);
        else speed.rotate(PI / 3.0 * 2.0 * (ball.x - xPos - pong_width / 2) / pong_width + PI / 2 - angle);
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
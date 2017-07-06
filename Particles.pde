/**
 Creates a handful of particles to fly around
 */
public class ParticleGenerator {
  
  /**
   One particle
   */
  private class Particle {

    public PVector position, direction; // Position & direction of the particles stored in 2D vectors
    public float rotation; // Direction of the Particle (0 - 2*PI)
    public int timeout; // The time until the particle will disappear
    public int col;
    public int particleWidth;
    public int particleHeight;

    public Particle(float x, float y, int minTime, int maxTime, int col, int particleWidth, int particleHeight) { // Creates a new 
      this.col = col;
      this.particleWidth = particleWidth;
      this.particleHeight = particleHeight;
      position = new PVector(x, y); // The current position of the particle
      direction = PVector.random2D().mult(random(1)); // Unit vector * a random number between 0 & 1
      rotation = random(2 * PI);
      timeout = (int) random(maxTime - minTime) + minTime; // Create a random time between min & max for this particle
    }
  }

  private ArrayList<Particle> particles = new ArrayList<Particle>(); // All the particles this generator contains

  /**Create particles around a point
   */
  public ParticleGenerator(int amount, float x, float y, int minTime, int maxTime, int col, int particleWidth, int particleHeight) {
    while (amount-- > 0) particles.add(new Particle(x, y, minTime, maxTime, col, particleWidth, particleHeight)); // Create amount times a new particle
  }

  public boolean render() { // Render all the particles
    for (int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      if (p == null) continue;
      fill(p.col);
      p.position.add(p.direction); // Vector addition x += px, y += py
      pushMatrix(); // Save the current postition & rotation
      translate(p.position.x + p.particleWidth / 2, p.position.y + p.particleHeight / 2); // Move position of 0|0 to the center of the particle
      rotate(p.rotation); // Rotate with the rotation from the particle around (new) 0|0

      rect(0, 0, p.particleWidth, p.particleHeight); // Draw the particle

      // translate(-p.position.x - particleWidth / 2, -p.position.y - particleHeight / 2); // Move position back to where it was --> popMatrix does the same

      popMatrix(); // Restore the position & rotation from previously
      if (--p.timeout <= 0) particles.remove(p); // Reduce the time by one & remove the particle if less than 0
    }
    return particles.isEmpty(); // returns true when the particles have all disappeared
  }
}
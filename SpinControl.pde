final int MAX_TOPSPIN = 10;
final int MAX_SIDESPIN = 15;

class SpinControl
{
  PVector position;
  float radius;
  
  PVector spin;
  
  PShape shape;
  
  SpinControl(float x, float y, float radius)
  {
    this.position = new PVector(x, y);
    this.radius = radius;
    this.spin = new PVector(0, 0);
    
    this.createSphere();
  }
  
  void createSphere()
  { 
    int tsize = BALL_DETAIL;
    PGraphics texture = createGraphics(tsize * 2, tsize, P2D);
    texture.beginDraw();
    texture.background(255);
    for (int i = 0; i < tsize * 2; i++)
    {
      for (int j = 0; j < tsize; j++)
      {
        float n = noise(i / 10.0, j / 10.0);
        texture.stroke(0, n * 64);
        texture.point(i, j);
        float n2 = noise(tsize * 2 - i / 10.0, tsize - j / 10.0);
        texture.stroke(255, n2 * 64);
        texture.point(i, j);
      }
    }
    texture.endDraw();
    
    sphereDetail(BALL_DETAIL / 4);
    specular(255, 255, 255);
    this.shape = createShape(SPHERE, this.radius);
    this.shape.setStroke(false);
    this.shape.setShininess(50);
    this.shape.rotateY(PI);
    this.shape.setTexture(texture);
  }
  
  boolean mousePressed()
  {
    if (dist(mouseX, mouseY, this.position.x, this.position.y) < this.radius)
    {
      float dx = mouseX - this.position.x;
      float dy = mouseY - this.position.y;
      
      this.spin = new PVector(dx / this.radius, dy / this.radius);
      this.spin = new PVector(dx / this.radius, 0);
      return true;
    }
    
    return false;
  }
  
  float getSideSpin()
  {
    return this.spin.x * MAX_SIDESPIN;
  }
  
  float getTopSpin()
  {
    return this.spin.y * -MAX_TOPSPIN;
  }
  
  void draw()
  {
    pushMatrix();
    translate(this.position.x, this.position.y);
    ellipseMode(CENTER);
    fill(0);
    noStroke();
    ellipse(0, 0, this.radius * 2 + 4, this.radius * 2 + 4);
    shape(this.shape);
    translate(this.spin.x * this.radius, this.spin.y * this.radius, 100);
    noFill();
    stroke(255, 0, 0);
    strokeWeight(2);
    ellipse(0, 0, this.radius / 4, this.radius / 4);
    popMatrix();
  }
}

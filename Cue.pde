final int CUE_WIDTH = 8;
final int CUE_LENGTH = 780;

class Cue
{
  PVector mouse;
  Ball cueBall;
  
  SpinControl spinControl;
  
  Cue(Ball cueBall, SpinControl spinControl)
  {
    this.mouse = new PVector(0, 0);
    this.cueBall = cueBall;
    this.spinControl = spinControl;
  }
  
  void shoot(float force)
  {
    if (cueBall.isMoving())
    {
      return;
    }
    
    cueBall.applyForce(this.getAngle(), force);
    cueBall.addSpin(this.spinControl.getSideSpin(), this.spinControl.getTopSpin());
  }
  
  float getAngle()
  {
    return PI + atan2(
      this.cueBall.position.y - this.mouse.y,
      this.cueBall.position.x - this.mouse.x
    );
  }
  
  void update()
  { 
    this.mouse.x = mouseX;
    this.mouse.y = mouseY;
  }
  
  void drawShadow()
  {
    float angle = atan2(
      this.mouse.y - this.cueBall.position.y,
      this.mouse.x - this.cueBall.position.x
    );
    
    pushMatrix();
    fill(0, S_OPACITY);
    noStroke();
    translate(this.cueBall.position.x + S_OFF.x, this.cueBall.position.y + S_OFF.y);
    rotate(angle + HALF_PI);
    translate(-CUE_WIDTH / 2, BALL_SIZE);
    rect(0, 0, CUE_WIDTH, CUE_LENGTH);
    popMatrix();
  }
  
  void draw()
  { 
    float angle = atan2(
      this.mouse.y - this.cueBall.position.y,
      this.mouse.x - this.cueBall.position.x
    );
    
    pushMatrix();
    fill(#A05300);
    stroke(0);
    strokeWeight(2);
    translate(this.cueBall.position.x, this.cueBall.position.y, 100);
    rotate(angle + HALF_PI);
    translate(-CUE_WIDTH / 2, BALL_SIZE);
    rect(0, 0, CUE_WIDTH, CUE_LENGTH);
    popMatrix();
  }
}

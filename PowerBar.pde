class PowerBar
{
  float power = 20;
  PVector p;
  PVector s;
  
  PowerBar(float x, float y, float w, float h)
  {
    this.p = new PVector(x, y);
    this.s = new PVector(w, h);
  }
  
  void addValue(float value)
  {
    this.power += value;
    this.power = constrain(this.power, 1, 100);
  }
  
  boolean mousePressed()
  {
    if (mouseX >= this.p.x && mouseX <= this.p.x + this.s.x
      && mouseY >= this.p.y && mouseY <= this.p.y + this.s.y)
    {
      this.power = (mouseX - this.p.x) / this.s.x * 100;
      
      return true;
    }
    
    return false;
  }
  
  float getForce()
  {
    return POWER_MAX * this.power / 100;
  }
  
  void draw()
  {
    pushMatrix();
    strokeWeight(4);
    stroke(0);
    fill(0);
    translate(this.p.x, this.p.y);
    rect(0, 0, this.s.x, this.s.y);
    fill(0, 255, 255);
    rect(0, 0, this.s.x * this.power / 100, this.s.y);
    translate(this.s.x / 2, this.s.y / 2);
    popMatrix();
  }
}

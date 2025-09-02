class Pocket
{
  PVector p;
  boolean edge;
  
  Pocket(float x, float y, boolean edge)
  {
    this.p = new PVector(x, y);
    this.edge = edge;
  }
  
  float getSize()
  {
    return this.edge ? EDGE_POCKET_SIZE : CORNER_POCKET_SIZE;
  }
  
  void draw()
  {
    noStroke();
    //fill(#009317);
    //ellipse(this.p.x, this.p.y, size, size);
    fill(32);
    ellipse(this.p.x, this.p.y, this.getSize(), this.getSize());
    fill(0);
    ellipse(this.p.x, this.p.y, this.getSize() * 0.9, this.getSize() * 0.9);
  }
}

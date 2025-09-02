Bumper createBumper(float ...verticesXY)
{
  float x = 0;
  float y = 0;
  
  PVector[] vertices = new PVector[verticesXY.length / 2];
  
  for (int i = 0; i < verticesXY.length; i += 2)
  {
    vertices[i / 2] = new PVector(x + verticesXY[i], y + verticesXY[i + 1]);
    x += verticesXY[i];
    y += verticesXY[i + 1];
  }
  
  return new Bumper(vertices);
}

class Bumper
{
  Polygon polygon;
  
  Bumper(PVector ...vertices)
  {
    this.polygon = new Polygon(vertices);
  }
  
  void drawShadow()
  {
    pushMatrix();
    noStroke();
    fill(0, S_OPACITY);
    translate(S_OFF.x, S_OFF.y);
    beginShape();
    for (PVector vt : this.polygon.points)
    {
      vertex(vt.x, vt.y);
    }
    endShape(CLOSE);
    popMatrix();
  }
  
  void draw()
  {
    pushMatrix();
    strokeWeight(2);
    fill(BUMPER_COLOR);
    noStroke();
    //stroke(#03550F);
    //translate(this.p.x, this.p.y);
    //rect(0, 0, this.s.x, this.s.y);
    beginShape();
    for (PVector vt : this.polygon.points)
    {
      vertex(vt.x, vt.y);
    }
    endShape(CLOSE);
    popMatrix();
    
    //this.polygon.drawOffsetEdges(BALL_SIZE / 2);
  }
}

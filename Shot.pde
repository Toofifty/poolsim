class Shot
{
  float angle;
  float force;
  float sideSpin;
  float topSpin;
  
  Shot(float angle, float force, float sideSpin, float topSpin)
  {
    this.angle = angle;
    this.force = force;
    this.sideSpin = sideSpin;
    this.topSpin = topSpin;
  }
  
  Shot(float angle, float force)
  {
    this.angle = angle;
    this.force = force;
    this.sideSpin = 0;
    this.topSpin = 0;
  }
}

float _R = 32 * 1.33 / 2; // ball radius
float _M = 1; // mass
float _SLF = 0.2; // sliding friction
float _SPF = 0.044; // spinning friction
float _G = 9.81; // gravy

// HELPERS

float angle2D(PVector v)
{
  return atan2(v.y, v.x);
}

//PVector rotateZ(PVector v, float angle)
//{
//  float cosA = cos(angle);
//  float sinA = sin(angle);
//  return new PVector(
//    v.x * cosA
//  );
//}

class BallState
{
  PVector r; // displacement (position)
  PVector v; // velocity
  PVector w; // angular velocity
  
  BallState(PVector r, PVector v, PVector w)
  {
    this.r = r;
    this.v = v;
    this.w = w;
  }
  
  BallState(BallState other)
  {
    this.r = other.r;
    this.v = other.v;
    this.w = other.w;
  }
  
  BallState copy()
  {
    return new BallState(this);
  }
  
  PVector relativeVelocity()
  {
    return this.surfaceVelocity(new PVector(0, 0, -1));
  }
  
  PVector surfaceVelocity(PVector normal)
  {
    PVector contactVelocity = PVector.cross(this.w, normal, null).mult(_R);
    return PVector.sub(this.v, contactVelocity);
  }

  // PHYSICS
  
  //BallState evolveSlideState(float dt)
  //{
  //  if (dt == 0) return this.copy();
    
  //  float phi = angle2D(this.v);
  //}
}

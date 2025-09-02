Quaternion toQuaternion(PVector axis, float angle)
{
  float half = angle / 2.0;
  float s = sin(half);
  return new Quaternion(cos(half), axis.x * s, axis.y * s, axis.z * s);
}

Quaternion randomQuaternion()
{
  return toQuaternion(new PVector(random(-1, 1), random(-1, 1)).normalize(), random(TWO_PI));
}

class Quaternion
{
  float w, x, y, z;
  
  Quaternion() {
    w = 1;
    x = y = z = 0;
  }
  
  Quaternion(float w, float x, float y, float z)
  {
    this.w = w;
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  Quaternion copy()
  {
    return new Quaternion(this.w, this.x, this.y, this.z);
  }

  Quaternion multiply(Quaternion b) {
    return new Quaternion(
      w * b.w - x * b.x - y * b.y - z * b.z,
      w * b.x + x * b.w + y * b.z - z * b.y,
      w * b.y - x * b.z + y * b.w + z * b.x,
      w * b.z + x * b.y - y * b.x + z * b.w
    );
  }

  AxisAngle toAxisAngle() {
    AxisAngle axisAngle = new AxisAngle();
    if (w > 1)
    {
      this.normalize();
    }
    axisAngle.angle = 2 * acos(this.w);
    float s = sqrt(1 - this.w * this.w);
    if (s < 0.0001)
    {
      axisAngle.axis = new PVector(1, 0, 0);
    }
    else
    {
      axisAngle.axis = new PVector(this.x / s, this.y / s, this.z / s);
    }
    return axisAngle;
  }

  void normalize() {
    float m = sqrt(this.w * this.w + this.x * this.x + this.y * this.y + this.z * this.z);
    if (m == 0)
    {
      this.w = 1;
      this.x = this.y = this.z = 0;
      return;
    }
    this.w /= m;
    this.x /= m;
    this.y /= m;
    this.z /= m;
  }
}

class AxisAngle
{
  float angle;
  PVector axis;
}

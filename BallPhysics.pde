class BallPhysics
{
  PVector position;
  PVector velocity;
  float radius = BALL_SIZE / 2;
  Quaternion orientation = new Quaternion();
  
  PVector spin = new PVector(0, 0, 0);
  
  // todo: constants
  float mass = 1.0;
  float spinDecay = 0.98;
  float rollingThreshold = 0.1;
  float friction = 0.002;
  float bounceBall = 0.9;
  float bounceWall = 0.75;
  float magnusStrength = 0.001;
  
  BallPhysics(float x, float y)
  {
    this.position = new PVector(x, y);
    this.velocity = new PVector(0, 0);
  }
  
  void update()
  {
    if (this.spin.mag() > 0.01 && this.velocity.mag() > 0.01)
    {
      this.velocity.add(this.calculateMagnusForce());
    }
    
    float speed = this.velocity.mag();
    if (speed > 0)
    {
      // friction
      float frictionCoeff = (speed < this.rollingThreshold) ? this.friction * 2 : this.friction;
      this.velocity.add(PVector.mult(this.velocity, -frictionCoeff));
    }
      
    if (this.velocity.mag() < 0.001)
    {
      this.velocity.mult(0);
      this.spin.mult(0);
    }
    
    this.position.add(this.velocity);
    this.spin.mult(this.spinDecay);
    this.updateOrientation();
  }
  
  PVector calculateMagnusForce()
  {
    PVector force = new PVector();
    
    if (abs(this.spin.z) > 0.01)
    {
      PVector perpendicular = new PVector(-this.velocity.y, this.velocity.x);
      perpendicular.normalize();
      perpendicular.mult(this.spin.z * this.magnusStrength * this.velocity.mag());
      force.add(perpendicular);
    }
    
    if (abs(this.spin.y) > 0.01)
    {
      PVector forward = PVector.mult(this.velocity, 1);
      forward.normalize();
      forward.mult(this.spin.y * this.magnusStrength * this.velocity.mag());
      force.add(forward);
    }
    
    return force;
  }
  
  void updateOrientation()
  {
    if (this.velocity.mag() > 0.01)
    {
      float angle = this.velocity.mag() / this.radius;
      PVector axis = new PVector(-this.velocity.y, this.velocity.x, 0).normalize();
      
      this.orientation = this.orientation.multiply(toQuaternion(axis, angle));
    }
  }
  
  boolean collide(BallPhysics other)
  {
    PVector diff = PVector.sub(this.position, other.position);
    float distance = diff.mag();
    float minDistance = this.radius + other.radius;
    
    if (distance < minDistance && distance > 0)
    {
      // separate balls
      PVector separation = PVector.mult(diff, (minDistance - distance) / (2 * distance));
      this.position.add(separation);
      other.position.sub(separation);
      
      PVector normal = PVector.div(diff, distance);
      PVector relativeVelocity = PVector.sub(this.velocity, other.velocity);
      float velocityAlongNormal = PVector.dot(relativeVelocity, normal);
      
      if (velocityAlongNormal > 0)
      {
        return true;
      }
      
      float impulse = -(1 + this.bounceBall) * velocityAlongNormal;
      impulse /= (1 / this.mass + 1 / other.mass);
      
      PVector impulseVector = PVector.mult(normal, impulse);
      this.velocity.add(PVector.div(impulseVector, this.mass));
      other.velocity.sub(PVector.div(impulseVector, other.mass));
      
      this.applyCollisionSpin(other, normal, impulseVector);
      
      return true;
    }
    
    return false;
  }
  
  void applyCollisionSpin(BallPhysics other, PVector normal, PVector impulse)
  {
    // Transfer some spin energy during collision
    float spinTransfer = 1;
    float frictionCoeff = 1; // Friction during collision
    
    // Calculate tangent direction
    PVector tangent = new PVector(-normal.y, normal.x);
    
    // Get relative velocity at contact point
    PVector relativeVel = PVector.sub(this.velocity, other.velocity);
    float tangentialVel = PVector.dot(relativeVel, tangent);
    
    // Include existing spin in relative motion
    // Contact point is at distance 'radius' from center
    float contactVel1 = tangentialVel + spin.z * radius;
    float contactVel2 = -spin.z * radius - other.spin.z * radius;
    float relativeContactVel = contactVel1 - contactVel2;
    
    // Generate spin from friction during collision
    float normalImpulse = PVector.dot(impulse, normal);
    float maxFrictionImpulse = abs(normalImpulse) * frictionCoeff;
    
    // Friction opposes relative sliding motion
    float frictionImpulse = constrain(-relativeContactVel * 0.1, -maxFrictionImpulse, maxFrictionImpulse);
    
    // Convert friction impulse to angular impulse (torque)
    float angularImpulse = frictionImpulse / radius;
    
    // Apply angular impulse to both balls (opposite directions)
    spin.z += angularImpulse * 0.5;
    other.spin.z -= angularImpulse * 0.5;
    
    // Also apply some direct spin transfer
    float avgSpin = (spin.z + other.spin.z) * 0.5;
    spin.z = spin.z * (1 - spinTransfer) + avgSpin * spinTransfer;
    other.spin.z = other.spin.z * (1 - spinTransfer) + avgSpin * spinTransfer;
    
    // Energy loss in collision
    spin.mult(0.85);
    other.spin.mult(0.85);
    
    // Clamp spin values to realistic ranges
    spin.z = constrain(spin.z, -15, 15);
    other.spin.z = constrain(other.spin.z, -15, 15);
  }
  
  boolean collide(Bumper bumper)
  {
    PVector closestPoint = this.findClosestPointOnPolygon(bumper.polygon);
    PVector diff = PVector.sub(this.position, closestPoint);
    float distance = diff.mag();
    
    if (distance < this.radius && distance > 0)
    {
      PVector normal = PVector.div(diff, distance);
      
      // separation
      this.position.add(PVector.mult(normal, this.radius - distance));
      
      float velocityDotNormal = PVector.dot(this.velocity, normal);
      if (velocityDotNormal < 0)
      {
        PVector reflection = PVector.mult(normal, 2 * velocityDotNormal);
        this.velocity.sub(reflection);
        this.velocity.mult(this.bounceWall);
        
        this.applyWallCollisionSpin(normal);
      }
      
      return true;
    }
    
    return false;
  }
  
  void applyWallCollisionSpin(PVector normal)
  {
    PVector tangent = new PVector(-normal.y, normal.x);
    float tangentialVelocity = PVector.dot(this.velocity, tangent);
    
    // Convert some tangential velocity to spin
    this.spin.z += tangentialVelocity * 0.05;
    
    // Reduce existing spin due to collision
    this.spin.mult(0.7);
    
    // Clamp spin to reasonable values
    this.spin.z = constrain(this.spin.z, -MAX_TOPSPIN, MAX_TOPSPIN);
  }
  
  PVector findClosestPointOnPolygon(Polygon polygon)
  {
    PVector[] points = polygon.points;
    PVector closest = points[0];
    float minDistSq = PVector.sub(this.position, closest).magSq();
    
    for (int i = 0; i < points.length; i++)
    {
      PVector start = points[i];
      PVector end = points[(i + 1) % points.length];
      
      PVector closestOnEdge = this.findClosestPointOnLineSegment(start, end);
      float distSq = PVector.sub(this.position, closestOnEdge).magSq();
      
      if (distSq < minDistSq)
      {
        minDistSq = distSq;
        closest = closestOnEdge;
      }
    }
    
    return closest;
  }
  
  PVector findClosestPointOnLineSegment(PVector start, PVector end)
  {
    PVector line = PVector.sub(end, start);
    PVector toPoint = PVector.sub(this.position, start);
    
    float lineLength = line.magSq();
    if (lineLength == 0)
    {
      return start.copy();
    }
    
    float t = constrain(PVector.dot(toPoint, line) / lineLength, 0, 1);
    
    return PVector.add(start, PVector.mult(line, t));
  }
  
  void addSpin(float sideSpin, float topSpin)
  {
    this.spin.z += sideSpin;
    this.spin.y += topSpin;
    
    this.spin.z = constrain(this.spin.z, -MAX_SIDESPIN, MAX_SIDESPIN);
    this.spin.y = constrain(this.spin.y, -MAX_TOPSPIN, MAX_TOPSPIN);
  }
  
  boolean isSettled()
  {
    return this.velocity.mag() < 0.001 && this.spin.mag() < 0.01;
  }
}

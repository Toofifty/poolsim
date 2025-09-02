final float BOUNCE_BALL = 0.9;
final float BOUNCE_WALL = 0.75;
final float FRICTION = 0.002;

final int BALL_DETAIL = 64;
final int BALL_VARIETY = 128;

class Ball extends BallPhysics
{
  color c;
  int number;
  
  boolean sunk = false;
  Pocket sunkPocket = null;
  PVector pocketPosition = null;
  Ball original = null;
  
  // for cue ball
  Ball firstCollision = null;
  
  // future collisions
  List<PVector> collisionPoints = new ArrayList<>();
  // hehe
  List<Quaternion> collisionOrientations = new ArrayList<>();
  // path before collision
  List<PVector> trackingPoints = new ArrayList<>();
  
  boolean fouled = false;
  
  PShape shape;
  
  Ball(float x, float y, color c)
  {
    super(x, y);
    this.c = c;
    this.number = -1;
    
    this.createSphere();
  }
  
  Ball(float x, float y, color c, int number)
  {
    super(x, y);
    this.c = c;
    this.number = number;
    
    this.createSphere();
  }
  
  Ball(float x, float y, color c, int number, Ball original)
  {
    super(x, y);
    this.c = c;
    this.number = number;
    this.original = original;
    this.orientation = original.orientation.copy();
    
    this.createSphere();
  }
  
  void createSphere()
  {
    if (!ENABLE_3D)
    {
      return;
    }
    
    if (this.original != null)
    {
      this.shape = createShape(SPHERE, this.radius);
      this.shape.setFill(this.c);
      return;
    }
    
    int tsize = BALL_DETAIL;
    PGraphics texture = createGraphics(tsize * 2, tsize, P2D);
    texture.beginDraw();
    texture.background(this.c);
    for (int i = 0; i < tsize * 2; i++)
    {
      for (int j = 0; j < tsize; j++)
      {
        float n = noise(i / 10.0, j / 10.0);
        texture.stroke(0, n * BALL_VARIETY);
        texture.point(i, j);
        float n2 = noise(tsize * 2 - i / 10.0, tsize - j / 10.0);
        texture.stroke(255, n2 * BALL_VARIETY);
        texture.point(i, j);
      }
    }
    if (this.number != -1)
    {
      texture.noStroke();
      texture.fill(DARK_THEME ? 32 : 255);
      texture.ellipse(tsize / 2, tsize / 2, tsize / 3, tsize / 3);
      texture.ellipse(tsize * 3 / 2, tsize / 2, tsize / 3, tsize / 3);
      texture.fill(DARK_THEME ? 255 : 0);
      texture.textSize(tsize / 4);
      texture.textAlign(CENTER, CENTER);
      texture.text("" + this.number, tsize / 2, tsize / 2);
      texture.text("" + this.number, tsize * 3 / 2, tsize / 2);
      texture.text("" + this.number, tsize / 2, tsize / 2);
      texture.text("" + this.number, tsize * 3 / 2, tsize / 2);
      texture.text("" + this.number, tsize / 2, tsize / 2);
      texture.text("" + this.number, tsize * 3 / 2, tsize / 2);
      texture.text("" + this.number, tsize / 2, tsize / 2);
      texture.text("" + this.number, tsize * 3 / 2, tsize / 2);
      
      if (this.number >= 9)
      {
        texture.fill(DARK_THEME ? 32 : 255);
        texture.rect(0, 0, tsize * 2, tsize / 4);
        texture.rect(0, tsize * 3 / 4, tsize * 2, tsize / 4);
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
  
  Ball copy()
  {
    Ball ball = new Ball(this.position.x, this.position.y, this.c, this.number, this);
    ball.sunk = this.sunk;
    ball.sunkPocket = this.sunkPocket;
    return ball;
  }
  
  void clearCollisionPoints()
  {
    if (this.original != null)
    {
      this.original.clearCollisionPoints();
      return;
    }
    this.collisionPoints.clear();
    this.collisionOrientations.clear();
    this.trackingPoints.clear();
  }
  
  void addCollisionPoint(PVector position, Quaternion orientation)
  {
    this.collisionPoints.add(position);
    this.collisionOrientations.add(orientation);
    this.trackingPoints.add(position);
  }
  
  void addCollisionPoint()
  {
    if (this.original != null)
    {
      this.original.addCollisionPoint(this.position.copy(), this.orientation.copy());
      return;
    }
    this.addCollisionPoint(this.position.copy(), this.orientation.copy());
  }
  
  void addTrackingPoint(PVector position)
  {
    if (!this.sunk)
    {
      this.trackingPoints.add(position);
    }
  }
  
  void addTrackingPoint()
  {
    if (this.original != null)
    {
      this.original.addTrackingPoint(this.position.copy());
      return;
    }
    this.addTrackingPoint(this.position.copy());
  }
  
  boolean isMoving()
  {
    return !this.isSettled();
  }
  
  void applyForce(float angle, float power)
  {
    this.velocity.x += power * cos(angle);
    this.velocity.y += power * sin(angle);
  }
  
  void applyForce(PVector force)
  {
    this.velocity.add(force);
  }
  
  void update()
  {
    // sink into pocket
    if (this.sunk)
    {
      if (this.pocketPosition != null)
      {
        this.position.lerp(this.pocketPosition, 0.01);
      }
      this.velocity.setMag(0);
      this.spin.setMag(0);
      return;
    }
    
    super.update();
  }
  
  boolean didCollide(List<Ball> balls, int index)
  {
    return this.collide(balls, index).size() > 0;
  }
  
  boolean didCollide(Pocket pocket)
  {
    return this.collide(pocket);
  }
  
  boolean didCollide(Bumper bumper)
  {
    return this.collide(bumper);
  }
  
  /** @deprecated */
  List<Ball> collide(List<Ball> balls, int index)
  {
    List<Ball> collisions = new ArrayList();
    
    if (this.sunk)
    {
      return collisions;
    }
    
    for (int i = index; i < balls.size(); i++)
    {
      Ball ball = balls.get(i);
      
      if (ball.sunk)
      {
        continue;
      }
      
      if (this.collide(ball))
      {
        collisions.add(ball);
      }
    }
    
    return collisions;
  }
  
  boolean collide(Pocket pocket)
  {
    if (this.sunk)
    {
      return false;
    }
    
    if (dist(this.position.x, this.position.y, pocket.p.x, pocket.p.y) < pocket.getSize() / 2)
    {
      this.sunk = true;
      this.sunkPocket = pocket;
      PVector randOffset = new PVector(random(-1, 1), random(-1, 1));
      randOffset.setMag(random(pocket.getSize() / 2 - BALL_SIZE / 2 - 4));
      this.pocketPosition = PVector.add(pocket.p, randOffset);
      
      return true;
    }
    
    return false;
  }
  
  void drawBall(PGraphics graphics, PVector position, Quaternion orientation)
  {
    float size = this.sunk ? BALL_SIZE * 0.75 : BALL_SIZE;
    
    graphics.pushMatrix();
    graphics.translate(position.x, position.y, this.sunk ? -10 : 0);
    
    graphics.noStroke();
    
    graphics.fill(this.c);
    graphics.pushMatrix();
    
    int outlineWidth = 4;
    // outline
    graphics.ellipse(0, 0, size + outlineWidth, size + outlineWidth);
    graphics.fill(0, 64);
    graphics.ellipse(0, 0, size + outlineWidth, size + outlineWidth);
    
    // ball
    AxisAngle axisAngle = orientation.toAxisAngle();
    graphics.rotate(axisAngle.angle, axisAngle.axis.x, axisAngle.axis.y, axisAngle.axis.z);
    
    graphics.shape(this.shape);
    
    graphics.popMatrix();
    
    // fake specular
    graphics.pushStyle();
    graphics.translate(0, 0, 50);
    graphics.fill(color(255, 255, 255, 96));
    graphics.noStroke();
    graphics.ellipse(
      -size / 6, -size / 6,
      size * 0.4, size * 0.4
    );
    graphics.popStyle();
    
    // vector debug
    graphics.pushMatrix();
    
    graphics.translate(0, 0, 100);
    // velocity
    //graphics.stroke(255, 255, 0);
    //graphics.line(0, 0, this.v.x * 100, this.v.y * 100);
    
    // angular rotation
    //graphics.stroke(0, 255, 255);
    //graphics.line(0, 0, this.rotationAxis.x * 100, this.rotationAxis.y * 100);
    
    graphics.popMatrix();
    graphics.popMatrix();
  }
  
  void drawConnection(PVector start, PVector end, float opacity)
  {
    stroke(this.c, opacity);
    line(
      start.x, start.y,
      end.x, end.y
    );
  }
  
  void drawShadow()
  {
    if (this.sunk)
    {
      return;
    }
    
    fill(0, S_OPACITY);
    noStroke();
    ellipse(this.position.x + S_OFF.x, this.position.y + S_OFF.y, this.radius * 2, this.radius * 2);
  }
  
  void drawAimAssist(PGraphics graphics)
  {
    if (this.original != null)
    {
      return;
    }
    
    if (!this.sunk)
    {
      // draw tracking
      for (int i = 0; i < this.trackingPoints.size(); i++)
      {
        PVector point = this.trackingPoints.get(i);
        
        if (i == 0)
        {
          this.drawConnection(point, this.position, 255);
        }
        else
        {
          this.drawConnection(point, this.trackingPoints.get(i - 1), 255);
        }
      }
      
      // draw aim assist
      for (int i = 0; i < this.collisionPoints.size(); i++)
      {
        PVector point = this.collisionPoints.get(i);
        Quaternion orientation = this.collisionOrientations.get(i);
        this.drawBall(graphics, point, orientation);
      }
    }
  }
  
  void draw()
  { 
    if (this.original != null)
    {
      return;
    }
    
    this.drawBall(g, this.position, this.orientation);
  }
}

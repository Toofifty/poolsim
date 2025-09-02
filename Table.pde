final float SCALE = 1.33;

final float CORNER_POCKET_SIZE = 64 * SCALE;
final float EDGE_POCKET_SIZE = 56 * SCALE;
final float BALL_SIZE = 32 * SCALE;
final float BUMPER_WIDTH = 16 * SCALE;
final float TABLE_WIDTH = 1200 * SCALE;
final float TABLE_HEIGHT = 600 * SCALE;
final float EDGE_WIDTH = CORNER_POCKET_SIZE / 2 + 8 * SCALE;

enum GameMode
{
  _8BALL,
  _9BALL
}

class Table
{
  Rack rack = new Rack();
  Cue cue;
  List<Bumper> bumpers;
  List<Polygon> bumperPolygons;
  List<Pocket> pockets;
  PowerBar powerBar;
  TableState state;
  SpinControl spinControl;
  
  PVector c;
  
  private GameManager game;

  PGraphics aag;
  
  Table(GameManager game)
  {
    this.game = game;
    this.state = new TableState();
  }
  
  void setup()
  {
    this.c = new PVector(width / 2, height / 2 - 64);
    this.aag = createGraphics(width, height, P3D);
    this.createBumpers();
    this.createPockets();
    this.createPowerBar();
    this.spinControl = new SpinControl(c.x - TABLE_WIDTH / 2, c.y + TABLE_HEIGHT / 2 + EDGE_WIDTH + 64, 48);
  }
  
  boolean mousePressed()
  {
    boolean captured = false;
    
    captured |= this.powerBar.mousePressed();
    captured |= this.spinControl.mousePressed();
    
    return captured;
  }
  
  void createBumpers()
  { 
    float leftBound = c.x - TABLE_WIDTH / 2;
    float rightBound = c.x + TABLE_WIDTH / 2;
    float topBound = c.y - TABLE_HEIGHT / 2;
    float bottomBound = c.y + TABLE_HEIGHT / 2;
    
    float vBumperHeight = TABLE_HEIGHT - CORNER_POCKET_SIZE;
    float hBumperWidth = TABLE_WIDTH / 2 - CORNER_POCKET_SIZE / 2 - EDGE_POCKET_SIZE / 2;
  
    this.bumpers = new ArrayList<>();
    
    // left
    this.bumpers.add(createBumper(
      leftBound, topBound + CORNER_POCKET_SIZE / 2,
      BUMPER_WIDTH, BUMPER_WIDTH,
      0, vBumperHeight - BUMPER_WIDTH * 2,
      -BUMPER_WIDTH, BUMPER_WIDTH
    ));
    
    // right
    this.bumpers.add(createBumper(
      rightBound, topBound + CORNER_POCKET_SIZE / 2,
      -BUMPER_WIDTH, BUMPER_WIDTH,
      0, vBumperHeight - BUMPER_WIDTH * 2,
      BUMPER_WIDTH, BUMPER_WIDTH
    ));
    
    // top-left
    this.bumpers.add(createBumper(
      leftBound + CORNER_POCKET_SIZE / 2, topBound,
      hBumperWidth, 0,
      -BUMPER_WIDTH / 2, BUMPER_WIDTH,
      -hBumperWidth + BUMPER_WIDTH * 3 / 2, 0
    ));
    
    // top-right
    this.bumpers.add(createBumper(
      rightBound - CORNER_POCKET_SIZE / 2, topBound,
      -hBumperWidth, 0,
      BUMPER_WIDTH / 2, BUMPER_WIDTH,
      hBumperWidth - BUMPER_WIDTH * 3 / 2, 0
    ));
    
    // bottom-left
    this.bumpers.add(createBumper(
      leftBound + CORNER_POCKET_SIZE / 2, bottomBound,
      hBumperWidth, 0,
      -BUMPER_WIDTH / 2, -BUMPER_WIDTH,
      -hBumperWidth + BUMPER_WIDTH * 3 / 2, 0
    ));
    
    // bottom-right
    this.bumpers.add(createBumper(
      rightBound - CORNER_POCKET_SIZE / 2, bottomBound,
      -hBumperWidth, 0,
      BUMPER_WIDTH / 2, -BUMPER_WIDTH,
      hBumperWidth - BUMPER_WIDTH * 3 / 2, 0
    ));
    
    this.bumperPolygons = this.bumpers.stream().map(b -> b.polygon).toList();
  }
  
  void createPockets()
  {
    float leftBound = c.x - TABLE_WIDTH / 2;
    float rightBound = c.x + TABLE_WIDTH / 2;
    float topBound = c.y - TABLE_HEIGHT / 2;
    float bottomBound = c.y + TABLE_HEIGHT / 2;
    
    this.pockets = new ArrayList<>();
  
    this.pockets.add(new Pocket(leftBound, topBound, false));
    this.pockets.add(new Pocket(rightBound, topBound, false));
    this.pockets.add(new Pocket(leftBound, bottomBound, false));
    this.pockets.add(new Pocket(rightBound, bottomBound, false));
    
    // edges
    float edgeOffset = (CORNER_POCKET_SIZE - EDGE_POCKET_SIZE) / 2;
    this.pockets.add(new Pocket(c.x, topBound - edgeOffset, true));
    this.pockets.add(new Pocket(c.x, bottomBound + edgeOffset, true));
  }
  
  void createPowerBar()
  {
    float leftBound = c.x - TABLE_WIDTH / 2;
    float topBound = c.y - TABLE_HEIGHT / 2;
    this.powerBar = new PowerBar(
      leftBound, topBound - EDGE_WIDTH - BUMPER_WIDTH * 3 / 2,
      TABLE_WIDTH, BUMPER_WIDTH
    );
  }
  
  void setBalls(List<Ball> balls)
  {
    this.state.setBalls(balls);
  }
  
  void setup8Ball()
  {
    this.placeCueBall();
    this.setBalls(this.rack.generate8Ball(this.c.x + TABLE_WIDTH / 4, this.c.y));
  }
  
  void setup9Ball()
  {
    this.placeCueBall();
    this.setBalls(this.rack.generate9Ball(this.c.x + TABLE_WIDTH / 4, this.c.y));
  }
  
  void setupDebugGame()
  {
    this.placeCueBall();
    this.setBalls(this.rack.generateDebugGame(this.c.x + TABLE_WIDTH / 4, this.c.y));
  }
  
  void placeCueBall()
  {
    this.state.cueBall = new Ball(this.c.x - TABLE_WIDTH / 4, this.c.y, DARK_THEME ? color(32, 32, 32) : color(220, 220, 220));
    this.cue = new Cue(this.state.cueBall, this.spinControl);
  }
  
  void draw()
  {
    float leftBound = c.x - TABLE_WIDTH / 2;
    float rightBound = c.x + TABLE_WIDTH / 2;
    float topBound = c.y - TABLE_HEIGHT / 2;
    float bottomBound = c.y + TABLE_HEIGHT / 2;
    
    specular(0, 0, 0);
    shininess(1.0);
    
    // table layer
    pushMatrix();
    noStroke();
    fill(64);
    rect(
      leftBound - EDGE_WIDTH, topBound - EDGE_WIDTH,
      TABLE_WIDTH + EDGE_WIDTH * 2, TABLE_HEIGHT + EDGE_WIDTH * 2,
      CORNER_POCKET_SIZE * 0.66
    );
    fill(TABLE_COLOR);
    rect(
      leftBound, topBound,
      TABLE_WIDTH, TABLE_HEIGHT
    );
    popMatrix();
    
    // shadow layer
    this.state.cueBall.drawShadow();
    for (Ball ball : this.state.balls)
    {
      ball.drawShadow();
    }
    for (Bumper bumper : this.bumpers)
    {
      bumper.drawShadow();
    }
    
    // table occlusion layer
    pushMatrix();
    noStroke();
    fill(EDGE_COLOR);
    // top
    rect(
      leftBound, topBound - EDGE_WIDTH,
      TABLE_WIDTH, EDGE_WIDTH
    );
    // bottom
    rect(
      leftBound, bottomBound,
      TABLE_WIDTH, EDGE_WIDTH
    );
    // left
    rect(
      leftBound - EDGE_WIDTH, topBound,
      EDGE_WIDTH, TABLE_HEIGHT
    );
    // right
    rect(
      rightBound, topBound,
      EDGE_WIDTH, TABLE_HEIGHT
    );
    popMatrix();
    
    // real layer
    
    for (Pocket pocket : this.pockets)
    {
      pocket.draw();
    }
    for (Bumper bumper : this.bumpers)
    {
      bumper.draw();
    }
    this.powerBar.draw();
    
    // aim assist
    if (this.aag != null)
    {
      this.aag.beginDraw();
      this.aag.ortho();
      this.aag.clear();
      this.state.cueBall.drawAimAssist(this.aag);
      for (Ball ball : this.state.balls)
      {
        ball.drawAimAssist(this.aag);
      }
      this.aag.endDraw();
    }
    
    tint(255, 64);
    image(this.aag, 0, 0);
    noTint();
    
    // balls
    this.state.cueBall.draw();
    for (Ball ball : this.state.balls)
    {
      ball.draw();
    }
  
    if (this.game.isPlayerShooting())
    {
      this.cue.drawShadow();
      this.cue.draw();
      
      //Ray ray = new Ray(this.state.cueBall.p, this.cue.getAngle());
      //ray.cast(this.bumpers.stream().map(b -> b.polygon).toList(), this.state.balls, this.state.cueBall.radius, 10);
      //ray.draw();
    }
    
    this.spinControl.draw();
    
    fill(255);
    textSize(32);
    textAlign(CENTER, TOP);
    text(this.game.getStatusText() + " | " + nfc(frameRate, 1) + " FPS", c.x, c.y + TABLE_HEIGHT / 2 + EDGE_WIDTH + BUMPER_WIDTH);
  }
}

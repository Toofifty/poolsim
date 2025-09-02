final int MAX_ITER = 10_000;
final int TRACKING_POINT_DIST = 10;

class Simulation
{
  class Collision
  {
    Ball initiator;
    
    Ball ball = null;
    Bumper bumper = null;
    Pocket pocket = null;
    
    Collision(Ball initiator, Ball ball)
    {
      this.initiator = initiator;
      this.ball = ball;
    }
    
    Collision(Ball initiator, Bumper bumper)
    {
      this.initiator = initiator;
      this.bumper = bumper;
    }
    
    Collision(Ball initiator, Pocket pocket)
    {
      this.initiator = initiator;
      this.pocket = pocket;
    }
  }
  
  class Result
  {
    int stepIterations = 1;
    
    // game logic
    int ballsPotted = 0;
    boolean pottedCueBall = false;
    // hit non-lowest in 9ball or 8 ball in 8ball
    boolean hitFoulBall = false;
    int firstStruck = -1;
    
    // stats
    int cueBallCollisions = 0;
    int cueBallBumperCollisions = 0;
    
    // todo: make into maps
    int ballCollisions = 0;
    int ballBumperCollisions = 0;
    
    List<Collision> collisions = new ArrayList<>();
    
    TableState state;
    
    Result(TableState state)
    {
      this.state = state;
    }
    
    Simulation.Result add(Simulation.Result other)
    {
      this.stepIterations += other.stepIterations;
      
      this.ballsPotted += other.ballsPotted;
      this.pottedCueBall |= other.pottedCueBall;
      this.hitFoulBall |= other.hitFoulBall;
      this.firstStruck = this.firstStruck == -1 ? other.firstStruck : this.firstStruck;
      
      this.cueBallCollisions += other.cueBallCollisions;
      this.cueBallBumperCollisions += other.cueBallBumperCollisions;
      this.ballCollisions += other.ballCollisions;
      this.ballBumperCollisions += other.ballBumperCollisions;
      
      this.collisions.addAll(other.collisions);
      
      return this;
    }
    
    boolean hasFoul()
    {
      return this.cueBallCollisions == 0
        || this.pottedCueBall
        || this.hitFoulBall;
    }
    
    String toString()
    {
      return "  ballsPotted: " + ballsPotted
        + "\n  pottedCueBall: " + pottedCueBall
        + "\n  hitFoulBall: " + hitFoulBall
        + "\n  firstStruck: " + firstStruck
        + "\n  cueBallCollisions: " + cueBallCollisions
        + "\n  cueBallBumperCollisions: " + cueBallBumperCollisions
        + "\n  ballCollisions: " + ballCollisions
        + "\n  ballBumperCollisions: " + ballBumperCollisions;
    }
  }
  
  class StepResult extends Simulation.Result
  {
    StepResult()
    {
      super(null);
    }
    
    boolean hasBallCollision()
    {
      return this.cueBallCollisions > 0 || this.ballCollisions > 0;
    }
    
    boolean hasBumperCollision()
    {
      return this.cueBallBumperCollisions > 0 || this.ballBumperCollisions > 0;
    }
  }
  
  private Table table;
  private Simulation.Result current;
  
  private float lastSimulationKey = 0;
  
  Simulation(Table table)
  {
    this.table = table;
    this.reset();
  }
  
  void reset()
  {
    this.current = new Simulation.Result(this.table.state);
  }
  
  float getKey(Shot shot)
  {
    return shot.angle + shot.force * 100 + shot.sideSpin * 1000 + shot.topSpin * 10000;
  }
  
  /**
   * Returns true if a raycast from the cueball on this angle
   * hits no ball or does not hit a target ball
   */
  boolean shouldCullAngle(float angle)
  {
    Ray ray = new Ray(this.table.state.cueBall.position, angle);
    ray.cast(
      this.table.bumperPolygons,
      this.table.state.balls,
      this.table.state.cueBall.radius,
      3
    );
      
    return ray.hitBall == null
    || ray.hitBall.number != this.table.state.getLowestBallNumber();
  }
  
  Simulation.Result getResult()
  {
    return this.current;
  }
  
  Simulation.StepResult step(TableState state, boolean trackCollisionPoints)
  {
    return this.step(state, trackCollisionPoints, -1);
  }
  
  Simulation.StepResult step(TableState state, boolean trackCollisionPoints, int stepIndex)
  {
    Simulation.StepResult result = new Simulation.StepResult();
    
    // update balls
    state.cueBall.update();
    if (trackCollisionPoints && stepIndex % TRACKING_POINT_DIST == 0)
    {
      state.cueBall.addTrackingPoint();
    }
    
    for (Ball ball : state.balls)
    {
      ball.update();
      if (trackCollisionPoints && stepIndex % TRACKING_POINT_DIST == 0)
      {
        ball.addTrackingPoint();
      }
    }
    
    List<Ball> activeBalls = state.getActiveBalls();
    
    // cue ball <-> ball collisions
    // todo: individual loop
    List<Ball> cueBallCollisions = state.cueBall.collide(activeBalls, 0);
    if (cueBallCollisions.size() > 0)
    {
      if (result.firstStruck == -1)
      {
        result.firstStruck = cueBallCollisions.get(0).number;
      }
      
      result.cueBallCollisions = cueBallCollisions.size();
      
      if (trackCollisionPoints)
      {
        state.cueBall.addCollisionPoint();
      }
    }
    
    // cue ball -> pocket collisions
    for (Pocket pocket : this.table.pockets)
    {
      if (state.cueBall.didCollide(pocket))
      {
        result.pottedCueBall = true;
      
        if (trackCollisionPoints)
        {
          state.cueBall.addCollisionPoint();
        }
      }
    }
    
    // cue ball -> bumper collisions
    for (Bumper bumper : this.table.bumpers)
    {
      if (state.cueBall.didCollide(bumper))
      {
        result.cueBallBumperCollisions++;
      
        if (trackCollisionPoints)
        {
          state.cueBall.addCollisionPoint();
        }
      }
    }
    
    // ball <-> ball collisions
    for (int i = 0; i < activeBalls.size(); i++)
    {
      Ball ball = activeBalls.get(i);
      for (int j = i + 1; j < activeBalls.size(); j++)
      {
        Ball other = activeBalls.get(j);
        if (ball.collide(other))
        {
          result.ballCollisions++;
          
          if (trackCollisionPoints)
          {
            ball.addCollisionPoint();
            other.addCollisionPoint();
          }
        }
      }
    }
    
    for (Ball ball : activeBalls)
    { 
      // ball -> bumper collisions
      for (Bumper bumper : this.table.bumpers)
      {
        if (ball.didCollide(bumper))
        {
          result.ballBumperCollisions++;
      
          if (trackCollisionPoints)
          {
            ball.addCollisionPoint();
          }
        }
      }
      
      // ball -> pocket collisions
      for (Pocket pocket : this.table.pockets)
      {
        if (ball.didCollide(pocket))
        {
          result.ballsPotted++;
      
          if (trackCollisionPoints)
          {
            ball.addCollisionPoint();
          }
        }
      }
    }
    
    return result;
  }
  
  Simulation.StepResult step()
  {
    Simulation.StepResult result = this.step(this.table.state, false);
    this.current.add(result);
    
    return result;
  }
  
  Simulation.Result run(Shot shot, boolean trackCollisionPoints)
  {
    TableState copiedState = this.table.state.copy();
    Simulation.Result result = new Simulation.Result(copiedState);
    
    int lowestBallNumber = this.table.state.getLowestBallNumber();
    
    copiedState.cueBall.applyForce(shot.angle, shot.force);
    copiedState.cueBall.addSpin(shot.sideSpin, shot.topSpin);
    
    for (int i = 0; i < MAX_ITER; i++)
    {
      result.add(this.step(copiedState, trackCollisionPoints, trackCollisionPoints ? i : -1));
      
      // todo: check for 9 ball
      if (result.firstStruck > 0 && result.firstStruck != lowestBallNumber)
      {
        result.hitFoulBall = true;
        break;
      }
      
      if (copiedState.allSettled())
      {
        break;
      }
    }
    
    return result;
  }
  
  void clearAimAssist()
  {
    if (this.lastSimulationKey == 0)
    {
      return;
    }
    
    this.lastSimulationKey = 0;
    
    this.table.state.cueBall.clearCollisionPoints();
    for (Ball ball : this.table.state.balls)
    {
      ball.clearCollisionPoints();
    }
  }
  
  void updateAimAssist(Shot shot)
  {
    if (this.lastSimulationKey == getKey(shot))
    {
      return;
    }
    
    this.clearAimAssist();
    
    Simulation.Result result = this.run(shot, true);
  
    // resting points
    result.state.cueBall.addCollisionPoint();
    for (Ball ball : result.state.balls)
    {
      ball.addCollisionPoint();
    }
    
    lastSimulationKey = getKey(shot);
  }
}

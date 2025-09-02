class TableState
{
  Ball cueBall;
  List<Ball> balls;
  Map<Integer, Ball> ballMap;
  
  TableState copy()
  {
    TableState newState = new TableState();
    newState.cueBall = this.cueBall.copy();
    newState.setBalls(this.balls.stream().map(ball -> ball.copy()).toList());
    return newState;
  }

  void setBalls(List<Ball> balls)
  {
    this.balls = balls;
    this.ballMap = new HashMap<>();
    for (Ball ball : balls)
    {
      this.ballMap.put(ball.number, ball);
    }
  }
  
  int getLowestBallNumber()
  {
    for (int i = 1; i < 15; i++)
    {
      if (this.ballMap.get(i) != null && !this.ballMap.get(i).sunk)
      {
        return i;
      }
    }
    
    return -1;
  }

  List<Ball> getActiveBalls()
  {
    return this.balls.stream().filter((ball) -> !ball.sunk).toList();
  }
  
  boolean allPotted()
  {
    return this.getActiveBalls().size() == 0;
  }
  
  boolean isGameOver()
  {
    if (this.ballMap.get(9) != null)
    {
      return this.allPotted() || this.ballMap.get(9).sunk;
    }
    return this.allPotted();
  }

  boolean allSettled(Ball cueBall, List<Ball> balls)
  {
    if (cueBall.isMoving())
    {
      return false;
    }
    
    return !balls.stream().anyMatch((ball) -> ball.isMoving());
  }
  
  boolean allSettled()
  {
    return this.allSettled(this.cueBall, this.balls);
  }
}

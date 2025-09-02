enum GameState
{
  PLAYER_SHOOT,
  AI_SHOOT,
  AI_READY,
  PLAYER_IN_PLAY,
  AI_IN_PLAY
}

class GameManager
{
  Table table;
  GameState state;
  GameMode mode = GameMode._9BALL;
  Simulation simulation;
  AI ai;
  Sounds sounds;
  
  GameManager(PApplet sketch)
  {
    this.table = new Table(this);
    this.simulation = new Simulation(this.table);
    this.ai = new AI(this.simulation);
    this.sounds = new Sounds(sketch);
  }
  
  void setup()
  {
    this.table.setup();
  }
  
  boolean mousePressed()
  {
    return this.table.mousePressed();
  }
  
  boolean is8Ball()
  {
    return this.mode == GameMode._8BALL;
  }
  
  boolean is9Ball()
  {
    return this.mode == GameMode._9BALL;
  }
  
  boolean isPlayerShooting()
  {
    return this.state == GameState.PLAYER_SHOOT;
  }
  
  boolean isInPlay()
  {
    return this.state == GameState.AI_IN_PLAY
      || this.state == GameState.PLAYER_IN_PLAY;
  }
  
  String getStatusText()
  {
    switch (this.state)
    {
      case PLAYER_SHOOT:
        return "Your turn";
      case AI_SHOOT:
        return "AI is thinking...";
      case AI_READY:
        return "Press F to shoot";
      case PLAYER_IN_PLAY:
      case AI_IN_PLAY:
        return "Playing...";
      default:
        return "???";
    }
  }
  
  void startGame()
  {
    this.simulation.reset();
    
    if (AI_ONLY)
    {
      this.state = GameState.AI_SHOOT;
      return;
    }
    
    this.state = GameState.PLAYER_SHOOT;
  }
  
  void start()
  {
    switch (GAME_TYPE)
    {
      case "debug":
        this.table.setupDebugGame();
        this.mode = GameMode._9BALL;
        break;
      case "8ball":
        this.table.setup8Ball();
        this.mode = GameMode._9BALL;
        break;
      default:
        this.table.setup9Ball();
        this.mode = GameMode._9BALL;
    }
    
    this.startGame();
  }
  
  boolean shouldSwitchTurn(Simulation.Result result)
  {
    return result.ballsPotted == 0 || result.hasFoul();
  }
  
  void playAIShot()
  {
    this.ai.shootLatest(this.table.state.cueBall);
    this.state = GameState.AI_IN_PLAY;
  }
  
  void updateState()
  {
    if (this.table.state.isGameOver())
    {
      this.start();
      return;
    }
    
    if (this.state == GameState.AI_IN_PLAY)
    {
      if (this.table.state.allSettled())
      {
        if (AI_ONLY)
        {
          this.simulation.reset();
          this.state = GameState.AI_SHOOT;
          return;
        }
        boolean switchTurn = this.shouldSwitchTurn(this.simulation.getResult());
        this.state = switchTurn ? GameState.PLAYER_SHOOT : GameState.AI_SHOOT;
        this.simulation.reset();
      }
      return;
    }
    
    if (this.state == GameState.PLAYER_IN_PLAY)
    {
      if (this.table.state.allSettled())
      {
        if (PLAYER_ONLY)
        {
          this.simulation.reset();
          this.state = GameState.PLAYER_SHOOT;
          return;
        }
        boolean switchTurn = this.shouldSwitchTurn(this.simulation.getResult());
        this.state = switchTurn ? GameState.AI_SHOOT : GameState.PLAYER_SHOOT;
        this.simulation.reset();
      }
      return;
    }
    
    if (this.state == GameState.AI_SHOOT)
    {
      Shot shot = this.ai.findShot();
      if (this.ai.waitAfterShot)
      {
        this.simulation.updateAimAssist(shot);
        this.state = GameState.AI_READY;
      }
      else
      {
        this.playAIShot();
      }
      return;
    }
  }
  
  void update()
  {
    this.updateState();
    
    if (this.isInPlay())
    {
      for (int i = 0; i < UPF; i++)
      {
        Simulation.StepResult result = this.simulation.step();
        if (result.hasBallCollision())
        {
          sounds.play("clack", 0.0);
        }
      }
    }
    
    if (this.state == GameState.PLAYER_SHOOT)
    {
      this.simulation.updateAimAssist(new Shot(
        this.table.cue.getAngle(),
        this.table.powerBar.getForce(),
        this.table.spinControl.getSideSpin(),
        this.table.spinControl.getTopSpin()
      ));
    }
    else if (this.isInPlay())
    {
      this.simulation.clearAimAssist();
    }
    
    this.table.cue.update();
  }
}

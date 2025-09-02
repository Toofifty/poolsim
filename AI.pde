class AI
{
  int precision = 100;
  int accuracy = 100;
  int prefTrickshot = 100;
  int prefMultishot = 100;
  
  boolean allowSideSpin = false;
  
  boolean waitAfterShot = false;
  
  private Simulation simulation;
  
  private float latestAngle = 0;
  private float latestForce = 0;
  private float latestSideSpin = 0;
  
  AI(Simulation simulation)
  {
    this.simulation = simulation;
    
    this.perfectPreset();
  }
  
  void perfectPreset()
  {
    this.precision = 100;
    this.accuracy = 100;
    this.prefTrickshot = 0;
    this.prefMultishot = 100;
  }
  
  void perfectTrickshotterPreset()
  {
    this.precision = 100;
    this.accuracy = 100;
    this.prefTrickshot = 100;
    this.prefMultishot = 100;
  }
  
  void allBrainsPreset()
  {
    this.precision = 100;
    this.accuracy = 10;
    this.prefTrickshot = 100;
    this.prefMultishot = 100;
  }
  
  void shoot(Ball cueBall, Shot shot)
  {
    cueBall.applyForce(shot.angle, shot.force);
    cueBall.addSpin(shot.sideSpin, shot.topSpin);
  }
  
  void shootLatest(Ball cueBall)
  {
    this.shoot(cueBall, new Shot(this.latestAngle, this.latestForce, this.latestSideSpin, 0));
  }
  
  void shoot(Ball cueBall)
  {
    Shot best = this.findShot();
    this.shoot(cueBall, best);
  }
  
  Shot findShot()
  {
    float steps = this.precision * 6;
    float step = TWO_PI / steps;
    
    float spinMax = MAX_SIDESPIN;
    float spinStep = spinMax / 5;
  
    float bestAngle = 0;
    float bestForce = 0;
    float bestSideSpin = 0;
    int bestScore = -Integer.MAX_VALUE;
    Simulation.Result bestResult = null;
    
    int iterations = 0;
    int stepIterations = 0;
    int start = millis();
    int anglesCulled = 0;
    int anglesChecked = 0;
    
    float minPower = this.allowSideSpin ? 4 : 1;
    float maxPower = this.allowSideSpin ? 5 : POWER_MAX;
    float powerStep = (maxPower - minPower) / 10;
    
    // todo: choose random when all shots culled
    
    for (float angle = -HALF_PI; angle < PI * 3 / 2; angle += step)
    {
      anglesChecked++;
      if (!this.allowSideSpin && this.simulation.shouldCullAngle(angle))
      {
        anglesCulled++;
        continue;
      }
      
      for (float force = minPower; force < maxPower; force += powerStep)
      {
        if (this.allowSideSpin)
        {
          for (float sideSpin = -spinMax; sideSpin <= spinMax; sideSpin += spinStep)
          {
            Simulation.Result result = this.simulation.run(new Shot(angle, force, sideSpin, 0), false);
            int score = this.score(result) - (int)force * 2;
            
            score += abs(sideSpin);
            
            if (score > bestScore)
            {
              bestAngle = angle;
              bestForce = force;
              bestSideSpin = sideSpin;
              bestScore = score;
              bestResult = result;
            }
            
            iterations++;
            stepIterations += result.stepIterations;
          }
        }
        else
        {
          Simulation.Result result = this.simulation.run(new Shot(angle, force), false);
          int score = this.score(result) - (int)force * 2;
          
          if (score > bestScore)
          {
            bestAngle = angle;
            bestForce = force;
            bestScore = score;
            bestResult = result;
          }
          
          iterations++;
          stepIterations += result.stepIterations;
        }
      }
    }
    
    if (random(100) > this.accuracy)
    {
      // +- 10 degrees
      //bestAngle += random(-10, 10) / 180;
      bestForce -= random(1);
    }
    
    println("AI best score: " + bestScore);
    println("Iterations: " + iterations + " steps: " + stepIterations);
    println("Angles culled: " + anglesCulled + "/" + anglesChecked);
    println("Time: " + (millis() - start) + "ms");
    println("angle: " + bestAngle + " force: " + bestForce + " sidespin: " + bestSideSpin);
    println(bestResult);
    
    this.latestAngle = bestAngle;
    this.latestForce = bestForce;
    this.latestSideSpin = bestSideSpin;
    
    return new Shot(bestAngle, bestForce, bestSideSpin, 0);
  }
  
  int score(Shot shot)
  {
    Simulation.Result result = this.simulation.run(shot, false);
    return this.score(result);
  }
  
  int score(Simulation.Result result)
  {
    int score = 0;
    
    score += result.ballsPotted * 100;
    
    int variance = (int)random(5);
    
    if (result.pottedCueBall)
    {
      score -= 1000;
    }
    
    if (result.hitFoulBall)
    {
      score -= 1000;
    }
    
    if (result.cueBallCollisions == 0)
    {
      score -= 1000;
    }
    
    float bumperMult = (this.prefTrickshot - 50) / 10;
    score += bumperMult * result.cueBallBumperCollisions;
    score += bumperMult * result.ballBumperCollisions;
    
    return score + variance;
  }
}

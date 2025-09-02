import java.util.Map;
import java.util.List;
import processing.sound.*;

/**

Ideas:
- Balls for AI to dodge
- UI stuff
- Potted ball display

- Sound variance
- Dont end until balls potted
- Animate cue
  - Plus AI cue
- Remove 3D toggle
- Rewrite physics sim

*/

GameManager game = new GameManager(this);

// shadow offset
final PVector S_OFF = new PVector(6, 10);
final float S_OPACITY = 64;

final int UPF = 3;

color BACKGROUND_COLOR = color(10, 16, 50);
color BUMPER_COLOR = color(5, 116, 0);
color EDGE_COLOR = color(90, 48, 25);
color TABLE_COLOR = color(2, 89, 0);

int POWER_MAX = 10;
boolean AI_ONLY = true;
boolean PLAYER_ONLY = false;

boolean ENABLE_3D = true;

boolean DARK_THEME = false;

// debug / 9ball / 8ball
String GAME_TYPE = "9ball";

void setup()
{
  size(2240, 1260, ENABLE_3D ? P3D : P2D);
  smooth(4);
  frameRate(165);
  ortho();
  
  game.setup();
  game.start();
  
  game.sounds.load();
}

void keyPressed()
{
  if (key == '8')
  {
    GAME_TYPE = "8ball";
    game.start();
  }
  else if (key == '9')
  {
    GAME_TYPE = "9ball";
    game.start();
  }
  else if (key == 'f')
  {
    game.playAIShot();
  }
  else if (key == 'd')
  {
    GAME_TYPE = "debug";
    game.start();
  }
  else if (key == 'c')
  {
    game.table.placeCueBall();
  }
}

void mousePressed()
{
  if (game.state != GameState.PLAYER_SHOOT)
  {
    return;
  }
  
  if (game.mousePressed())
  {
    return;
  }
  
  game.sounds.play("break");
  game.table.cue.shoot(game.table.powerBar.getForce());
  game.state = GameState.PLAYER_IN_PLAY;
}

void mouseWheel(MouseEvent event)
{
  game.table.powerBar.addValue(-event.getCount());
}

void draw()
{
  background(BACKGROUND_COLOR);
  game.update();
  
  if (game.table.state.cueBall.sunk && game.table.state.allSettled())
  {
    game.table.placeCueBall();
  }
  
  game.table.draw();
}

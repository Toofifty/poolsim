class Rack
{
  float gap = BALL_SIZE / 16;
  color[] colors = new color[16];
  
  Rack()
  {
    colors[1] = color(200, 200, 0);   // yellow
    colors[2] = color(0, 0, 255);     // blue
    colors[3] = color(255, 0, 0);     // red
    colors[4] = color(128, 0, 128);   // purple
    colors[5] = color(255, 165, 0);   // orange
    colors[6] = color(0, 128, 0);     // green
    colors[7] = color(128, 0, 0);     // brown
    colors[8] = color(0, 0, 0);       // black
    colors[9] = colors[1];   // stripes match solid colors
    colors[10] = colors[2];
    colors[11] = colors[3];
    colors[12] = colors[4];
    colors[13] = colors[5];
    colors[14] = colors[6];
    colors[15] = colors[7];
  }
  
  ArrayList<Ball> generate8Ball(float tipX, float tipY)
  {
    ArrayList<Ball> balls = new ArrayList<Ball>();

    final float step = BALL_SIZE + gap;
    final float rowOffset = step * sqrt(3) / 2.0f;
  
    // Official rack layout (numbers only)
    // Row-wise, tip-left orientation
    int[][] layout = {
      {1},                // Row 0
      {2, 3},             // Row 1
      {4, 8, 5},          // Row 2 (8-ball in center)
      {6, 7, 9, 10},      // Row 3
      {11, 12, 13, 14, 15} // Row 4
    };
  
    // Generate positions
    for (int row = 0; row < layout.length; row++)
    {
      int ballsInRow = layout[row].length;
  
      // y position: center vertically along row
      float yStart = tipY - (ballsInRow - 1) * step / 2.0f;
  
      for (int col = 0; col < ballsInRow; col++)
      {
        float x = tipX + row * rowOffset; // triangle grows rightwards
        float y = yStart + col * step;
  
        int number = layout[row][col];
        color c = colors[number];
  
        balls.add(new Ball(x, y, c, number));
      }
    }
  
    return balls;
  }
  
  ArrayList<Ball> generate9Ball(float tipX, float tipY)
  {
    ArrayList<Ball> balls = new ArrayList<Ball>();

    final float step = BALL_SIZE + gap;
    final float rowOffset = step * sqrt(3) / 2.0f;
  
    int[][] layout = {
      {1},
      {2, 3},
      {4, 9, 5},
      {6, 7},
      {8}
    };
  
    for (int row = 0; row < layout.length; row++)
    {
      int ballsInRow = layout[row].length;
      float yStart = tipY - (ballsInRow - 1) * step / 2.0f;
  
      for (int col = 0; col < ballsInRow; col++)
      {
        float x = tipX + row * rowOffset;
        float y = yStart + col * step;
  
        int number = layout[row][col];
        color c = colors[number];
  
        balls.add(new Ball(x + random(-gap, gap) / 2, y + random(-gap, gap) / 2, c, number));
      }
    }
  
    return balls;
  }
  
  ArrayList<Ball> generateDebugGame(float tipX, float tipY)
  {
    ArrayList<Ball> balls = new ArrayList<Ball>();
    
    balls.add(new Ball(tipX, tipY, this.colors[9], 9));
    
    return balls;
  }
}

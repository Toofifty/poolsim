class Sounds
{
  PApplet sketch;
  
  SoundFile clackSound;
  SoundFile breakSound;
  
  Sounds(PApplet sketch)
  {
    this.sketch = sketch;
  }
  
  void load()
  {
    this.clackSound = new SoundFile(this.sketch, "clack.wav");
    this.breakSound = new SoundFile(this.sketch, "break.wav");
  }
  
  SoundFile get(String soundName)
  {
    switch (soundName)
    {
      case "clack":
        return this.clackSound;
      case "break":
        return this.breakSound;
      default:
        return null;
    }
  }
  
  void playWithOffset(String soundName, SoundFile sound)
  {
    switch (soundName)
    {
      case "clack":
        sound.play();
        break;
      case "break":
        sound.jump(0.5);
        break;
    }
  }
  
  void reset(SoundFile sound)
  {
    sound.amp(1.0);
  }
  
  void play(String soundName)
  {
    SoundFile sound = this.get(soundName);
    this.playWithOffset(soundName, sound);
  }
  
  void play(String soundName, float amp)
  {
    SoundFile sound = this.get(soundName);
    sound.amp(amp);
    this.playWithOffset(soundName, sound);
    this.reset(sound);
  }
}

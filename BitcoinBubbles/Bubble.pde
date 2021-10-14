class Bubble {
  float bubbleX, bubbleY;
  String bubbleValue;
  
  float minVolume = 0.3;
  float maxVolume = 0.7;
  float volume;
  
  public color colour;
  
  private float bubbleScale;
  private double bubbleSpeed;
  private float pitch;


  // This is in no way, shape or form accurate. but it works.
  float minSpeed = 1.0;
  float maxSpeed = 6.0;
  float theLog = 2.52444;

  Bubble(float x, float y, double value){
    if(value<=0.01){
      bubbleValue = "<0.01";
    }
    else{
      bubbleValue = String.format("%.2f",value);
    }
    
    bubbleScale = constrain(100*(float)value/2,50.0,500.0);
    
    bubbleX = x;
    
    if(bubbleX - bubbleScale/2 <= 0){
      bubbleX = bubbleX + bubbleScale/2;
    }
    if(bubbleX + bubbleScale >= width){
      bubbleX = bubbleX - bubbleScale/2;
    }
    
    bubbleY = y;
    
    bubbleSpeed = Math.min(maxSpeed,Math.log(value+theLog) / Math.log(theLog));
    bubbleSpeed = constrain(abs( maxSpeed - (float)bubbleSpeed),0.1,5);
    
    volume = (float)value / (maxSpeed / (maxVolume - minVolume)) + minVolume;
      if (volume > maxVolume)
        volume = maxVolume;
        
    pitch = (float)Math.min(100,Math.log(value+1.0715307808111486871978099) / Math.log(1.0715307808111486871978099));
    pitch = 100 - pitch;

    
  }
  
  void draw(){
    fill(colour);
    circle(bubbleX,bubbleY,bubbleScale);
  }
  
  void drawText(){
    fill(255);
    textAlign(CENTER,CENTER);
    textSize(constrain((int)bubbleScale/8,12,100));
    text(bubbleValue + " BTC", bubbleX, bubbleY);
  }
  
  float returnVolume(){
    return volume;
  }
  
  float returnPitch(){
    return pitch;
  }
  
  void doBubbleThings(){
    bubbleY-=bubbleSpeed;
  }
  
  public boolean checkIfTimeToDie(){
    if(bubbleY<=0-bubbleScale/2){
      return true;
    }
    return false;
  }
}

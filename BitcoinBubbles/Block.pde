class Block {
  float blockY;
  String blockValue;
  
  Block(double value){
    blockY = height;
    blockValue = String.format("%.2f",value);
  }
  
  void draw(){
    rect(0,blockY,width,height/10);
  }
  
  void drawText(){
    textAlign(CENTER,CENTER);
    textSize(height/16);
    text(blockValue + " BTC", width/2, blockY + height/25);
  }
  
  void doBlockThings(){
    blockY-=1;
  }
  
  public boolean checkIfTimeToDie(){
    if(blockY<=0-height/10/2){
      return true;
    }
    return false;
  }
}

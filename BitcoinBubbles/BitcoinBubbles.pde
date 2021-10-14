import processing.sound.*;

SoundFile[] transactionSoundBubbleSounds;
SoundFile transactionSoundBubble;
WebsocketClient webSocket;

ArrayList<Bubble> bubbles = new ArrayList<Bubble>();
ArrayList<Block> blocks = new ArrayList<Block>();

void setup(){
 size(1000,1000); 
 
 // Initialise our sounds.
 transactionSoundBubbleSounds = new SoundFile[4];
 transactionSoundBubbleSounds[0] = new SoundFile(this,"celesta001.wav");
 transactionSoundBubbleSounds[1] = new SoundFile(this,"celesta002.wav");
 transactionSoundBubbleSounds[2] = new SoundFile(this,"celesta003.wav");
 transactionSoundBubbleSounds[3] = new SoundFile(this,"celesta004.wav");
 
 //Open a websocket connection with blockchain.info
 webSocket = new WebsocketClient(this,"wss://ws.blockchain.info/inv");
 
 //Ask the webhook to send us the data for unconfirmed transactions and blocks
 JSONObject json = new JSONObject();
 json.setString("op","unconfirmed_sub");
 webSocket.sendMessage(json.toString());
 json.setString("op","blocks_sub");
 webSocket.sendMessage(json.toString());
}

// This function is called every time the websocket sends us a message.
void webSocketEvent(String msg){
  
  //Try parse the data
  try{
    var parsedDataObject = parseJSONObject(msg);
    if(parsedDataObject==null) return;
    String operationType = parsedDataObject.getString("op");
    
    
    //If the operation is an unconfirmed transaction
    if(operationType.equals("utx")){
      
      JSONObject parsedData = parsedDataObject.getJSONObject("x");
      
      //Sum up the value of the satoshis (1/100mill)th of a bitcoin.
      JSONArray outputs = parsedData.getJSONArray("out");
      double value = 0;
      
      for (int outputCount = 0; outputCount<outputs.size(); outputCount++){
        JSONObject output = outputs.getJSONObject(outputCount);
        value += output.getFloat("value");
      }
      
      // Divide the value by 100 million to get the value in BTC.
      value/=100000000;
      
      //If the value is greater than 0, create a bubble.
      if(value>=0){
        Bubble newBubble = new Bubble(random(0,width),height,value);
        

        // Change the sound based on value.
        if(value<=0.02){
          newBubble.colour = color(255,214,255,128);
          return;
        }
        if(value>0.02){
          newBubble.colour = color(231,198,255,128);
          transactionSoundBubble = transactionSoundBubbleSounds[0];
        }
        if(value>1){
          newBubble.colour = color(200,182,255,128);
          transactionSoundBubble = transactionSoundBubbleSounds[1];
        }
        if(value>5){
          newBubble.colour = color(200, 182, 255,128);
          transactionSoundBubble = transactionSoundBubbleSounds[2];
        }
        if(value>100){
          newBubble.colour = color(187,208,255,128);
          transactionSoundBubble = transactionSoundBubbleSounds[3];
        }
        
        //Set the rate and volume of the bubble based on logarithsm+value
        transactionSoundBubble.rate(map(newBubble.returnPitch(),0,100,0.3,1));
        transactionSoundBubble.amp(newBubble.returnVolume());
        
        transactionSoundBubble.stop();
        transactionSoundBubble.play();
        
        println("New bubble: "+value+"BTC");
        println("Hash: "+parsedData.getString("hash"));
        
        bubbles.add(newBubble);
      }
    }
    
    
    //If a new block is found
    if(operationType.equals("block")){
      double value;
      JSONObject parsedData = parsedDataObject.getJSONObject("x");
      
      //println(parsedData.getFloat("estimatedBTCSent"));
      //println(parsedData.getFloat("totalBTCSent"));
      value = abs(parsedData.getFloat("estimatedBTCSent")/100000000);
      blocks.add(new Block(value));
    }
  }
  catch (Exception e){
    println(e);
  }
}

void draw(){
  background(153,193,222);
  
  //Create an array for bubbles/blocks to prevent concurrent access issues
  //(This can be improved, need to research more)
  Bubble[] bubbleArray = new Bubble[bubbles.size()];
  bubbleArray = bubbles.toArray(bubbleArray);
  
  Block[] blockArray = new Block[blocks.size()];
  blockArray = blocks.toArray(blockArray);
  
  noStroke();
  
  //For each bubble in the bubble array.
  for(Bubble bubble: bubbleArray){
    bubble.draw();
    bubble.drawText();
    bubble.doBubbleThings();
    
    if(bubble.checkIfTimeToDie()){
      bubbles.remove(bubble);
    }
  }
  
  for(Block block: blockArray){
    fill(0,255,255,128);
    block.draw();
    fill(255,255,255,180);
    block.drawText();
    block.doBlockThings();
    
    if(block.checkIfTimeToDie()){
      blocks.remove(block);
    }
  }
}

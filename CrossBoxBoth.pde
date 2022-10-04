import processing.serial.*;
import controlP5.*;

import cc.arduino.*;

Arduino arduinoSlider, arduinoButton;

ControlP5 cp5;


float sensorData =100 ; 


int myColor = color(0,0,0);

int sensorVal; 
int mapVal; 
int trianPos; 
int buttonData;

Table register;
int freq = 100;  // Frequency of recording = 10 Hz (once every 10 ms)

String pctimestamp; 
String timestamp ; 
boolean timeflag = false; 
int timer;

void setup() {
  size(800,800);
  noStroke();
 
  
  cp5 = new ControlP5(this);
  
  // create a toggle
  cp5.addButton("Record")
     .setPosition(100, 600)
     .setSize(80,20)
     ;  
  
  // create a toggle
  cp5.addButton("Save")
     .setPosition(200, 600)
     .setSize(80,20)
     ;  

  pctimestamp= str(year())+ '-' + str(month()) + '-' + str(day()) + '-' + str(hour()) + '-' + str(minute());
  
  register = new Table();
  
  register.addColumn("Timestamp");
  register.addColumn("Raw");
  register.addColumn("Value");
  register.addColumn("Button");
   
  // Prints out the available serial ports.
  println(Arduino.list());
  
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduinoSlider = new Arduino(this, Arduino.list()[2], 57600);
  arduinoButton = new Arduino(this, Arduino.list()[1], 57600);
  arduinoSlider.pinMode(0, Arduino.OUTPUT);
  arduinoButton.pinMode(0, Arduino.OUTPUT);
}

void draw() {
  background(0);
  
  textSize(14);
  fill(255);
  text("SLIDER POSITION", 100, 100); 
  
  fill(0,45,90);
  rect(100,200,500,25);
  
  
  sensorData = arduinoSlider.analogRead(0);
  mapVal= int(map(sensorData, 0, 1023, 0, 100));
  trianPos = int(map(sensorData, 0, 1023, 100, 600));
  buttonData = arduinoButton.digitalRead(2);

  fill(255);
  text("BUTTON STATUS", 100, 420); 

  pushMatrix();
  if(buttonData==0) {
      fill(255,255,220);
    } else {
      fill(128,128,110);
    }
  translate(250, 415);
  ellipse(0,0,30,30);
  popMatrix();
 
  fill(0,170,255);
  triangle(trianPos-5,225, trianPos+5, 225, trianPos, 200);
  println("Button data: "+ buttonData);
  println("Normalized value: "+ mapVal + "  Raw value: " + sensorData);

  if(timeflag == true){
    if (millis() - timer >= freq) {
        TableRow newRow = register.addRow();
        timestamp= str(year())+'-'+str(month())+'-'+str(day())+'-'+ str(hour())+'-'+str(minute())+'-'+str(second())+'-'+str(millis()); 
        newRow.setString("Timestamp", timestamp);
        newRow.setFloat("Raw", sensorData);
        newRow.setFloat("Value", mapVal);
        newRow.setFloat("Button", buttonData);
        
        timer = millis();
        
        textSize(10);
        fill(255);
        text("RECORDING DATA", 100, 700);       
    }
  }
}

public void Record() {
  println("Recording Started");  
  timeflag = true; 
  timer = millis();
}

public void Save( ) {
  println("Save File");
  
  timeflag=false; 
  
  timestamp= str(year())+'-'+str(month())+'-'+str(day())+'-'+ str(hour())+'-'+str(minute())+'-'+str(second()); 

  saveTable(register, "data/" + timestamp + ".csv");
  
  
  textSize(10);
  fill(255);
  text("FILE SAVED", 100, 700); 
  
  register.clearRows();
  delay(4000);

}

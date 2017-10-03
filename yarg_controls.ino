int initSv[] = {0, 0, 0, 0, 0, 0, 0, 0}; // stores initial sensor values
const int sensitivityVal = 100; // to compare (sensor value - initial value) to. greater value means less sensitive
const int delayVal = 20; // value to delay the loop by (in ms)

boolean isRed = false;
boolean isGreen = false;
boolean isBlue = false;
boolean isYellow = false;


void setup() {
  Serial.begin(19200); // NOT 9600. MAKE SURE TO CHANGE IN SERIAL MONITOR AND PROCESSING!
  getInitSensorVals(); // ensures that the initial values are captured as soon as you run/reset
}

void loop() {
  red();
  green();
  blue();
  yellow();
  sendInputs();
  delay(delayVal);
}

void getInitSensorVals() {
  // function to get the sensor values and store to the initial values array
  for (int i = 0; i <= 7; i++) {
    initSv[i] = analogRead(i);
  }
}

void red() {
  int r1 = (analogRead(0) - initSv[0]);
  int r2 = (analogRead(1) - initSv[1]);
  if (r1 >= sensitivityVal || r2 >= sensitivityVal) isRed = true;
  else isRed = false;
}

void green() {
  int g1 = (analogRead(2) - initSv[2]);
  int g2 = (analogRead(3) - initSv[3]);
  if (g1 >= sensitivityVal || g2 >= sensitivityVal) isGreen = true;
  else isGreen = false;
}

void blue() {
  int b1 = (analogRead(4) - initSv[4]);
  int b2 = (analogRead(5) - initSv[5]);
  if (b1 >= sensitivityVal || b2 >= sensitivityVal) isBlue = true;
  else isBlue = false;
}

void yellow() {
  int y1 = (analogRead(6) - initSv[6]);
  int y2 = (analogRead(7) - initSv[7]);
  if (y1 >= sensitivityVal || y2 >= sensitivityVal) isYellow = true;
  else isYellow = false;
}

void sendInputs(){
  if (isRed && !isGreen && !isBlue && !isYellow) Serial.write(1);       //r---
  else if (!isRed && isGreen && !isBlue && !isYellow) Serial.write(2);  //-g--
  else if (!isRed && !isGreen && isBlue && !isYellow) Serial.write(3);  //--b-
  else if (!isRed && !isGreen && !isBlue && isYellow) Serial.write(4);  //---y
  else if (isRed && isGreen && !isBlue && !isYellow) Serial.write(5);  //rg--
  else if (isRed && !isGreen && isBlue && !isYellow) Serial.write(6);  //r-b-
  else if (isRed && !isGreen && !isBlue && isYellow) Serial.write(7);  //r--y
  else if (!isRed && !isGreen && isBlue && isYellow) Serial.write(8);  //--by
  else if (!isRed && isGreen && !isBlue && isYellow) Serial.write(9);  //-g-y
  else if (isRed && isGreen && isBlue && !isYellow) Serial.write(10);  //rgb-
  else if (isRed && isGreen && !isBlue && isYellow) Serial.write(11);  //rg-y
  else if (isRed && !isGreen && isBlue && isYellow) Serial.write(12);  //r-by
  else if (!isRed && isGreen && isBlue && !isYellow) Serial.write(13);  //-gb-
  else if (!isRed && isGreen && isBlue && isYellow) Serial.write(14);  //-gby
  else if (isRed && isGreen && isBlue && isYellow) Serial.write(15);  //rgby
  else if (!isRed && !isGreen && !isBlue && !isYellow) Serial.write(0); //----
}


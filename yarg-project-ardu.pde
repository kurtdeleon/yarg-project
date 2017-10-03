import ddf.minim.*;
import processing.video.*;
import java.util.*;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import processing.serial.*;

/***** VARIABLES *****/

// The gameState variable determines which screen is active.
//
// 0: Main Menu
// 1: Song Selection
// 2: Game Screen
// 3: Scoreboard
// 4: Transition/s
// 5: Game Over

int gameState;
int songState;

// Alpha variable for animations.
int exitAlpha;
int beatAlpha;
boolean beatOn;

// Images to be used in the game.

PImage menubg; 
PImage results;
PImage pic1; 
PImage pic2; 
PImage pic3;

// Audio variables.

int songs = 3; 
int bgm = 3;
AudioPlayer[] player = new AudioPlayer[songs + bgm]; 
Minim minim; 
AudioSample beatpress;
AudioSample select; 
AudioSample enter;
AudioSample quit; 
AudioSample death;

//Beatmap variables.

PImage game1; 
PImage game2; 
PImage game3;
PImage r; 
PImage g; 
PImage b; 
PImage y;
PImage rankS; 
PImage rankA; 
PImage rankB;
PImage rankC; 
PImage rankD; 
PImage gameover;
boolean r_press; 
boolean g_press;
boolean b_press; 
boolean y_press;
int r_time; 
int g_time; 
int health;
int b_time; 
int y_time;
int score; 
float maxScore;
int combo; 
int max_combo;
int judge; 
boolean songEnd;
int startMillis; 
int perfect;
int good; 
int bad; 
int miss;
ArrayList<Float> rNotes;
ArrayList<Float> gNotes;
ArrayList<Float> bNotes;
ArrayList<Float> yNotes;
Float temp; 
Float speed;

//Other resources

PFont title; 
PrintWriter map1;
PrintWriter map2; 
PrintWriter map3;
boolean rPressed; 
boolean gPressed;
boolean bPressed; 
boolean yPressed;
boolean rHovered; 
boolean gHovered;
boolean bHovered; 
boolean yHovered;
boolean rightPressed; 
boolean leftPressed; 
String[] lines; 
String k; 
float v; 
Robot robot; 
Serial myPort; 
volatile int ardu;
String portName;

/***** SETUP *****/

void setup() {
  size(800, 800);
  surface.setResizable(false);
  frameRate(80);
  minim = new Minim(this);
  portName = Serial.list()[0]; // CEREAL PORT
  myPort = new Serial(this, portName, 19200);

  /** ROBOT **/

  try { 
    robot = new Robot();
    robot.setAutoDelay(2);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }

  /** BOOLEANS N STUFF */

  gameState = 0; 
  exitAlpha = 0;
  beatAlpha = 0; 
  beatOn = false;
  r_press = false; 
  r_time = 0;
  g_press = false; 
  g_time = 0;
  b_press = false; 
  b_time = 0;
  y_press = false; 
  y_time = 0;
  rPressed = false; 
  gPressed = false;
  bPressed = false; 
  yPressed = false;
  rHovered = false; 
  gHovered = false;
  bHovered = false; 
  yHovered = false;
  rightPressed = false;
  leftPressed = false;
  title = loadFont("The-2K12-84.vlw");
  combo = 0; 
  max_combo = 0; 
  score = 0; 
  judge = 0;
  perfect = 0; 
  good = 0;
  bad = 0; 
  miss = 0;
  songEnd = false;
  maxScore = 0.0;
  health = 0;

  /** SONGS + BGM **/
  player[0] = minim.loadFile("song1_gintama_ed17.mp3", 2048); //song # 1
  player[1] = minim.loadFile("song2_jojo_op7.mp3", 2048); //song # 2
  player[2] = minim.loadFile("song3_gintama_op7.mp3", 2048); //song # 3
  player[3] = minim.loadFile("marshmello_alone.mp3", 1024); //menu
  player[4] = minim.loadFile("byrne_miami.mp3", 1024); //results
  player[5] = minim.loadFile("thecitythatneversleeps.mp3", 1024); //gameover

  /** SOUND EFFECTS **/
  beatpress = minim.loadSample("beat.mp3", 128);
  select = minim.loadSample("select.mp3", 128);
  enter = minim.loadSample("enter.mp3", 128);
  quit = minim.loadSample("quit.mp3", 128);
  death = minim.loadSample("death.mp3", 128);

  /** PICTURES **/
  menubg = loadImage("menu.png");
  pic1 = loadImage("pic1_gintama_ed17.png");
  pic2 = loadImage("pic2_jojo_op7.png");
  pic3 = loadImage("pic3_gintama_op7.png");
  game1 = loadImage("game1_gintama_ed17.png");
  game2 = loadImage("game2_jojo_op7.png");
  game3 = loadImage("game3_gintama_op7.png");
  results = loadImage("results.png");
  r = loadImage("note_red.png");
  g = loadImage("note_green.png");
  b = loadImage("note_blue.png");
  y = loadImage("note_yellow.png");
  rankS = loadImage("rank_s.png");
  rankA = loadImage("rank_a.png");
  rankB = loadImage("rank_b.png");
  rankC = loadImage("rank_c.png");
  rankD = loadImage("rank_d.png");
  gameover = loadImage("gameover.png");
}

/***** DRAW *****/

void draw() {
  /** ARDUINO READER **/
  thread("readVal");
  //textFont(title, 84);
  //fill(255, 255, 255, 250);
  //text(ardu, 252, 600);
  readArduino();

  /** GAME STATES **/
  if (gameState == 0) {
    mainMenu();
  } else if (gameState == 1) {
    songSelection();
  } else if (gameState == 2) {
    gameScreen();
  } else if (gameState == 3) {
    scoreBoard();
  } else if (gameState == 4) {
    closeGame();
  } else if (gameState == 5) {
    gameOver();
  }
}

/***** SCREENS *****/

/** MAIN MENU **/

void mainMenu() {
  background(menubg);
  player[3].play();
  fill(200, 255, 255, beatAlpha);
  rect(0, 0, width, height);

  /** FLASHING ANIMATION **/
  if (beatAlpha == 60) {
    beatOn = false;
  } else if (beatAlpha == 0) {
    beatOn = true;
  } 
  if (beatOn) {
    beatAlpha += 5;
  } else {
    beatAlpha -= 2;
  }
}

/** SONG SELECTION **/

void songSelection() {
  background(0);
  player[songState].play();

  if (songState == 0) {
    image(pic1, 0, 0);
  } else if (songState == 1) {
    image(pic2, 0, 0);
  } else if (songState == (songs-1)) {
    image(pic3, 0, 0);
  }

  fill(200, 255, 255, beatAlpha);
  rect(0, 0, width, height);

  /** FLASHING ANIMATION **/
  if (beatAlpha == 20) {
    beatOn = false;
  } else if (beatAlpha == 0) {
    beatOn = true;
  } 
  if (beatOn) {
    beatAlpha += 2;
  } else {
    beatAlpha -= 1;
  }
}

/** GAME SCREEN **/

void gameScreen() {
  background(0);
  player[songState].play();
  if (songState == 0) {
    speed = 8.0;
    image(game1, 0, 0);
    if ((millis() - startMillis) >= 88*1000) {
      reset();
    }
  } else if (songState == 1) {
    speed = 8.9;
    image(game2, 0, 0);
    if ((millis() - startMillis) >= 87*1000) {
      reset();
    }
  } else if (songState == (songs-1)) {
    image(game3, 0, 0);
    speed = 9.5;
    if ((millis() - startMillis) >= 92*1000) {
      reset();
    }
  }

  /** NOTES **/
  for (int i = 0; i < rNotes.size(); i++) {
    temp = rNotes.get(i);
    image(r, 50, temp);
    rNotes.set(i, temp+speed);
  }
  for (int i = 0; i < gNotes.size(); i++) {
    temp = gNotes.get(i);
    image(g, 152, temp);
    gNotes.set(i, temp+speed);
  }
  for (int i = 0; i < bNotes.size(); i++) {
    temp = bNotes.get(i);
    image(b, 254, temp);
    bNotes.set(i, temp+speed);
  }
  for (int i = 0; i < yNotes.size(); i++) {
    temp = yNotes.get(i);
    image(y, 356, temp);
    yNotes.set(i, temp+speed);
  }

  /** CHECK MISS **/
  if (!rNotes.isEmpty()) {
    if (rNotes.get(0) > 801) {
      rNotes.remove(0);
      miss++;
      judge = 4;
      combo = 0;
      health += 20;
      if (health >= 800) {
        gameState = 5;
        death.trigger();
        beatAlpha = 0;
        clearAll();
        stopAll();
      }
    }
  }
  if (!gNotes.isEmpty()) {
    if (gNotes.get(0) > 801) {
      gNotes.remove(0);
      miss++;
      judge = 4;
      combo = 0;
      health += 20;
      if (health >= 800) {
        gameState = 5;
        death.trigger();
        clearAll();
        stopAll();
        beatAlpha = 0;
      }
    }
  }
  if (!bNotes.isEmpty()) {
    if (bNotes.get(0) > 801) {
      bNotes.remove(0);
      miss++;
      judge = 4;
      combo = 0;
      health += 20;
      if (health >= 800) {
        gameState = 5;
        death.trigger();
        clearAll();
        stopAll();
        beatAlpha = 0;
      }
    }
  }
  if (!yNotes.isEmpty()) {
    if (yNotes.get(0) > 801) {
      yNotes.remove(0);
      miss++;
      judge = 4;
      combo = 0;
      health += 20;
      if (health >= 800) {
        gameState = 5;
        death.trigger();
        clearAll();
        stopAll();
        beatAlpha = 0;
      }
    }
  }

  /** HEALTH BAR **/
  fill(255, 255, 255, 200);
  rect(458, health, 30, height);

  /** JUDGE **/
  textFont(title, 56);
  if (judge == 1) {
    fill(90, 99, 231, 200);
    text("PERFECT", 252, 352);
  } else if (judge == 2) {
    fill(97, 243, 92, 200);
    text("GOOD", 252, 352);
  } else if (judge == 3) {
    fill(254, 13, 73, 200);
    text("BAD", 252, 352);
  } else if (judge == 4) {
    fill(181, 157, 163, 200);
    text("MISS", 252, 352);
  }

  /** SCORES AND COMBOS**/
  if (combo >= max_combo) {
    max_combo = combo;
  } 

  textFont(title, 84);
  fill(255, 255, 255);
  textAlign(CENTER);
  text(combo, 651, 480); //combo
  text(max_combo, 651, 632); //maxcombo
  textFont(title, 48);
  text(score, 651, 755); //score

  /** RGBY COLORS ON TRACKS **/
  if (r_press) {
    if (r_time == 0) {
      r_press = false;
    } else {
      fill(225, 28, 28, 80);
      rect(50, 0, 99, height);
      r_time--;
    }
  } 
  if (g_press) {
    if (g_time == 0) {
      g_press = false;
    } else {
      fill(67, 232, 38, 80);
      rect(152, 0, 99, height);
      g_time--;
    }
  } 
  if (b_press) {
    if (b_time == 0) {
      b_press = false;
    } else {
      fill(71, 68, 239, 80);
      rect(254, 0, 99, height);
      b_time--;
    }
  } 
  if (y_press) {
    if (y_time == 0) {
      y_press = false;
    } else {
      fill(255, 255, 0, 80);
      rect(356, 0, 99, height);
      y_time--;
    }
  }
}

/** SCORE BOARD **/

void scoreBoard() {
  songEnd = true;
  player[4].play();
  image(results, 0, 0);

  /** SCORES AND COMBOS**/
  textFont(title, 64);
  fill(255, 255, 255);
  textAlign(LEFT);
  text(max_combo, 523, 293); //max_combo
  text(perfect, 523, 343); //perfect
  text(good, 523, 392); //good
  text(bad, 523, 440); //bad
  text(miss, 523, 487); //miss
  textFont(title, 60); 
  textAlign(CENTER);
  text(score, 534, 587); //score

  /** RANKS **/
  if (score >= (maxScore*.95)) {
    image(rankS, 168, 355);
  } else if (score >= (maxScore*.90) && score < (maxScore*.95)) {
    image(rankA, 138, 355);
  } else if (score >= (maxScore*.84) && score < (maxScore*.90)) {
    image(rankB, 168, 355);
  } else if (score >= (maxScore*.78) && score < (maxScore*.84)) {
    image(rankC, 154, 355);
  } else if (score < (maxScore*.78)) {
    image(rankD, 134, 355);
  }

  /** FLASH ANIMATIONS **/
  fill(200, 255, 255, beatAlpha);
  rect(0, 0, width, height);
  if (beatAlpha == 40) {
    beatOn = false;
  } else if (beatAlpha == 0) {
    beatOn = true;
  } 
  if (beatOn) {
    beatAlpha += 4;
  } else {
    beatAlpha -= 2;
  }
}

void closeGame() {
  fill(0, 0, 0, exitAlpha);
  rect(0, 0, width, height);
  if (exitAlpha < 260) {
    exitAlpha += 5;
  } else {
    exit();
  }
}

void gameOver() {
  player[5].play();
  image(gameover, 0, 0);
  /** FLASH ANIMATIONS **/
  fill(200, 0, 0, beatAlpha);
  rect(0, 0, width, height);
  if (beatAlpha == 40) {
    beatOn = false;
  } else if (beatAlpha == 0) {
    beatOn = true;
  } 
  if (beatOn) {
    beatAlpha += 4;
  } else {
    beatAlpha -= 2;
  }
}

/***** KEYS *****/

void keyPressed() {
  /** QUIT BUTTON **/
  if (key == 'Q') {
    stopAll();
    quit.trigger();
    gameState = 4;
  }

  /** PLAY BUTTON **/
  if (gameState == 0) {
    if (key == 'X') {
      delay(400);
      stopAll();
      delay(100);
      enter.trigger();
      beatAlpha = 0;
      beatOn = false;
      gameState = 1;
    }
  }

  /** SONG SELECTION **/
  else if (gameState == 1) {
    if (key == 'W') {
      stopAll();
      enter.trigger();
      startMillis = millis();
      buildNotes();
      gameState = 2;
    } else {
      if (key == 'D' && !rightPressed) {
        stopAll();
        select.trigger();
        if (songState == (songs-1)) {
          songState = 0;
        } else {
          songState++;
        }
        rightPressed = true;
      } else if (key == 'A' && !leftPressed) {
        stopAll();
        select.trigger();
        if (songState == 0) {
          songState = (songs-1);
        } else {
          songState--;
        }
        leftPressed = true;
      }
    }
  }

  /** GAME SCREEN **/
  if (gameState == 2) {
    /** RED **/
    if (key == 'U' && !rPressed) {
      beatpress.trigger();
      r_press = true;
      r_time = 7;
      judge("r");
      rPressed = true;
    }
    /** GREEN **/
    if (key == 'I' && !gPressed) {
      beatpress.trigger();
      g_press = true;
      g_time = 7;
      judge("g");
      gPressed = true;
    }
    /** BLUE **/
    if (key == 'O' && !bPressed) {
      beatpress.trigger();
      b_press = true;
      b_time = 7;
      judge("b");
      bPressed = true;
    }
    /** YELLOW **/
    if (key == 'P' && !yPressed) {
      beatpress.trigger();
      y_press = true;
      y_time = 7;
      judge("y");
      yPressed = true;
    }
  }

  /** SCORE BOARD **/
  if ((gameState == 3 && songEnd) || gameState == 5) {
    stopAll();
    clearAll();
    songState = 0;
    beatAlpha = 0;
    gameState = 1;
    songEnd = false;
    enter.trigger();
  }
}

void keyReleased() {
  /** SONG SELECTION **/
  if (gameState == 1) {
    if (key == 'D' && rightPressed) {
      rightPressed = false;
    } else if (key == 'A' && leftPressed) {
      leftPressed = false;
    }
  }

  /** GAME SCREEN **/
  if (gameState == 2) {
    /** RED **/
    if (key == 'U' && rPressed) {
      rPressed = false;
    }
    /** GREEN **/
    if (key == 'I' && gPressed) {
      gPressed = false;
    }
    /** BLUE **/
    if (key == 'O' && bPressed) {
      bPressed = false;
    }
    /** YELLOW **/
    if (key == 'P' && yPressed) {
      yPressed = false;
    }
  }
}


/***** FUNCTIONS *****/

void stopAll() {
  for (int i = 0; i < player.length; i++) {
    if (player[i].isPlaying()) {
      player[i].rewind();
      player[i].pause();
    } else {
      continue;
    }
  }
}

void clearAll() {
  perfect = 0;
  good = 0;
  bad = 0;
  miss = 0;
  combo = 0;
  max_combo = 0;
  score = 0;
  maxScore = 0.0;
  health = 0;
  judge = 0;
}

void reset() {
  stopAll();
  beatAlpha = 0;
  gameState = 3;
  startMillis = 0;
}

void buildNotes() {
  rNotes = new ArrayList<Float>(); 
  gNotes = new ArrayList<Float>();  
  bNotes = new ArrayList<Float>(); 
  yNotes = new ArrayList<Float>(); 

  if (songState == 0) {
    lines = loadStrings("map1.txt");
  } else if (songState == 1) {
    lines = loadStrings("map2.txt");
  } else if (songState == (songs-1)) {
    lines = loadStrings("map3.txt");
  }

  for (int i = 0; i < lines.length; i++) {
    String[] parts = lines[i].split(" ");
    k = parts[0];
    if (songState == 0){
      v = Float.parseFloat(parts[1])*-10.4;
    } else if (songState == 1){
      v = (Float.parseFloat(parts[1])*-9)+800;
    } else if (songState == (songs-1)){
      v = (Float.parseFloat(parts[1])*-9.5)+750;
    }
    if (k.equals("r")) {
      rNotes.add(v);
    } else if (k.equals("g")) {
      gNotes.add(v);
    } else if (k.equals("b")) {
      bNotes.add(v);
    } else if (k.equals("y")) {
      yNotes.add(v);
    }
  }
  maxScore = (rNotes.size() + gNotes.size() + bNotes.size() + yNotes.size()) * 500;
}

void judge(String a) {
  if (a.equals("r")) {
    if (!rNotes.isEmpty()) {
      float x = rNotes.get(0);
      if ((x>=607 && x<655) || (x>=775 && x<801)) {
        rNotes.remove(0);
        bad++;
        score += 50;
        combo = 0;
        judge = 3;
        health += 6;
        if (health >= 800) {
          gameState = 5;
          death.trigger();
          clearAll();
          stopAll();
          beatAlpha = 0;
        }
      } else if ((x>=655 && x<675) || (x>=740 && x<755)) {
        rNotes.remove(0);
        good++;
        score += 350;
        combo++;
        judge = 2;
        health -= 6;
        if (health <= 0) {
          health = 0;
        }
      } else if (x>=675 && x<740) {
        rNotes.remove(0);
        perfect++;
        score += 500;
        combo++;
        judge = 1;
        health -= 10;
        if (health <= 0) {
          health = 0;
        }
      }
    }
  } else if (a.equals("g")) {
    if (!gNotes.isEmpty()) {
      float x = gNotes.get(0);
      if ((x>=607 && x<655) || (x>=775 && x<801)) {
        gNotes.remove(0);
        bad++;
        score += 50;
        combo = 0;
        judge = 3;
        health += 6;
        if (health >= 800) {
          gameState = 5;
          death.trigger();
          clearAll();
          stopAll();
          beatAlpha = 0;
        }
      } else if ((x>=655 && x<675) || (x>=740 && x<755)) {
        gNotes.remove(0);
        good++;
        score += 350;
        combo++;
        judge = 2;
        health -= 6;
        if (health <= 0) {
          health = 0;
        }
      } else if (x>=675 && x<740) {
        gNotes.remove(0);
        perfect++;
        score += 500;
        combo++;
        judge = 1;
        health -= 10;
        if (health <= 0) {
          health = 0;
        }
      }
    }
  } else if (a.equals("b")) {
    if (!bNotes.isEmpty()) {
      float x = bNotes.get(0);
      if ((x>=607 && x<655) || (x>=775 && x<801)) {
        bNotes.remove(0);
        bad++;
        score += 50;
        combo = 0;
        judge = 3;
        health += 6;
        if (health >= 800) {
          gameState = 5;
          death.trigger();
          clearAll();
          stopAll();
          beatAlpha = 0;
        }
      } else if ((x>=655 && x<675) || (x>=740 && x<755)) {
        bNotes.remove(0);
        good++;
        score += 350;
        combo++;
        judge = 2;
        health -= 6;
        if (health <= 0) {
          health = 0;
        }
      } else if (x>=675 && x<740) {
        bNotes.remove(0);
        perfect++;
        score += 500;
        combo++;
        judge = 1;
        health -= 10;
        if (health <= 0) {
          health = 0;
        }
      }
    }
  } else if (a.equals("y")) {
    if (!yNotes.isEmpty()) {
      float x = yNotes.get(0);
      if ((x>=607 && x<655) || (x>=775 && x<801)) {
        yNotes.remove(0);
        bad++;
        score += 50;
        combo = 0;
        judge = 3;
        health += 6;
        if (health >= 800) {
          gameState = 5;
          death.trigger();
          clearAll();
          stopAll();
          beatAlpha = 0;
        }
      } else if ((x>=655 && x<675) || (x>=740 && x<755)) {
        yNotes.remove(0);
        good++;
        score += 350;
        combo++;
        judge = 2;
        health -= 6;
        if (health <= 0) {
          health = 0;
        }
      } else if (x>=675 && x<740) {
        yNotes.remove(0);
        perfect++;
        score += 500;
        combo++;
        judge = 1;
        health -= 10;
        if (health <= 0) {
          health = 0;
        }
      }
    }
  }
}

void readArduino() {
  if (gameState == 0 && ardu > 0) {
    robot.keyPress(KeyEvent.VK_X);
    robot.keyRelease(KeyEvent.VK_X);
  } else if ((gameState == 3 || gameState == 5) && ardu > 0) {
    robot.keyPress(KeyEvent.VK_S);
    robot.keyRelease(KeyEvent.VK_S);
  } else if (gameState == 1) {
    if (ardu == 0) { //----
      buttonPresser2(0, 0);
    } else if (ardu == 1) { //left
      buttonPresser2(1, 0);
    } else if (ardu == 2 || ardu == 3 || ardu == 13) {
      delay(400);
      robot.keyPress(KeyEvent.VK_W);
      robot.keyRelease(KeyEvent.VK_W);
    } else if (ardu == 4) { //right
      buttonPresser2(0, 1);
    }
  } else if (gameState == 2) {
    if (ardu == 0) { //----
      buttonPresser(0, 0, 0, 0);
    } else if (ardu == 1) { //r---
      buttonPresser(1, 0, 0, 0);
    } else if (ardu == 2) { //-g--
      buttonPresser(0, 1, 0, 0);
    } else if (ardu == 3) { //--b-
      buttonPresser(0, 0, 1, 0);
    } else if (ardu == 4) { //---y
      buttonPresser(0, 0, 0, 1);
    } else if (ardu == 5) { //rg--
      buttonPresser(1, 1, 0, 0);
    } else if (ardu == 6) { //r-b-
      buttonPresser(1, 0, 1, 0);
    } else if (ardu == 7) { //r--y
      buttonPresser(1, 0, 0, 1);
    } else if (ardu == 8) { //--by
      buttonPresser(0, 0, 1, 1);
    } else if (ardu == 9) { //-g-y
      buttonPresser(0, 1, 0, 1);
    } else if (ardu == 10) { //rgb-
      buttonPresser(1, 1, 1, 0);
    } else if (ardu == 11) { //rg-y
      buttonPresser(1, 1, 0, 1);
    } else if (ardu == 12) { //r-by
      buttonPresser(1, 0, 1, 1);
    } else if (ardu == 13) { //-gb-
      buttonPresser(0, 1, 1, 0);
    } else if (ardu == 14) { //-gby
      buttonPresser(0, 1, 1, 1);
    } else if (ardu == 15) { //rgby
      buttonPresser(1, 1, 1, 1);
    }
  }
}

void readVal() {
  if (myPort.available() > 0) {
    ardu = myPort.read();
  }
}

void buttonPresser(int u, int i, int o, int p) {
  if (u == 1) {
    robot.keyPress(KeyEvent.VK_U);
  } else {
    robot.keyRelease(KeyEvent.VK_U);
  }

  if (i == 1) {
    robot.keyPress(KeyEvent.VK_I);
  } else {
    robot.keyRelease(KeyEvent.VK_I);
  }

  if (o == 1) {
    robot.keyPress(KeyEvent.VK_O);
  } else {
    robot.keyRelease(KeyEvent.VK_O);
  }

  if (p == 1) {
    robot.keyPress(KeyEvent.VK_P);
  } else {
    robot.keyRelease(KeyEvent.VK_P);
  }
}

void buttonPresser2(int a, int d) {
  if (a == 1) {
    robot.keyPress(KeyEvent.VK_A);
  } else {
    robot.keyRelease(KeyEvent.VK_A);
  }

  if (d == 1) {
    robot.keyPress(KeyEvent.VK_D);
  } else {
    robot.keyRelease(KeyEvent.VK_D);
  }
}
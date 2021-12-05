//Concept:
//A fun point and click game where the batter needs to hit all baseballs in the fastest time!

//Instructions:
//Move the bat over the baseballs with the mouse and click to hit them out of the park! Hit all of them to finish!

//Sources:
//All sprites are original creations made with Piskel App (https://www.piskelapp.com/)
//Background image: https://www.insidenova.com/sports/prince_william/pitching-in-how-volunteers-built-potomac-s-baseball-field/article_bca380f0-610f-11e9-b82f-03ca30d198c5.html

import processing.sound.*; //Imports Processing's sound library
import java.io.PrintStream; //Imports Java's PrintStream library
import java.util.*; //Imports Java's utilities library, for Queue data structure

PImage field; //Variable for image of field (background)
PImage[] bat = new PImage[4]; //Array to store frames of baseball bat sprite
int batFrame = 0; //Variable to keep track of index for bat frames
PImage[] baseball = new PImage[5]; //Array to store frames of baseball sprite
int[][] baseballFrames = new int[9][7]; //2D array to keep track of all frame indexes for all balls
int frameRater; //Variable to keep track of system time for framerate comparison
boolean swing = false; //Boolean for baseball bat swinging state
boolean hit = false; //Boolean for baseball hit state
Queue<int[]> mouseClicks = new LinkedList<int[]>(); //Queue to manage coordinates of incoming mouse clicks
int clickX; //Variable to store current mouse click's x-coordinate
int clickY; //Variable to store current mouse click's y-coordinate
SoundFile missSound; //SoundFile to store the sound effect for missed swings
SoundFile hitSound; //SoundFile to store effect for hit balls
boolean playSound = false; //Boolean for sound state
boolean started = false; //Boolean for game state
int balls = 9 * 7; //Variable to keep track of current # of balls

void setup() {
  //This method will make the console disregard unnecessary INFO messages
  System.setErr(new PrintStream(new OutputStream() {
    public void write(int b) {
    }
  }));
  size(1000, 800); //Sets the size of the screen to be 1000x800 pixels
  fill(0); //Sets the fill colour to black
  textSize(50); //Sets the text size to 50 pixels
  imageMode(CENTER); //Sets rendered images to be centered relative to the specified render coordinates
  rectMode(CENTER); //Sets rendered rectangles to be centered relative to the specified width/height values
  field = loadImage("data/field.jpg"); //Loads the background image (a baseball diamond, from batter's perspective)
  //Loads each frame of the baseball bat sprite into the array
  for (int i = 0; i < bat.length; i++)
    bat[i] = loadImage("data/Baseball Bat/bat_" + i + ".png");
  //Loads each frame of the baseball sprite into the array
  for (int i = 0; i < baseball.length; i++)
    baseball[i] = loadImage("data/Baseball/baseball_" + i + ".png");
  missSound = new SoundFile(this, "data/miss.wav"); //Loads the sound effect for missed swings
  hitSound = new SoundFile(this, "data/hit.wav"); //Loads the sound effect for hit swings
  frameRater = millis(); //Stores the current system time in milliseconds
}

void draw() {
  image(field, width / 2, height / 2); //Draws the background, centered

  //If the mouse click queue is not empty, store the latest coordinate values
  if (!mouseClicks.isEmpty()) {
    clickX = mouseClicks.peek()[0];
    clickY = mouseClicks.remove()[1];
  }

  //For each ball frame in the array...
  for (int i = 0; i < baseballFrames.length; i++) {
    for (int j = 0; j < baseballFrames[i].length; j++) {
      //Draws the ball with the current frame specified by the array, at the corresponding grid location, scaled according to its time in motion to simulate distance
      image(baseball[baseballFrames[i][j] % 5], i* 100 + 95, j * 100 + 75, baseball[0].width * (1 - baseballFrames[i][j] / 100.0), baseball[0].height * (1 - baseballFrames[i][j] / 100.0));
      //Checks if the latest mouse click is in the region of any ball on screen
      if (baseballFrames[i][j] == 0 && clickX <= (i * 100 + 95) + (baseball[0].width / 2) && clickX >= (i * 100 + 95) - (baseball[0].width / 2) && 
        clickY <= (j * 100 + 75) + (baseball[0].height / 2) && clickY >= (j * 100 + 75) - (baseball[0].height / 2)) {
        baseballFrames[i][j] = 1; //Changes the specific baseball's idle frame to the next (movement starts)
        balls--; //Decrements the current ball value
        clickX = -1; //Resets the current mouse click's x-coordinate
        clickY = -1; //Resets the current mouse click's y-coordinate
        hit = true; //Tells the program a ball was hit for appropriate sound
      }
    }
  }

  //Checks if it is time to play a sound
  if (playSound) {
    //Checks if a ball was just hit
    if (hit) {
      hitSound.play(); //Plays the hit sound effect
      hit = false; //Resets the hit state
    } else
      missSound.play(); //Plays the miss sound effect

    playSound = false; //Does not allow the program to play overlapping sound effects
  }

  image(bat[batFrame], mouseX + 75, mouseY); //Draws the bat sprite in its current frame at the mouse's position

  updateFrames(); //Updates each sprite's frames in a separate method

  //If the game is started and there are still baseballs on the screen
  if (started && balls != 0) {
    textAlign(LEFT); //Aligns the text to the left of the text box
    text(millis() / 1000 + "." + millis() % 1000 + "s", 10, height - 10); //Displays a timer in the bottom left
    textAlign(RIGHT); //Aligns the text to the right of the text box
    text(balls + "/63", width - 10, height - 10); //Displays the current number of balls in the bottom right
  //If there are no more balls on the screen
  } else if (balls == 0) {
    textAlign(CENTER, CENTER); //Aligns the text to the center (vert. and horz.) of the text box
    textSize(75); //Sets the size of text to be 75 pixels (a bit bigger than bottom stats)
    fill(255); //Sets the fill colour to white
    //Tells the player their final time
    text("Congrats! Your time was: " + millis() / 1000 + "." + millis() % 1000 + "s!", width / 2, height / 2 - 20, width - 20, height);
    noLoop(); //Stops the draw() loop and the game
  }
}

//Separate custom function to update sprite frames
void updateFrames() {
  //Compares the amount of time that has past since last frame
  //Only updates sprite frames at a rate of 24 frames per second
  if (millis() - frameRater > (1000 / 24)) {
    //If the bat is currently swinging
    if (swing)
      //If the bat is not at its last swing frame
      if (batFrame < 3) {
        batFrame++; //Go to the next frame
      } else {
        batFrame = 0; //Resets the bat animation
        swing = false; //Tells the program the bat is done swinging
      }
    //For every ball frame index in the 2D array...
    for (int i = 0; i < baseballFrames.length; i++) {
      for (int j = 0; j < baseballFrames[i].length; j++) {
        //Checks if the ball animation is started or about to finish
        if (baseballFrames[i][j] > 0 && baseballFrames[i][j] < 100) {
          baseballFrames[i][j] += 3; //Increments the frame index by 3 (used in downscale of image and frame access)
        }
      }
    }
    frameRater = millis(); //Updates the current system time in milliseconds
  }
}

//Built-in function to concurrently check for mouse presses
void mousePressed() {
  //If the bat is not currently swinging
  if (!swing) {
    int[] mousePos = {mouseX, mouseY}; //Store mouse press coordinates in array
    mouseClicks.add(mousePos); //Add array to mouse click queue
    swing = true; //Tells the program the bat is now swinging
    playSound = true; //Tells the program it is okay to play one sound
    //Checks if the game is already considered to be running
    if (!started)
      started = true; //Updates the game state to be considered running
  }
}

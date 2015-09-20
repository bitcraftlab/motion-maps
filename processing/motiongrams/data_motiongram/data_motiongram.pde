
///////////////////////////////////////////////////////////////
//                                                           //
//     D A T A    M O T I O N G R A M   E X P L O R E R      //
//                                                           //
///////////////////////////////////////////////////////////////

// This is an exploration in using Motiongrams (dense graphical notations of motion)
// It downloads videos and tracking data from the MotionBank database

// This sketch was created during the 5th Choreographic Coding Lab in LA, 2015.
// (c) bitcraftlab 2015

import java.util.Properties;
import java.util.Date;

import org.piecemaker2.api.*;
import org.piecemaker2.models.*;

import processing.video.*;

// Access the API
PieceMakerApi api;

// Events for Callbacks
org.piecemaker2.models.Event videoEvent;
org.piecemaker2.models.Event dataEvent;

// Data is a 3D-Array of measurements (Frame, Channel, Track)

// - Each frame corresponds to one tick in time,
// - The trajectory of each dancer is contained in a channel that contains several tracks.
// - There is one track for each coordinate (x-coordinate, y-coordinate)

float[][][] data;
float[][][] motiongram;

Movie video;
boolean paused = false;

// length of each trail
int trailSize = 200;

// Ringbuffer of trails, containing previous values (Frame, Channel, Track)
int trailIndex = 0;
int channels;
int framenum;

boolean loaded = false;

float inMarker;
float outMarker;
float pauseMarker;

// window dimensions
int width, height; 
int frame;

// diameter of the canvas
int dmap; 

// gap around canvas and video
int gap = 15;
int gap2 = 0;
int speed = 1;

int barHeight = 40;
int barHeight2 = 10;
int barWidth;
int barsHeight;

int bars;

int hoverChannel;

color hiColor = color(255, 0, 0);
color hiColor2 = color(255);
color outlineColor = color(63);

boolean colorMode;

char motiongramType = 'x';

void setup () {

  // get video from the server if it's not in the data folder yet ...
  get_video(videoServer, videoTitle);

  // get channels + tracks from the server, in case they are not in the data folder yet.
  get_data();

  // one bar for each channel
  bars = channels;

  // set markers
  inMarker = startTime;
  outMarker = endTime;

  // adjust window and canvas dimensions to the video size

    barsHeight = barHeight2 + gap2 * (bars - 1);
  height = videoHeight + gap * 4 + barHeight + bars * barsHeight;
  dmap = videoHeight;
  width = videoWidth + 3 * gap + dmap;

  // adjust bars to video size
  barWidth = videoWidth + gap + dmap;

  // create window
  size(width, height);

  // let the video trigger the redraw
  noLoop();
}



void draw () {

  // pulsate color, to stand out more ...
  // hiColor = lerpColor(hiColor1, hiColor2, sin(frameCount * TWO_PI * 0.05 ));

  if (loaded) {

    background(255);
    image(video, gap, gap);
    markVideo();

    // draw canvas

    pushMatrix();
    translate(gap + videoWidth + gap, gap);

    fill(200); 
    noStroke();
    rect(0, 0, dmap, dmap);

    drawTrails();
    drawDancers();

    popMatrix();

    // draw GUI


    pushMatrix();


    translate(gap, gap2);

    translate(0, 2 * gap + videoHeight);
    drawProgressBar();
    translate(0, barHeight);


    // draw the motionGrams
    translate(0, gap);
    for (int i = 0; i < bars; i++) {
      pushMatrix();
      translate(0, i * (barHeight2 + gap2));
      drawMotiongram(i);
      popMatrix();
    }

    // motion gram progress bar
    int w = 5;
    int h = bars * (barHeight2 + gap2) + gap2;
    int x = spaceMap(video.time());
    stroke(255);
    rect(x - w, -1, 2 * w, h + 2);

    popMatrix();

    // hilight the hovered channel
    mouseOverMotiongrams();

    // loop inside the limit
    if (video.time() < inMarker || video.time() > outMarker) {
      video.jump(inMarker);
    }

    // pause hack
    if (paused) {
      video.jump(pauseMarker);
    }
  } else {

    // indicate that the video is still loading
    background( #994433 );
  }
}


void movieEvent ( Movie mov ) {

  video.read();

  // increase frame counter
  frame = int( (video.time() - eventTimeOffset) * 25.0 );

  redraw();
}


void drawDancers() {

  noStroke();

  for (int j = 0; j < channels; j++) {
    fill(j == hoverChannel ? hiColor : 0, 100);
    float x = mapX(data[frame][j][0]);
    float z = mapZ(data[frame][j][2]); 
    ellipse(x, z, 12, 12);
  }
}


void markVideo() {

  fill(255, 100);
  strokeWeight(3);

  for (int j = 0; j < channels; j++) {

    float x = data[frame][j][0];
    float y = data[frame][j][1];
    float z = data[frame][j][2];

    float vx = videoX(x, y, z);
    float vy = videoY(x, y, z);
    float vr = videoR(x, y, z);

    stroke(j == hoverChannel ? hiColor : 255, 100);
    strokeWeight(j == hoverChannel ? 6 : 3);

    ellipse(vx, vy, vr, vr);
  }
}

void drawTrails() {

  noFill();
  strokeWeight(10);
  strokeJoin(ROUND);  

  for (int i = 0; i < channels; i++) {

    // TODO: individual stroke for each channel
    stroke(i == hoverChannel ? hiColor : 0, 20);

    beginShape();

    for (int j = 0; j < trailSize && j < frame; j++) {

      float x0 = data[frame - j][i][0];
      float z0 = data[frame - j][i][2];

      // ignore 0-values (hacky-di-hack)
      if (x0 != 0 && z0 != 0) {
        vertex(mapX(x0), mapZ(z0));
      }
    } 

    endShape();
  }
}

void mouseOverMotiongrams() {

  int x0 = gap;
  int x1 = gap + barWidth;

  int sw = 3;

  if (colorMode) {
    stroke(hiColor2, 180);
  } else {
    stroke(hiColor, 150);
  }

  strokeWeight(2 * sw);

  // draw hilight outline around the bar, that is hovered
  hoverChannel = -1;
  for (int i = 0; i < bars; i++) {

    int y0 = 3 * gap + videoHeight + barHeight + i * (barHeight2 + gap2);
    int y1 = y0 + barHeight2 + gap2;

    if (mouseX > x0 && mouseX < x1 && mouseY > y0 && mouseY < y1) {
      hoverChannel = i;
      rect(x0-sw, y0-sw, x1 - x0 + 2 * sw, y1 - y0 + 2 * sw);
    }
  }
}


// map data to canvas coordinates
float mapX(float x) {
  return map(x, xMin, xMax, 0, dmap);
}
float mapZ(float z) {
  return map(z, zMax, zMin, 0, dmap);
}

// map data to video coordinates
float videoX(float x, float y, float z) {
  return map(x, -8, 8, 0, videoWidth);
}
float videoY(float x, float y, float z) {
  return map(z, 8, -8, 0 - (videoWidth-videoHeight)/2, videoHeight + (videoWidth-videoHeight)/2);
}
float videoR(float x, float y, float z) {
  return y * 100;
}


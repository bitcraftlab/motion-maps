
// More complex example loading multiple tracks from
// "One Flat Thing reproduced" by William Forsythe.

// Drag your mouse across the timeline to mark a region to play.


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

// Data is a 3D-Array of measurements (Frame, Track, Channel)

// - Each frame corresponds to one tick in time,
// - The trajectory of each dancer is contained in a channel that contains several tracks.
// - There is one track for each coordinate (x-coordinate, y-coordinate)

float[][][] data;

Movie video;
boolean paused = false;

// length of each trail
int trailSize = 200;

// Ringbuffer of trails, containing previous values (Frame, Track, Channel)
int trailIndex = 0;
int channels;

boolean loaded = false;

float inMarker;
float outMarker;

// window dimensions
int width, height; 
int frame;

// diameter of the canvas
int dmap; 

// gap around canvas and video
int gap = 10; 

int barHeight = 40;
int barWidth;

void setup () {

  // adjust window and canvas dimensions to the video size
  height = videoHeight + 3 * gap + barHeight;
  
  dmap = videoHeight;
  width = videoWidth + 3 * gap + dmap;
    
  // create window
  size(width, height);

  // get video from the server if it's not in the data folder yet ...
  get_video(videoServer, videoTitle);
  
  // get channels + tracks from the server, in case they are not in the data folder yet.
  get_data();
  
  // adjust bars to video size
  barWidth = videoWidth;
  
  // set markers
  inMarker = startTime;
  outMarker = endTime;
 
  // let the video trigger the redraw
  noLoop();

}



void draw () {
  
  if (loaded) {

    background(255);
    image(video, gap, gap);
    markVideo();
    
    // draw canvas
    
    pushMatrix();
    translate(2 * gap + videoWidth, gap);
  
    fill(200); noStroke();
    rect(0, 0, dmap, dmap);

    drawTrails();
    drawDancers();
   
    popMatrix();
    
    // draw GUI
    
    pushMatrix();
    translate(0, 2 * gap + videoHeight);
    drawProgressBar();
    popMatrix();

  } else {
    
    // indicate that the video is still loading
    background( #994433 );
  
  }
  
  
  // loop inside the limit
  if(video.time() < inMarker || video.time() > outMarker) {
     video.jump(inMarker);
  }

}


void movieEvent ( Movie mov ) {

  video.read();
  
  // increase frame counter
  frame = int( (video.time() - eventTimeOffset) * 25.0 );
  
  redraw();
     
}


void drawDancers() {
  
  fill(0, 100);
  noStroke();
  
  for(int j = 0; j < channels; j++) {
    float x = mapX(data[frame][j][0]);
    float z = mapZ(data[frame][j][2]); 
    ellipse(x, z, 12, 12);
  }
  
}


void markVideo() {
  
  fill(255, 100);
  strokeWeight(3);
  stroke(255, 100);
  
  for(int j = 0; j < channels; j++) {
    
    float x = data[frame][j][0];
    float y = data[frame][j][1];
    float z = data[frame][j][2];
    
    float vx = videoX(x, y, z);
    float vy = videoY(x, y, z);
    float vr = videoR(x, y, z);
    
    ellipse(vx, vy, vr, vr);
    
  }
  
}

void drawTrails() {
    
  noFill();
  
  for(int c = 0; c < channels; c++) {
    
    // TODO: individual stroke for each channel
    stroke(0, 20);
    strokeWeight(10);
    strokeJoin(ROUND);
    
    beginShape();
    
    for(int i = 0; i < trailSize && i < frame; i++) {
   
      float x0 = data[frame - i][c][0];
      float z0 = data[frame - i][c][2];
      
      // ignore 0-values (hacky-di-hack)
      if(x0 != 0 && z0 != 0) {
        vertex(mapX(x0), mapZ(z0));
      }

    } 
    
    endShape();
    
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



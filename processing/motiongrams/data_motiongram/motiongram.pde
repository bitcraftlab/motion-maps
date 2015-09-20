
// HSB constants
final int H = 0, S = 1, B = 2;
final int X = 0, Y = 1, Z = 2;

void drawProgressBar() {

  int x1 = spaceMap(inMarker);
  int x2 = spaceMap(video.time());

  fill(220);
  strokeWeight(1);
  stroke(50);
  rect(0, 0, barWidth, barHeight);

  fill(150);
  noStroke();
  rect(x1 + 1, 1, x2 - x1 - 1, barHeight - 1);

  // hilight progress bar cursor
  if (dragging) {

    fill(hiColor, 100);
    noStroke();

    x1 = spaceMap(tmpMarker);
    x2 = constrain(mouseX, gap, gap + barWidth) - gap;

    rect(x1, 0, x2 - x1, barHeight);

    strokeWeight(2);
    stroke(100, 0, 0);
    marker(tmpMarker);
    marker(timeMap(mouseX));
  }

  stroke(0, 100);
  strokeWeight(2);
  marker(inMarker);
  marker(outMarker);
}

void marker(float t) {
  float x = map(t, startTime, endTime, 0, barWidth);
  line(x, 0, x, barHeight-1);
}

void drawMotiongram(int channel) {

  // background bar
  stroke(outlineColor);
  strokeWeight(1);
  noFill();
  rect(0, 0, barWidth, barHeight2);


  // draw the actual datagram
  for (int x = 1; x < barWidth; x++) {

    // calculate the frame corresponding to the x-coordinate
    float t = timeMap(x);
    int frame = int( (t - eventTimeOffset) * 25.0 );

    // get HSB from the motiongram
    float[] hsb = motiongram[frame][channel];

    // draw a single 1pixel vertical line
    colorMode(HSB, 1, 1, 1);
    stroke(color(hsb[H], hsb[S], hsb[B]));
    line(x, 1, x, barHeight2 - 1);

    // reset color mode
    colorMode(RGB, 255);
  }
}


void initMotiongrams() {

  // two tracks for each frame and channel,and 3 for HSB values
  motiongram = new float[framenum + 1][channels][3];

  // default motiongram
  createMotiongrams(motiongramType);
}


void createMotiongrams(char mode) {

  for (int i = 0; i < framenum; i++) {
    for (int j = 0; j < channels; j++) {

      // account for the offset
      // this is somewhat of a hack, since it seems the offsets may be slightly different for each channel
      int ii = (int) (i + eventTimeOffset * 25);

      // sample distance for speed + acceleration calculations
      int ds = 10;

      // some magic numbers ...
      float max_speed = 1;
      float max_accel = 1;
      float vx, vy, vz;
      float vx2, vy2, vz2;
      float ax, ay, az;

      if (ii > 0 && i < framenum) {

        float[] hsb = motiongram[ii][j];


        switch(mode) {

        case 'x':
          // map x-coordinates to brightness
          hsb[H] = 0; 
          hsb[S] = 0;
          hsb[B] = map(data[i][j][X], xMin, xMax, 0, 1);
          colorMode = false;
          break;

        case 'y':
          // map y-coordinates to brightness
          hsb[H] = 0; 
          hsb[S] = 0;
          hsb[B] = map(data[i][j][Y], yMin, yMax, 0, 1);
          colorMode = false;
          break; 

        case 'z':
          // map y-coordinates to brightness
          hsb[H] = 0; 
          hsb[S] = 0;
          hsb[B] = map(data[i][j][Z], zMin, zMax, 0, 1);
          colorMode = false;
          break;

        case 'p':
          // map position to color
          // (distance from center = brightness, angle = hue)
          hsb[H] = map(atan2(data[i][j][Z], data[i][j][X]), -PI, PI, 0, 1);
          hsb[S] = 1;
          hsb[B] = map(dist(0, 0, data[i][j][X], data[i][j][Z]), 0, 8, 1, 0);
          colorMode = true;
          break;

        case 'v':
          // map speed to color
          // speed = ds / dt 
          vx = data[i][j][X] - data[i-ds][j][X];
          vz = data[i][j][Z] - data[i-ds][j][Z];
          hsb[H] = map(atan2(vz, vx), -PI, PI, 0, 1);
          hsb[S] = 1;
          hsb[B] = map(dist(0, 0, vx, vz), 0, max_speed, 0, 1);
          colorMode = true;
          break;

        case 'a':
          // map acceleration to color
          // a = dv / dt

          vx = data[i-ds][j][X] - data[i-2*ds][j][X];
          vz = data[i-ds][j][Z] - data[i-2*ds][j][Z];
          vx2 = data[i][j][X] - data[i-ds][j][X];
          vz2 = data[i][j][Z] - data[i-ds][j][Z];

          ax = vx2 - vx;
          az = vz2 - vz;

          hsb[H] = map(atan2(az, ax), -PI, PI, 0, 1);
          hsb[S] = 1;
          hsb[B] = map(dist(0, 0, ax, az), 0, max_accel, 0, 1);
          colorMode = true;

          break;

        case 'X':
          // map x-speed to color
          vx = data[i][j][X] - data[i-ds][j][X];
          hsb[H] = 0;
          hsb[S] = 0;
          hsb[B] = map(vx, -max_speed, max_speed, 0, 1);
          colorMode = false;
          break;

        case 'Y':
          // map y-speed to color
          vy = data[i][j][Y] - data[i-ds][j][Y];
          hsb[H] = 0;
          hsb[S] = 0;
          hsb[B] = map(vy, -max_speed, max_speed, 0, 1);
          colorMode = false;
          break;

        case 'Z':
          // map y-speed to color
          vz = data[i][j][Z] - data[i-ds][j][Z];
          hsb[H] = 0;
          hsb[S] = 0;
          hsb[B] = map(vz, -max_speed, max_speed, 0, 1);
          colorMode = false;
          break;
        }
      }
    }
  }
}


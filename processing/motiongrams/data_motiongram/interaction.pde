boolean dragging;

float tmpMarker;

void keyPressed() {
  switch(key) {

  case ' ':
    paused = !paused;
    if (paused) {
      // quick and dirty hack to pause the video.
      // keep jumping to the pause marker.
      // (We can't use video.pause(), since movieEvents are driving the draw loop ...)
      pauseMarker = video.time();
    }
    break;

  case '-': 
    eventTimeOffset -= 0.1;
    break;

  case '+':
    eventTimeOffset += 0.1;
    break;

  case '2':
    speed = 2;
    video.speed(speed);
    break;

  case '1':
    speed = 1;
    video.speed(speed);
    break;

  case 'i':
    inMarker = timeMap(mouseX);
    break;

  case 'o':
    outMarker = timeMap(mouseX);
    break;

  case 'r':
    // reset markers
    inMarker = startTime;
    outMarker = endTime;
    break;

    ////////////////////////// Motiongram Keys ////////////////////////

  case 'x':
    // color corrresponding to screen-x position of the dancer
    createMotiongrams('x');
    break;

  case 'X':
    // color corrresponding to screen-x position of the dancer
    createMotiongrams('X');
    break;

  case 'Y':
    // color corrresponding to screen-x position of the dancer
    createMotiongrams('Z');
    break;

  case 'C':
  case 'Z':
    // color corrresponding to screen-x position of the dancer
    createMotiongrams('Y');
    break;

  case 'y':
    // color corrresponding to height of the dancer
    createMotiongrams('z');
    break;

  case 'c':
  case 'z':
    // color corrresponding to the screen-y position of the dancer
    createMotiongrams('y');
    break;

  case 'p':
  case 'd':
    // color and hue corresponding to position of the dancer, with respect to the center 
    createMotiongrams('p');
    break;

  case 's':
  case 'v':
    // color and hue corresponding to the speed of the dancer
    createMotiongrams('v');
    break;

  case 'a':
    // color and hue corresponding to the acceleration of the dancer
    createMotiongrams('a');
    break;
  }
}

void mouseClicked() {

  //paused = false;
  int m1 = spaceMap(inMarker);
  int m2 = spaceMap(outMarker);

  if (mouseX < m1) {
    inMarker = timeMap(mouseX);
  } else if (mouseX > m2) {
    outMarker = timeMap(mouseX);
  } else {
    float t = timeMap(mouseX);
    video.jump(t);
    // pause hack ...
    if (paused) pauseMarker = t;
  }
}

void mouseDragged() {
  if ((keyPressed && keyCode == SHIFT) || mouseButton == RIGHT) {

    if (dragging == false) {
      dragging = true;
      tmpMarker = timeMap(mouseX);
    }
  } else {
    mouseClicked();
  }
}

void mouseReleased() {
  if (dragging) {

    float tmpMarker2 = timeMap(mouseX);      

    if (tmpMarker < tmpMarker2) {
      inMarker = tmpMarker;
      outMarker = tmpMarker2;
    } else {
      outMarker = tmpMarker;
      inMarker = tmpMarker2;
    }

    dragging = false;
  }
}

float timeMap(float x) {

  int minX = gap;
  int maxX = barWidth + gap;
  x = constrain(x, minX, maxX);

  return map(x, minX, maxX, startTime, endTime);
}

int spaceMap(float t) {

  int x = (int) map(t, startTime, endTime, 0, barWidth);
  x = (int) constrain(x, 0, barWidth);
  return x;
}


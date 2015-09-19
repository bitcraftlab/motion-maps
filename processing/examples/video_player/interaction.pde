boolean dragging;

float tmpMarker;

void keyPressed() {
  switch(key) {

    case '-': 
      eventTimeOffset -= 0.1;
      break;
      
    case '+':
      eventTimeOffset += 0.1;
      break;
   
    case 'p':
      println("OFFSET: " + eventTimeOffset);
      break;
   
     case 'i':
      inMarker = timeMap(mouseX);
      break;
      
     case 'o':
       outMarker = timeMap(mouseX);
       break;
   
  } 
  
}

void mouseClicked() {
  
  int m1 = spaceMap(inMarker);
  int m2 = spaceMap(outMarker);

  if(mouseX < m1) {
    inMarker = timeMap(mouseX); 
  } else if(mouseX > m2) {
    outMarker = timeMap(mouseX);
  } else {
    video.jump(timeMap(mouseX));
  }
  
}

void mouseDragged() {
  if(dragging == false) {
    dragging = true;
    tmpMarker = timeMap(mouseX);
  }
}

void mouseReleased() {
  if(dragging) {
    
    float tmpMarker2 = timeMap(mouseX);      

    if(tmpMarker < tmpMarker2) {
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
  int maxX = videoWidth + gap;
  x = constrain(x, minX, maxX);
  
  return map(x, minX, maxX, startTime, endTime);
   
}

int spaceMap(float t) {
  
  int x = (int) map(t, startTime, endTime, 0, barWidth);
  x = (int) constrain(x, 0, barWidth);
  return x;
  
}

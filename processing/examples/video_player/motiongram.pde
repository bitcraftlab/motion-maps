
void drawProgressBar() {
 
  int x1 = spaceMap(inMarker);
  int x2 = spaceMap(video.time());

  fill(220);
  rect(gap, 0, barWidth, barHeight);
  
  fill(150);
  rect(gap + x1, 0, x2 - x1, barHeight);
  
  // hilight cursor
  if(dragging) {
    
    fill(255, 0, 0, 100);
    noStroke();
    
    x1 = spaceMap(tmpMarker);
    x2 = constrain(mouseX, gap, gap + barWidth) - gap;
    
    rect(gap + x1, 0, x2 - x1, barHeight);
    
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
  line(gap + x, 0, gap + x, barHeight-1);
}

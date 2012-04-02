

/* @pjs preload="lichen4.jpeg"; */

import processing.opengl.*;

Loom currentLoom;
PVector rotation;
PVector trotation;
float yshift = 0;
float tyshift = 0;

ArrayList<Loom> activeLooms = new ArrayList();
ControlMatrix harnessControl = new ControlMatrix();
ControlMatrix tieUpControl = new ControlMatrix();
ControlMatrix treadleControl = new ControlMatrix();

color bgcolor = 255;
color tbgcolor = 0;


boolean advancing = true;
boolean flat = true;

boolean controls = false;

int mode = 0;

int advanceSpeed = 40;

void setup() {
  size(screenWidth, screenHeight, OPENGL);
  background(bgcolor); 
  strokeWeight(1.2);
  smooth();
  currentLoom = new Loom();
  currentLoom.init(16, 64, 16, 250);//ceil(height/currentLoom.threadSpace) + 50);
  //currentLoom.setColors("lichen.jpeg");
  setControls();
  positionControls();


  activeLooms.add(currentLoom);
  rotation = new PVector();
  trotation = new PVector();

  tyshift = (height - (currentLoom.cWeft * currentLoom.threadSpace)) / 2;
  
  toggleFlat();

}

void draw() {

  bgcolor = lerpColor(bgcolor, tbgcolor, 0.1);
  yshift = lerp(yshift, tyshift, 0.1);

  if (mousePressed) {
    //trotation.x += (mouseY - pmouseY) * 0.01;
    trotation.z -= (mouseX - pmouseX) * 0.001;
  }

  background(bgcolor);

  fill(255);
  //lights();
  //text(rotation.x, 50, 250);
  //text(rotation.z, 50, 270);
  pushMatrix();

  rotation.x += (trotation.x - rotation.x) * 0.1;
  rotation.z += (trotation.z - rotation.z) * 0.1;

  translate(width/2 - (rotation.x * 300), 0);

  translate(0, 300);
  rotateX(rotation.x);
  rotateZ(rotation.z);
  translate(0, -300);
  translate(0, yshift);
  //println(frameRate);

  for (Loom loom:activeLooms) {
    loom.update();
    loom.render();
  };

  popMatrix();
  if (controls) renderControls();

  /*
 renderMatrix( currentLoom.harnesses, 5);
   
   translate(width - 100, 0);
   renderMatrix( currentLoom.tieUp, 5);
   
   translate(0,200);
   renderMatrix( currentLoom.treadlePattern, 5);
   */
  if (advancing && frameCount % advanceSpeed == 0 || frameCount == 1) {
    if (mode == 0) {
      currentLoom.treadlePattern =  wolframAdvance(currentLoom.treadlePattern, 1); 
    } else {
      currentLoom.treadlePattern = automate(currentLoom.treadlePattern, 1); 
    }
    setControls();
  }
}

void mousePressed() {
  harnessControl.onPress(); 
  tieUpControl.onPress(); 
  treadleControl.onPress();
}

void keyPressed() {
  //println(key);

  if (keyCode == RIGHT) {
    nextHarness();
  }
  if (keyCode == DOWN || key == '8') {
    //println("DOWN");
    //nextPattern();
  }
  if (key == 'w') {
    currentLoom.cWeft = 0;
  }

  if (key == 's') {
    String timeStamp = hour() + "_"  + minute() + "_" + second();
    save("out/weave" + timeStamp + ".png");
  } 

  if (key == 'b') {
    toggleBack();
  }

  if (key == 'a') {
    advancing = !advancing;
  }

  if (key == 'f') {
    toggleFlat();
  }

  if (key == 'c') {
    toggleControls();
  }

  //println("KEY PRESSED");
}

void toggleControls() {
  controls = !controls;
}

void toggleFlat() {
  flat = !flat;
  trotation = (flat) ? new PVector():new PVector(1.19, 0, -0.9); 
  tyshift = (flat) ? (height - (currentLoom.cWeft * currentLoom.threadSpace)) / 2:600;
}

void toggleBack() {
  tbgcolor = (tbgcolor == 0) ? (255):(0);
}

void setWeft(String wc) {
  color c = unhex("FF" + wc);
  currentLoom.weftColor = c; 
}

void setWarp(String wc) {
  color c = unhex("FF" + wc);
  currentLoom.warpColors = new color[0]; 
  currentLoom.warpColors[0] = c;
}

void setAdvance(int i) {
 advanceSpeed = i; 
}

void setWidth(int i) {
  currentLoom.threadCount = i * currentLoom.heddleCount;
}

void setMode(int i) {
 mode = i; 
}

void setControls() {
  harnessControl.init(currentLoom.harnesses);
  tieUpControl.init(currentLoom.tieUp);
  tieUpControl.vert = true;
  treadleControl.init(currentLoom.treadlePattern);
  treadleControl.vert = true;
}

void positionControls() {


  tieUpControl.pos.x = width - 50 - tieUpControl.w;
  tieUpControl.pos.y = 25; 

  treadleControl.pos.x = tieUpControl.pos.x;
  treadleControl.pos.y = 25 + tieUpControl.h + 1;

  harnessControl.pos.x = 25;//tieUpControl.pos.x - harnessControl.w - 25;
  harnessControl.pos.y = 25;
}

void renderControls() {
  harnessControl.update();
  tieUpControl.update();
  treadleControl.update();

  harnessControl.render();
  tieUpControl.render();
  treadleControl.render();
}


void nextHarness() {
  Loom newLoom = cloneLoom(currentLoom);

  activeLooms.add(newLoom);
  currentLoom.tpos.x = -width/2 - 500;
  newLoom.harnesses = zebra(blank(newLoom.harnesses.length, newLoom.harnesses[0].length), 0.1, 1, false);
  newLoom.setColors("lichen4.jpeg");
  newLoom.weftColor = currentLoom.weftColor;
  newLoom.threadCount = currentLoom.threadCount;
  currentLoom = newLoom;
  setControls();
  currentLoom.pos.x = width/2 + 300;
}

void nextPattern() {
  Loom newLoom = cloneLoom(currentLoom);
  activeLooms.add(newLoom);
  currentLoom.tpos.y += -height * 1.5;
  newLoom.treadlePattern = automate(currentLoom.treadlePattern, 1);
  newLoom.weftColor = currentLoom.weftColor;
  newLoom.warpColors = cloneArray(currentLoom.warpColors);
  newLoom.threadCount = currentLoom.threadCount;
  currentLoom = newLoom;
  setControls();
  currentLoom.pos.y = height;
}

Loom cloneLoom(Loom oldLoom) {
  Loom newLoom = new Loom();
  newLoom.init(oldLoom.harnessCount, oldLoom.heddleCount, oldLoom.treadleCount, oldLoom.patternLength);
  newLoom.harnesses = cloneMatrix(oldLoom.harnesses);
  newLoom.tieUp = cloneMatrix(oldLoom.tieUp);
  newLoom.treadlePattern = cloneMatrix(oldLoom.treadlePattern);

  return(newLoom);
}

public class ControlMatrix {

  int[][] matrix;
  PVector pos = new PVector();
  PVector tpos = new PVector();

  PGraphics canvas;

  float w;
  float h;

  float blockSize = 5;
  float buttonSize = 15;
  boolean mouseOver = false;
  boolean buttonOver = false;
  int buttonIndex = 0;

  int buttonCount = 5;

  boolean blitted = false;
  boolean vert = false;
  
  String[] labels = {"zebra","zigzag","automata","automata2","clear"};
  String label = "";
  
  void init(int[][] _m) {
    blitted = false;

    matrix = _m;
    w = matrix[0].length * blockSize;
    h = matrix.length * blockSize;

    //if (canvas == null) canvas = createGraphics(floor(w), floor(h), P3D);
  }

  void update() {
    mouseOver = (mouseX > pos.x && mouseX < pos.x + w && mouseY > pos.y && mouseY < pos.y + h);
    if (!vert) {
      buttonOver = (mouseX > pos.x && mouseX < pos.x + w + 30 && mouseY > pos.y + h && mouseY < pos.y + h + 12);
    } else {
      buttonOver = (mouseX > pos.x - buttonSize && mouseX < pos.x && mouseY > pos.y&& mouseY < pos.y + h);

    }
    
    if (buttonOver) {
      if (!vert) {
        buttonIndex = floor((mouseX - pos.x) / (buttonSize + 1));
      } else {
        buttonIndex = floor((mouseY - pos.y) / (buttonSize + 1));
      }
    }
  }

  void render() {
    if (!buttonOver) label = "";
    pushMatrix();
    //render the base grid
    translate(pos.x, pos.y);
    int gs = (mouseOver) ? (100):(200);
    gs = 200;
    if (!blitted) {
      //canvas.beginDraw();
      //canvas.background(255);
      renderMatrix(matrix, blockSize, gs);
      //blitted = true;
      //canvas.endDraw();
    } 
    else {
      image(canvas, 0, 0);
    }


    if (mouseOver) {
      //hilight the block we're over
      int xo = floor((mouseX - pos.x)/blockSize);
      int yo = floor((mouseY - pos.y)/blockSize);
      stroke(255, 0, 0);
      noFill();
      pushMatrix();
      translate(0,0,0.002) ;
        rect(xo * blockSize, yo * blockSize, blockSize, blockSize);
      popMatrix();
    }
    
    if (!vert) {
      translate(0, h + 1);
    } else {
      translate(-1, 0);
      rotate(PI/2);
    }
    noStroke();

    for (int i = 0; i < buttonCount; i++) {
      fill(230);
      if (buttonOver && i == buttonIndex) {
        fill(#FF9900);
        label = labels[i];
      }
      rect(i * (buttonSize + 1), 0, buttonSize, buttonSize);
    }


    translate(0,5);
    fill(255);
    textSize(12);
    text(label, 0, 20);
    popMatrix();
  }

  void onPress() {
    int xo = floor((mouseX - pos.x)/blockSize);
    int yo = floor((mouseY - pos.y)/blockSize);
    if (mouseOver) {
      matrix[yo][xo] = (matrix[yo][xo] == 1) ? (0):(1); 
      blitted = false;
    } 
    else if (buttonOver) {
      buttonPress();
    }
  }

  void buttonPress() {
    //println(buttonIndex);
    if (buttonIndex == 0) {
      int[][] newMatrix = zebra(matrix, 0, 0, false);
      populateMatrix(newMatrix, matrix);
    } 
    else if (buttonIndex == 1) {
      clearMatrix(matrix);
      int[][] newMatrix = zebra(matrix, 0.1, 0, false);
      populateMatrix(newMatrix, matrix);
    } 
    else if (buttonIndex == 2) {
      int[][] newMatrix = automate(matrix, 0);
      populateMatrix(newMatrix, matrix);
    } 
    else if (buttonIndex == 3) {
      int[][] newMatrix = automate(matrix, 1);
      populateMatrix(newMatrix, matrix);
    } 
    else if (buttonIndex == 4) {
      clearMatrix(matrix);
    } 

    blitted = false;
  }
}

public class Loom {

  int harnessCount = 4;
  int heddleCount = 12;

  int treadleCount = 4;
  int patternLength = 8;

  int threadCount = 12 * 5;
  float threadSpace = 2.5;

  color[] warpColors = {
    #331111, #551111
  };
  color weftColor = #FFFFFF;

  boolean alive= true;

  int[][] harnesses;
  int[][] treadlePattern;
  int[][] tieUp;

  float warpWidth = 2.5;
  float weftWidth = 2.5;

  PVector pos = new PVector();
  PVector tpos = new PVector();

  
  int cWeft = 0;
  int[] superHarness;
  float[] positions;
  float[] tpositions;
 
  
  int weftRepeat = 1;
  
  float spread = 0;

  Loom() {
  }

  void init(int har_, int hed_, int ped_, int pat_) {
    
    harnesses = zebra(blank(har_, hed_), 0, 1, false);
    tieUp = zebra(blank(har_, ped_), 0, 1, false);
    treadlePattern = zebra(blank(pat_, ped_), 0.1, 1, false);

    harnessCount = har_;
    heddleCount = hed_;
    treadleCount = ped_;
    patternLength = pat_;
    
    threadCount = heddleCount * 2;
    cWeft = patternLength * weftRepeat;
    
    positions = new float[heddleCount];
    tpositions = new float[heddleCount];
    for (int i = 0; i < heddleCount; i++) {
     tpositions[i] = 0; 
    }
    
    
  }
  
  void setColors(String url) {
    PImage img = loadImage(url);
    int repeat = ceil(random(100));
    int step = floor(random(1,10));
    
    warpColors = new color[repeat];
    int offset = floor(random(img.pixels.length - 1000));
    for (int i =0 ; i < repeat; i++) {
     warpColors[i] = img.pixels[(i * step) + offset];
    } 
    
    //weftColor = warpColors[0];
    
  }

  void update() {
    pos.x = lerp(pos.x, tpos.x, 0.1);
    pos.y = lerp(pos.y, tpos.y, 0.1);
    alive = (pos.x > -width/2 - 250 && pos.x < width/2 + 250 && pos.y > -(height * 1)+ 10 & pos.y < height - 10);
    
    for (int i = 0; i < heddleCount; i++) {
     positions[i] += (tpositions[i] - positions[i]) * (1.0 / 8); 
    }
  }

  void render() {
    if (alive) {
      pushMatrix();
      translate(pos.x, pos.y);
      translate(-threadCount * 0.5 * threadSpace, 0);
      
      int b = round(height - (patternLength * threadSpace * 2)) / 4;
      pushMatrix();
      float wf = (float) cWeft / patternLength;
      translate(0,patternLength * weftRepeat * threadSpace * wf);
      translate(0,-150);
      for (int i = 0; i < cWeft; i++) {
        weft(i);
      }
      popMatrix();
      if (currentLoom == this || (alive && tpos.x != 0) ) warp();
      
      popMatrix();
      if (cWeft < patternLength * weftRepeat) cWeft += 1;
    }
  }


  void warp() {
    strokeWeight(warpWidth);
    pushMatrix();
    float off = patternLength * weftRepeat * threadSpace;
    off -= 50;
    for (int i = 0; i < threadCount; i++) {
      stroke(warpColors[i % warpColors.length] );
      line(i * threadSpace, 2000, i * threadSpace, -50);
      float h = positions[i % superHarness.length] * 20;
      line(i * threadSpace, -50, 0, i * threadSpace, -10000, h * 100);
    }
    popMatrix();
  }

  void weft(int wi) {
    pushMatrix();
    translate(0,100);
    strokeWeight(weftWidth);
    //First, see what treadles are down by getting a treadling pattern from the list
    int[] tp = treadlePattern[wi % treadlePattern.length];
    //Now, go through the tie-up pattern to see which harnesses we have raised
    int[] harnessList = new int[harnessCount];
    // - first, make a zero-filled list
    for (int i = 0; i < harnessCount; i++) {
      harnessList[i] = 0;
    }
    //Next, use the tie-up to mark which harnesses we're using
    for (int i = 0; i < tp.length; i++) {
      if (tp[i] == 1) {
        int[] tu = tieUp[i];
        for (int j = 0; j < tu.length; j++) {
          if (tu[j] == 1) {
            harnessList[j] = 1;
          }
        }
      }
    }
    //Finally, add these harnesses together into a 'super harness' which tells us which strings we have raised
    superHarness = new int[heddleCount];
    for (int i = 0; i < heddleCount; i++) {
      superHarness[i] = 0;
      tpositions[i] = 0;
    }

    for (int i = 0; i < harnessList.length; i++) {
      if (harnessList[i] == 1) {
        int[] harness = harnesses[i];
        for (int j = 0; j < harness.length; j++) {
          if (harness[j] == 1) {
            superHarness[j] = 1;
            tpositions[j] = 1;
          }
        }
      }
    }

    //Ok, this is really finally. Now we can draw the thread
    noFill();
    beginShape();
    stroke(weftColor,255);
    vertex(0, -wi * threadSpace, 0);
    float slope = 0;
    for (int i = 0; i < threadCount; i ++) {
      int ud = superHarness[i % superHarness.length];
      float h = (ud * 2) - 1;
      //h *= random(0.7, 1.3);
      vertex(i * threadSpace, -wi * threadSpace, h + slope);
    }
    endShape();
    popMatrix();
  }
}

int[][] cloneMatrix(int[][] seed) {
  int[][] out = new int[seed.length][seed[0].length];
  for (int i = 0; i < seed.length; i++) {
    for (int j = 0; j < seed[0].length; j++) {
      out[i][j] = seed[i][j];
    }
  } 
  return(out);
}

int[] cloneArray(int[] seed) {
 int[] out = new int[seed.length];
 for (int i = 0; i < seed.length; i++) {
   out[i] = seed[i];
 }
 return(out);

  
}

void populateMatrix(int[][] seed, int[][] out) {
  for (int i = 0; i < seed.length; i++) {
    for (int j = 0; j < seed[0].length; j++) {
      out[i][j] = seed[i][j];
    }
  }
}

int[][] blank(int x, int y) {
  int[][] out = new int[x][y];
  for (int i = 0; i < x; i++) {
    for (int j = 0; j < y; j++) {
      out[i][j] = 0;
    }
  } 
  return(out);
}

void clearMatrix(int[][] seed) {
  for (int i = 0; i < seed.length; i++) {
    for (int j = 0; j < seed[0].length; j++) {
      seed[i][j] = 0;
    }
  }
}


int[][] zebra(int[][] seed, float mirrorChance, float bounceChance, boolean self) {
  int[][] out = cloneMatrix(seed);
  int dir = 1;
  int c = 0;
  if (seed.length > seed[0].length) {
    //tall 
    for (int i = 0; i < seed.length; i++) {
      if (c % seed[0].length == seed[0].length - 1 && random(1) < bounceChance || random(1) < mirrorChance) dir *= -1;
      c += dir;
      c = (c  + seed[0].length) % seed[0].length;
      //println(i + ":" + c);
      out[i][c] = 1;
    }
  } 
  else {
    //wide 
    for (int i = 0; i < seed[0].length; i++) {

      if (c % seed.length == seed.length - 1 && random(1) < bounceChance || random(1) < mirrorChance ) dir *=-1;
      c += dir;
      c = ( c + seed.length )% seed.length;
      out[c][i] = 1;
    }
  }
  return(out);
}


int[][] advance(int[][] seed, int x, int y) {
  int[][] out = cloneMatrix(seed);
  for (int i = 0; i < seed.length; i++) {
    for (int j = 0; j < seed[0].length; j++) {
      out[i][j] = seed[(i + x) % seed.length][(j + y) % seed[0].length];
    }
  }
  return(out);
}

int[][] automate(int[][] seed, int rule) {
  int[][] out = cloneMatrix(seed);
  if (rule < 2) {
    for (int i = 0; i < seed.length; i++) {
      for (int j = 0; j < seed[0].length; j++) {
        int t = seed[i][((j - 1) + seed[0].length) % seed[0].length];
        int b = seed[i][(j + 1) % seed[0].length];
        int r = seed[(i + 1) % seed.length][j];
        int l = seed[((i - 1) + seed.length) % seed.length][j];
        /*
     int topRight = seed[(i + 1) % seed.length][((j - 1) + seed[0].length) % seed[0].length];
         int topLeft = seed[((i - 1)  + seed.length)% seed.length][((j - 1) + seed[0].length) % seed[0].length];
         int bottomRight = seed[(i + 1) % seed.length][(j + 1) % seed[0].length];
         int bottomLeft = seed[((i - 1)  + seed.length)% seed.length][(j + 1) % seed[0].length];
         */

        if (rule == 0) {
          //Von Neumann voter rule
          if (t + b + r + l > 2) {
            out[i][j] = 1;
          } 
          else if ( t + b + r + l < 2) {
            out[i][j] = 0;
          } 
          else {
            out[i][j] = (seed[i][j] == 1) ? (0):(1);
          }
        } 
        else if (rule == 1) {
          out[i][j] = (t + b + r + l) % 2;
        }
      }
    }
  } 
  else {
    //Wolframe's rule 110
    //Start with the last row from the seed
    int[] current = seed[seed.length - 1];
    for (int k = 0; k < seed.length; k++) {
      out[k] = wolfram110(current);
      current = out[k];
    }
  }

  return(out);
}

int[][] wolframAdvance(int[][] seed, int count) {
  int[][] out = cloneMatrix(seed);

  int[] current = seed[count];
  for (int k = 0; k < seed.length; k++) {
    out[k] = wolfram110(current);
    current = out[k];
  }

  return(out);
}

void renderMatrix(int[][] matrix, float bs, int gs) {
  //pg.beginDraw();
  stroke(0, 10);
  fill(255,255,255);
  rect(0,0,matrix[0].length * bs, matrix.length *bs);
  noStroke();
  pushMatrix();
  translate(0,0,0.001);
  for (int i = 0; i < matrix.length; i++) {
    for (int j = 0; j < matrix[0].length; j++) {
      float c = (matrix[i][j] == 1) ? (gs):(255);
      if (matrix[i][j] == 1) {
      fill(170);
      rect(j * bs, i * bs, bs, bs);
      }
    }
  }
  popMatrix();
  //pg.endDraw();
}

int[] wolfram110(int[] seed) {
  int[] out = new int[seed.length];

  for (int i = 0; i < seed.length; i++) {
    int c = seed[i];
    int l = seed[((i - 1) + seed.length) % seed.length]; 
    int r = seed[(i + 1) % seed.length];

    int bracket = (l * 100) + (c * 10) + r;


    if (bracket == 111) {
      out[i] = 0;
    } 
    else if (bracket == 110) {
      out[i] = 0;
    } 
    else if (bracket == 101) {
      out[i] = 0;
    } 
    else if (bracket == 100) {
      out[i] = 1;
    } 
    else if (bracket == 11 ) {
      out[i] = 1;
    } 
    else if (bracket == 10) {
      out[i] = 1;
    } 
    else if (bracket == 1) {
      out[i] = 1;
    } 
    else if (bracket == 0) {
      out[i] = 0;
    }
  }


  for (int i = 0; i < seed.length; i++) {
    //out[i] = seed[i];
  }
  return(out);
}



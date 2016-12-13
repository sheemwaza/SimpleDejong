import controlP5.*;


ControlP5 cp5;

int renderMultiplier = 100;
int contrast = 50;
int exposure = 15;
int DOF = 50;

float maxRange = 3;

float a = random(-maxRange, maxRange);
float b = random(-maxRange, maxRange);
float c = random(-maxRange, maxRange);
float d = random(-maxRange, maxRange);
float e = random(-maxRange, maxRange);
float f = random(-maxRange, maxRange);

float x = 0;
float y = 0;
float z = 0;

float xTemp, yTemp, zTemp;


float cx, cy;
float sx = 150;
float sy = 150;
float sz = 150;

float cr = 0;


float [][] HDRBuffer;
PImage img;

int INTERACTIVE = 0;
int RENDERING = 1;
int DISPLAY = 2;

int mode = INTERACTIVE;

int renderCounter = 0;

void setup() {

  size (1500, 1000, P3D);
  cx = width/2.f;
  cy = height/2.f;
  background(255);     


cp5 = new ControlP5(this);
  cp5.addSlider("a")
     .setPosition(50,30)
     .setRange(-maxRange,maxRange)
     ;

cp5 = new ControlP5(this);
  cp5.addSlider("b")
     .setPosition(50,40)
     .setRange(-maxRange,maxRange)
     ;


cp5 = new ControlP5(this);
  cp5.addSlider("renderMultiplier")
     .setPosition(50,50)
     .setRange(0,1000)
     ;

cp5 = new ControlP5(this);
  cp5.addSlider("contrast")
     .setPosition(50,60)
     .setRange(0,100)
     ;

cp5 = new ControlP5(this);
  cp5.addSlider("exposure")
     .setPosition(50,70)
     .setRange(0,100)
     ;

cp5 = new ControlP5(this);
  cp5.addSlider("DOF")
     .setPosition(50,80)
     .setRange(1,500)
     ;

  cp5.addButton("Save")
     .setPosition(50,100)
     .setSize(100,9)
     ;
  cp5.addButton("New")
     .setPosition(50,110)
     .setSize(100,9)
     ;

  HDRBuffer = new float[width][height];
  img = new PImage(width,height);
}


public void Save(int val) {
  println("Saving image");
  save("c:\\temp\\render" + random(0,999999) + ".jpg");

}


void draw() {

  fill(255, 255, 255, 70);
  rect(0, 0, width, height);
  //background(255);
  noStroke();
  fill(0, 0, 0, 30);

  pushMatrix();
  //translate(cx,cy);
  //scale(sx,sy);

  float rx, ry, rz; //render coords

  int count=25000;
  if (mode == RENDERING ) count *=renderMultiplier;

  for (int i=0; i < count; i++) {  

    xTemp = sin(a*z)-cos(b*x) + random(0, .01);
    yTemp = sin(c*x)-cos(d*y);// + random(0,.05);
    zTemp = sin(e*y)-cos(f*z);// + random(0,.05);

    x = xTemp;
    y = yTemp;
    z = zTemp;

    //rotate
    rx = x*cos(cr) + z*sin(cr);
    rz = x*sin(cr) - z*cos(cr);
    ry = y;

    //scale
    rx *= sx;
    ry *= sy;
    rz *= sz;

    //translate
    rx += cx;
    ry += cy;
    

    if (mode == INTERACTIVE) {

      //ellipse(rx,ry,1.f/(.75*sx),1.f/(.75*sy));
      ellipse(rx, ry, 1.5, 1.5);
    } else if (mode == RENDERING) {

    //code for DOF blur
    /*
    int wX = 1+(int)abs((rz/DOF));  
    float sc;  
      if (rx > wX && rx < width-wX) {
        if (ry >=0 && ry < height) {
          
          for (int w = -wX; w < wX; w++){
            //sc = wX-abs((w-wX)/wX);
            HDRBuffer[(int)rx+w][(int)ry] += 1.f/wX;
          }
  }          
      }
      */  
   HDRBuffer[(int)rx][(int)ry] += 1.f;    
    
       

    } else if (mode == DISPLAY) {
    }
  }
  if ( mode == RENDERING) {
    mode = DISPLAY;
    

     //get the darkest value
     float maxVal = 0;
     float tVal;
    for (int i=0; i< width; i++){
      for (int j=0; j < height; j++){

          tVal = HDRBuffer[i][j];
          if (tVal > maxVal) maxVal = tVal;
      }
    }
    
    
    //now bake the buffer into an image
    for (int i=0; i< width; i++){
      for (int j=0; j < height; j++){

          tVal = HDRBuffer[i][j];
          
          
          tVal /= maxVal;//map domain 0-1
          tVal *=pow(exposure/10.f,1/(contrast/100.f));
          
          //gamma correct
          tVal = sRGBEncode(tVal);
            
          tVal += abs(j-(height/2))/(height/2.f)/20.f;
          tVal += abs(i-(width/2))/(width/2.f)/20.f;
          
          tVal = 1-tVal;
             
          
          tVal *=255;
          img.set(i,j,color(tVal));

      }
    }
    
  }
  
  else if (mode == DISPLAY){
      image(img,0,0);
  }
  popMatrix();
}


float sRGBEncode(float c){

  float A=(float)exposure/10.f;
  float lambda = (float)contrast/100.f;
  return A*pow(c,lambda);
 }


void mouseWheel(MouseEvent event){
  float e = 10*event.getCount();
    
    sy -= e; 
    sx -= e;
    sz -= e;
  


}


void mouseDragged() {

  if (mouseButton == CENTER) {
    cx += mouseX-pmouseX;
    cy += mouseY-pmouseY;
  } else if (mouseButton == RIGHT){
    cr += (mouseX-pmouseX)/100.f;
  }
}


public void New(int val) {

    a = random(-maxRange, maxRange);
    b = random(-maxRange, maxRange);
    c = random(-maxRange, maxRange);
    d = random(-maxRange, maxRange);
    e = random(-maxRange, maxRange);
    f = random(-maxRange, maxRange);

}

void clearBuffer(){
  HDRBuffer = new float[width][height];

}




void keyPressed() {

  if (key == ' ') {
    if (mode == INTERACTIVE){
      mode = RENDERING;
      
      clearBuffer();
    }
    
    else if (mode == DISPLAY) mode = INTERACTIVE;
  }


}
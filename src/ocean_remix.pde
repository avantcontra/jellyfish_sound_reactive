import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;


Minim minim;
AudioInput in;
AudioOutput out;
AudioPlayer player;
SineWave sine;
BeatDetect beat;

int numSystems = 40; 
PSystem[] ps = new PSystem[numSystems]; 
float theta, theta2 = 0.0f; 
float r; 
float amplitude;   
float x, y,z; 
float inx, iny, inz; 
PVector centerLoc; 
float rotx,roty;
int bounds = 1000;
float jx,jy,jz;
float jxSpeed, jySpeed, jzSpeed, jxRot,jyRot,jzRot;
int zoom;
color curvColor;
color pointColor;
boolean isBeat = false;

void setup() 
{ 
  size(800, 600, P3D); 
  
   minim = new Minim(this);
//  minim.debugOn();
  in = minim.getLineIn(Minim.STEREO, 512);
   player = minim.loadFile("BlueFantasy.mp3", 2048);
   
  beat = new BeatDetect();
  beat.setSensitivity(250);
  //beat.detectMode(BeatDetect.FREQ_ENERGY); 
  
   // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
  out = minim.getLineOut(Minim.STEREO);
 
  
  colorMode(HSB, 360, 100, 100, 100); 
   background(224, 94, 28, 100); 
   c1 = color(224, 98, 98, 255);
c2 = color(224, 98, 6, 255);
  inx = 0; 
  iny = 0; 
  centerLoc = new PVector(width/2, height/2, 0); 
  for(int i=0; i<numSystems; i++){ 
    // dispose PSystems in a circle 
    x = r * cos(theta); 
    y = r * sin(theta); 
    z = 1;
    x += inx; 
    y += iny;       
    ps[i] = new PSystem(new PVector(x, y, z), 60, theta);  
    theta += 0.16; //0.0572;
  } 
  r = 20.0f; //40
  amplitude = r; 
  
  curvColor = color(0, 99, 99, 255);
  pointColor = color(0, 99, 99, 255);

  this.jxSpeed = 1;
  this.jySpeed = 1; 
  this.jzSpeed = 1; 
  this.jxRot = random(100, 150);
  this.jyRot = random(100, 150);
  this.jzRot = random(100, 150);
  
  img = loadImage("windows.jpg");  // Load the image
  columns = img.width / cellsize;  // Calculate # of columns
  rows = img.height / cellsize;  // Calculate # of rows
  
} 
PImage img;       // The source image
int cellsize = 16; // Dimensions of each cell in the grid
int columns, rows;   // Number of columns and rows in our system


void mouseDragged () {
  zoom =-mouseY*4;
}
  
color c2;
color c1;

void draw() 
{ 
 background(224, 94, 28, 100); 
 
 if(dump)
 {
   drawExpode();
   return;
 }
 
 
//  for (int i = 0; i <= height; i++)
//  {
//      float inter = map(i, 0, height, 0, 1);
//      color c = lerpColor(c1, c2, inter);
//      stroke(c);
//      line(0, i, -1000, width, i, -1000);
//    }
  
 translate (width/2,height/2,zoom); 
 rotx += map(mouseX, 0, width,-0.001,0.001) * HALF_PI;
 roty += map(mouseY, 0, height,-0.001,0.001) * HALF_PI; 
  rotateX(rotx);
  rotateY(roty);

  noSmooth(); 
  
  
  detectBeat();
  waveR(); // cycle and run all the PSystems 
 // amplitude = 20;
  
  pushMatrix();
  
  noiseDetail(1,0.2);
  jyRot += noise (-0,005,0.005);
  jzRot += noise (-0.005,0.005);
  rotateY(radians(jyRot));
  rotateZ(radians(jzRot));
 //rotateY(PI/2);
   drawWaveForms();
  for(int i = 0; i < numSystems; i++) 
  { 
    ps[i].run(); 
  }  
  popMatrix();
} 

void drawWaveForms()
{
   // draw the waveforms
    float amp = random(70, 200);
  
  //=========1
   pushMatrix();  
   rotateY(-PI/2);
   rotateX(-PI/3);
   scale(random(1.1, 1.2),1);  
    translate (0-width/2,0,0);  
  for(int i = 0; i < player.bufferSize()/12 - 1; i++)
  {   
    int aaa = int(map(i, 0, player.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);
    //line(x1, y1, z1, x2, y2, z2)
    line(i, 0 + player.left.get(i)*amp,0, i+1, 0 + player.left.get(i+1)*amp, 0);  
  }  
  popMatrix();
  
  //=========1.2
   pushMatrix();  
   rotateY(-PI/2); 
   rotateX(-PI*5/6);  
   scale(random(1.1, 1.2),1);  
    translate (0-width/2,0,0);  
  for(int i = 0; i < player.bufferSize()/12 - 1; i++)
  {   
    int aaa = int(map(i, 0, player.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);
    //line(x1, y1, z1, x2, y2, z2)
    line(i, 0 + player.right.get(i)*amp,0, i+1, 0 + player.right.get(i+1)*amp, 0);  
  }  
  popMatrix();
  
  //=========2
   pushMatrix();  
   rotateY(-PI/2);
   scale(random(1.1, 1.2),1);  
    translate (0-width/2, -10,0);  
    strokeWeight(1);
  for(int i = int(player.bufferSize()/10); i < int(player.bufferSize()/10)+player.bufferSize()/10 - 1; i++)
  {   
    int aaa = int(map(i, 0, player.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);
    //line(x1, y1, z1, x2, y2, z2)
    line(i, 0 + player.left.get(i)*amp,0, i+1, 0 + player.left.get(i+1)*amp, 0);  
  }  
  popMatrix();
  
   //=========2.2
   pushMatrix();  
   rotateY(-PI/2);
   rotateX(-PI/2);
   scale(random(1.1, 1.2),1);  
    translate (0-width/2, -10,0);  
    strokeWeight(1);
  for(int i = int(player.bufferSize()/10); i < int(player.bufferSize()/10)+player.bufferSize()/10 - 1; i++)
  {   
    int aaa = int(map(i, 0, player.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);
    //line(x1, y1, z1, x2, y2, z2)
    line(i, 0 + player.left.get(i)*amp,0, i+1, 0 + player.left.get(i+1)*amp, 0);  
  }  
  popMatrix();
  
  //=========3
   pushMatrix();
    rotateY(-PI/2);
   //scale(random(1.0, 1.1),1);  
   translate (0-width/2,0 - 50,0);
  for(int i = int(in.bufferSize()/10); i < int(in.bufferSize()/10)+in.bufferSize()/10 - 1; i++)
  {   
    int aaa = int(map(i, 0, in.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);    
    line(i, 0 + in.right.get(i)*amp/2, 0, i+1, 0 + in.right.get(i+1)*amp/2, 0);
  }
  popMatrix();
  
  //=========4
   pushMatrix();
    rotateY(-PI/2);
   scale(random(0.9, 1.0),1); 
  translate (0-width/2,0 - 20,0);
  for(int i = int(in.bufferSize()/10)*2; i < int(in.bufferSize()/10)*2+in.bufferSize()/10 - 1; i++)
  {   
    int aaa = int(map(i, 0, in.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);
    line(i,0 + in.left.get(i)*amp/4, 0, i+1, 0 + in.left.get(i+1)*amp/4,0 );
  }
  popMatrix();
  
  //=========5
  pushMatrix();
   rotateY(-PI/2);
  scale(random(1.1, 1.2),1);
   translate (0-width/2,0 + 20,0);
   for(int i = int(in.bufferSize()/10)*3; i < int(in.bufferSize()/10)*3+in.bufferSize()/10 - 1; i++)
  {      
    int aaa = int(map(i, 0, in.bufferSize()-1, 0, 255));
    stroke(230, 45, 94, aaa);   
    line(i, 0 + in.right.get(i)*amp/8, 0, i+1, 0 + in.right.get(i+1)*amp/8, 0);
  }
  popMatrix();
}

void detectBeat()
{
   beat.detect(in.mix);
  
  if ( beat.isOnset() )
  {
    //println("fuck");
    isBeat = true;
    amplitude = random(20, 80);
    curvColor = color(0, 99, 99, random(100, 200));
    pointColor =  color(random(0, 255), random(0, 255), random(0, 255), random(100, 200));
    
    float tmp = random(100);
    if(tmp < 25)
      background(219, 99, random(99), 255); 
  }
  else
  {
    isBeat = false;
  }
 
 

}

void waveR() 
{ 
  theta += 0.03;//0.05 
  r = theta; 
  r = sin(r)*amplitude; 
  r += 100; //100
} 

class PSystem  
{ 
  float th; 
  PVector ps_loc;   
  ArrayList particles;
  float zP; 

  public PSystem(PVector ps_loc, int num, float th)  
  { 
    this.ps_loc = ps_loc; 
    this.th = th; 
    particles = new ArrayList(); 
    for (int i = 0; i < num; i++) { 
      particles.add(new jParticle(new PVector(), new PVector(), new PVector(ps_loc.x, ps_loc.y,ps_loc.z), random(1.0, 70.0), i)); 
    } 
  } 

  void run() 
  { 
    update();     
    for (int i = particles.size()-1; i >= 0; i--) {         
      jParticle prt = (jParticle) particles.get(i); 
      prt.run(); 
      //      ps_loc.z = inz+i*10;
      prt.move(new PVector(ps_loc.x,ps_loc.y,ps_loc.z)); 
      
      
    }
    ellipse(ps_loc.x,ps_loc.y, 10, 10); 
  } 

  void update() 
  { 
    th += 0.0025f; 
    ps_loc.x = inx + r * cos(th); 
    ps_loc.y = iny + r * sin(th); 
    ps_loc.z = inz - r/2;
    ps_loc.x += random(-30.0f, 30.0f); 
    ps_loc.y += random(-30.0f, 30.0f); 
    //    ps_loc.z += random(-30.0f, 30.0f);

  } 

} 
class jParticle { 
  PVector loc; 
  PVector vel; 
  PVector acc; 
  float ms; 
  float counter; 
  float lengthVar;

  jParticle(PVector a, PVector v, PVector l, float ms_, float counter_) { 
    acc = a; 
    vel = v; 
    loc = l; 
    ms = ms_; 
    counter = counter_; 
    lengthVar = random (30);
  } 

  void run() { 
    update(); 
    render(); 
    //    print (counter);
  } 

  void update() { 
    vel.add(acc); 
    loc.add(vel); 
    acc = new PVector(); 
  } 

  void render() { 
    noStroke(); 
    fill(257, 28, 65, 10);
    float tenticleSize = ms/30 + 1; 
    strokeWeight(tenticleSize);
    //    ellipse(loc.x,loc.y, ms/8, ms/8); 
   
     
    stroke(pointColor);
    
    if(!isBeat)
    {
     stroke(238, 14, 85, 30); 
     //stroke(42,61,93,30); 
    }
    else
    { 
           stroke(pointColor);  //stroke(curvColor);
    }
    
    point(loc.x,loc.y,loc.z-ms*4); 
    
    if(!isBeat)
    {
      float al = map(vel.mag(), 0, 1.2, .1, 3);
      stroke(238, 14, 85, al);
   // stroke(42,61,93,al);  
    }
    else
    {
        stroke(pointColor);   
    }
//    stroke(238, 14, 85, 100);
    //print(counter%5 + " "); 
    //    if(ms >= 69.5) 
    noFill();
    strokeWeight(1.5);
    if(ms <= 5) {
      bezier(inx,iny,inz+70, loc.x - (inx-loc.x)/20,loc.y - (iny-loc.y)/20,inz+60,loc.x - (inx-loc.x)/3,loc.y - (iny-loc.y)/3,inz-10,loc.x,loc.y,loc.z + lengthVar);
       bezier(loc.x + (inx-loc.x)/1.5,loc.y + (iny-loc.y)/1.5,inz+20, loc.x - (inx-loc.x)/40,loc.y - (iny-loc.y)/40,inz+40,loc.x - (inx-loc.x)/3,loc.y - (iny-loc.y)/3,inz-10,loc.x,loc.y,loc.z + lengthVar);
    }
  }

  void move(PVector target) { 
    acc.add(steer(target)); 
  }     

  PVector getLocation() { 
    return loc; 
  }  

  PVector steer(PVector target) { 
    PVector steer; 
    PVector desired = PVector.sub(target,loc); 
    float d = desired.mag(); 
    desired.normalize(); 
    desired.mult(3.5f); 
    steer = PVector.sub(desired,vel); 
    steer.limit(3.0f); 
    steer.div(ms); 
    return steer; 
  } 
} 


boolean dump = false;
//boolean expodeGo = false;
void keyPressed()
{
  if (key == 'D' || key == 'd')
  {
    dump = !dump;
    if(dump)
    {
      if(sine == null)
      {
         // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
        sine = new SineWave(440, 0.5, out.sampleRate());
        // set the portamento speed on the oscillator to 200 milliseconds
        sine.portamento(200);    
        sine.setFreq(800);
        sine.setPan(0);
        // add the oscillator to the line out
       
        
      }
      player.pause();
       out.addSignal(sine);
    }
    else
    {
      out.removeSignal(sine);
       player.play();
    }
  } 
   else if (key == 'S' || key == 's') 
  {
     background(random(244), random(244), random(244), 100); 
  }
  else if (key == 'M' || key == 'm') 
  {
    player.play();
     
  }
}

void drawExpode()
{
  image(img, 0, 0);
}


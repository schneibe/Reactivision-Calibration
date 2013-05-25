import TUIO.*;
import java.util.*; 
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

void setup()
{
  size(800,600);
  noStroke();
  fill(0);
  
  loop();
  frameRate(30);
  //noLoop();
  
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  tuioClient  = new TuioProcessing(this);
  
  initCalibration();
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(0);
  
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
   
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(255);
     fill(0);
     pushMatrix();
     translate(tx(tobj),ty(tobj));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(255);
     text(""+tobj.getSymbolID(), tx(tobj), ty(tobj));
   }   
  
  if (!calibrated) drawCalibration(); 
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}





float a1,b1,c1,a3,b3,a2,b2,c2;

int calPoints = 0;
boolean calibrated = false;

PVector [] cal = new PVector[4];
PVector [] dots = new PVector[4];

void initCalibration()
{
  //dot is the original calibration image
  int calibInset = 50;
  dots[0] = new PVector( calibInset, calibInset ); //top left
  dots[1] = new PVector( width -calibInset, calibInset ); //top right
  dots[2] = new PVector( calibInset, height -calibInset ); //bot left
  dots[3] = new PVector( width -calibInset, height -calibInset); //bot right
  
  // if we already have some data, then we used the saved configuration
  String lines[] = loadStrings("calibration.txt");
  if(lines != null && lines.length == 8)
  {
    println("Loading calibration file...");
    b3 = float(lines[0]);
    b2 = float(lines[1]);
    a2 = float(lines[2]);
    c2 = float(lines[3]);
    a3 = float(lines[4]);
    b1 = float(lines[5]);
    a1 = float(lines[6]);
    c1 = float(lines[7]);
    calibrated = true;
    println("Done.");
  }
}

void keyPressed() 
{
  java.util.Vector tuioObjectList = tuioClient.getTuioObjects();
  
  // performs a new calibration
  if (key == 'n')
  {
    calibrated = false;
    calPoints = 0;
  }
  
  // save data points
  if (key == 'c')
  {
    if(tuioObjectList.size() > 0) 
    {
      TuioObject tobj = (TuioObject)tuioObjectList.elementAt(0);
      getCalibrationPoint(tobj.getScreenX(width), tobj.getScreenY(height));
    }
  }
}

void drawCalibration()
{
  int lineLength = 10;

  stroke( 255 );
  fill( 0 );
  ellipse( dots[calPoints].x, dots[calPoints].y, lineLength * 2, lineLength * 2 );
  line(   dots[calPoints].x - lineLength, dots[calPoints].y,
    dots[calPoints].x + lineLength, dots[calPoints].y );
  line(   dots[calPoints].x, dots[calPoints].y - lineLength,
    dots[calPoints].x, dots[calPoints].y + lineLength );
}

void getCalibrationPoint(int x, int y)
{
  if( calibrated == false )
  {
    cal[calPoints ++] = new PVector(x,y);

    if( calPoints == 4 )
    {
      if( calibrate() == 0 ) calibrated = true; 
      else calPoints = 0;
    }
  }
}

int calibrate()
{
  println( "running calibration" );


  float [][] matrix = { 
    { -1, -1, -1, -1, 0, 0, 0, 0 },
  
   {   -cal[0].x, -cal[1].x, -cal[2].x, -cal[3].x, 0, 0, 0, 0 },
   { -cal[0].y, -cal[1].y, -cal[2].y, -cal[3].y, 0,0,0,0 },
   { 0,0,0,0,-1,-1,-1,-1 },
   { 0,0,0,0, -cal[0].x, -cal[1].x, -cal[2].x, -cal[3].x },
   { 0,0,0,0, -cal[0].y, -cal[1].y, -cal[2].y, -cal[3].y },
   { cal[0].x * dots[0].x, cal[1].x * dots[1].x, cal[2].x * dots[2].x, cal[3].x * dots[3].x, cal[0].x * dots[0].y, cal[1].x * dots[1].y, cal[2].x * dots[2].y, cal[3].x * dots[3].y },
   { cal[0].y * dots[0].x, cal[1].y * dots[1].x, cal[2].y * dots[2].x, cal[3].y * dots[3].x, cal[0].y * dots[0].y, cal[1].y * dots[1].y, cal[2].y * dots[2].y, cal[3].y * dots[3].y },
    };
  
  
  float [] bb = { -dots[0].x, -dots[1].x, -dots[2].x, -dots[3].x, -dots[0].y, -dots[1].y, -dots[2].y, -dots[3].y };
  
  // gauß-elimination
  
  for( int j = 1; j < 4; j ++ )
  {
  
     for( int i = 1; i < 8; i ++ )
     {
        matrix[i][j] = - matrix[i][j] + matrix[i][0];
     }
     bb[j] = -bb[j] + bb[0];
     matrix[0][j] = 0;
  
  }
  
  
    for( int i = 2; i < 8; i ++ )
    {
      matrix[i][2] = -matrix[i][2] / matrix[1][2] * matrix[1][1] + matrix[i][1];
    }
  bb[2] = - bb[2] / matrix[1][2] * matrix[1][1] + bb[1];
  matrix[1][2] = 0;
  
  
    for( int i = 2; i < 8; i ++ )
    {
      matrix[i][3] = -matrix[i][3] / matrix[1][3] * matrix[1][1] + matrix[i][1];
    }
  bb[3] = - bb[3] / matrix[1][3] * matrix[1][1] + bb[1];
  matrix[1][3] = 0;
  
  
  
    for( int i = 3; i < 8; i ++ )
    {
      matrix[i][3] = -matrix[i][3] / matrix[2][3] * matrix[2][2] + matrix[i][2];
    }
  bb[3] = - bb[3] / matrix[2][3] * matrix[2][2] + bb[2];
  matrix[2][3] = 0;
  
  println( "var57, var56, var55");
  println( matrix[4][6] + " " + matrix[4][5] + " " + matrix[4][4] );
  
  for( int j = 5; j < 8; j ++ )
  {
    for( int i = 4; i < 8; i ++ )
    {
       matrix[i][j] = -matrix[i][j] + matrix[i][4];
    }
    bb[j] = -bb[j] + bb[4];
    matrix[3][j] = 0;
  }
  
  
  for( int i = 5; i < 8; i ++ )
    {
      matrix[i][6] = -matrix[i][6] / matrix[4][6] * matrix[4][5] + matrix[i][5];
    }
  
  bb[6] = - bb[6] / matrix[4][6] * matrix[4][5] + bb[5];
  matrix[4][6] = 0;
  
  
  for( int i = 5; i < 8; i ++ )
    {
      matrix[i][7] = -matrix[i][7] / matrix[4][7] * matrix[4][5] + matrix[i][5];
    }
  bb[7] = - bb[7] / matrix[4][7] * matrix[4][5] + bb[5];
  matrix[4][7] = 0;
  
  
  for( int i = 6; i < 8; i ++ )
    {
      matrix[i][7] = -matrix[i][7] / matrix[5][7] * matrix[5][6] + matrix[i][6];
    }
  bb[7] = - bb[7] / matrix[5][7] * matrix[5][6] + bb[6];
  matrix[5][7] = 0;
  
  
  
  matrix[7][7] = - matrix[7][7]/matrix[6][7]*matrix[6][3] + matrix[7][3];
  bb[7] = -bb[7]/matrix[6][7]*matrix[6][3] + bb[3];
  matrix[6][7] = 0;
  
  
  println( "data dump" );
  for( int i = 0; i < 8 ; i ++ )
  {
     for( int j= 0; j < 8 ; j ++ )
     {
       print( matrix[i][j] + "," );
     }
     println("");
  }
  
  println( "bb" );
   for( int j= 0; j < 8 ; j ++ )
   {
     print( bb[j] + "," );
   }
  
  println("");
  
  b3 =  bb[7] /matrix[7][7];
  b2 = (bb[6]-(matrix[7][6]*b3+matrix[6][6]*a3))/matrix[5][6];
  a2 = (bb[5]-(matrix[7][5]*b3+matrix[6][5]*a3+matrix[5][5]*b2))/matrix[4][5];
  c2 = (bb[4]-(matrix[7][4]*b3+matrix[6][5]*a3+matrix[5][4]*b2+matrix[4][4]*a2))/matrix[3][4];
  a3 = (bb[3]-(matrix[7][3]*b3))/matrix[6][3];
  b1 = (bb[2]-(matrix[7][2]*b3+matrix[6][2]*a3+matrix[5][2]*b2+matrix[4][2]*a2+matrix[3][2]*c2))/matrix[2][2];
  a1 = (bb[1]-(matrix[7][1]*b3+matrix[6][1]*a3+matrix[5][1]*b2+matrix[4][1]*a2+matrix[3][1]*c2+matrix[2][1]*b1))/matrix[1][1];
  c1 = (bb[0]-(matrix[7][0]*b3+matrix[6][0]*a3+matrix[5][0]*b2+matrix[4][0]*a2+matrix[3][0]*c2+matrix[2][0]*b1+matrix[1][0]*a1))/matrix[0][0];
  
  if( Float.isNaN( b3 ) ) return 1;
  if( Float.isNaN( b2 ) ) return 1;
  if( Float.isNaN( a2 ) ) return 1;
  if( Float.isNaN( c2 ) ) return 1;
  if( Float.isNaN( a3 ) ) return 1;
  if( Float.isNaN( b1 ) ) return 1;
  if( Float.isNaN( a1 ) ) return 1;
  if( Float.isNaN( c1 ) ) return 1;
  
  println( "calibrated OK" );
  
  String data = ""+b3+";"+b2+";"+a2+";"+c2+";"+a3+";"+b1+";"+a1+";"+c1;
  
  saveStrings("calibration.txt", split(data, ';'));
  
  return 0;
}


// transform coordinates based on calibration
int tx(TuioObject tobj) { return  int((a1 * tobj.getScreenX(width) + b1 * tobj.getScreenY(height) + c1 ) / (a3 * tobj.getScreenX(width) + b3 * tobj.getScreenY(height) + 1 )); }
int ty(TuioObject tobj) { return  int((a2 * tobj.getScreenX(width) + b2 * tobj.getScreenY(height) + c2 ) / (a3 * tobj.getScreenX(width) + b3 * tobj.getScreenY(height) + 1 )); }

# REACTIVISION-CALIBRATION

Performs a four-points calibration for the fiducials used in the Reactivision framework (http://reactivision.sourceforge.net/). This code works for Processing 2.x.

I have been frustrated for a while with the calibration procedure provided in reactivision. Here is a simpler approach.

## Installation
- either modify the two files provided
- or copy `Calibration.pde` file to your project folder; then add a global Calibration object, 
  initialize it in `setup`, and call it in `draw`. For example:

```
Calibration calibration;
    
void setup() {
    calibration = new Calibration();
    // do the rest of your setup
}
    
void draw() {
    if(!calibration.calibrated) calibration.draw();
    // do the rest of your drawing
}
```

## Usage
-  install reactivision in your library folder
-  Launch the script; position a fiducial on the target located on top left corner of the screen; press 'c'
-  repeat for each corner of the screen

This will save your values to the "calibration.txt" file. If you want to start a new calibration, press 'n' on your keyboard. So you don't have to calibrate your system every time you launch your application. The position of your tags should now be properly calibrated. Use the functions `tx(tobj)` and `ty(tobj)` in your code to get the correct coordinates. See [this thread](https://sourceforge.net/projects/reactivision/forums/forum/515398/topic/8278640) for more information. Code adapted from [Jochen Zaunert](http://www.zaunert.de/jochenz/wii/).

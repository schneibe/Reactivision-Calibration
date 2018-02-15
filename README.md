# REACTIVISION-CALIBRATION

Performs a four-points calibration for the fiducials used in the Reactivision framework (http://reactivision.sourceforge.net/). This code works for Processing 2.x.

I have been frustrated for a while with the calibration procedure provided in reactivision. Here is a simpler approach.

## Installation
- either modify the two files provided
- or copy the "Calibration.pde" file to your folder; then
    -  add a global object Calibration: "Calibration calibration;"
    - init the object in your setup function "calibration = new Calibration();"
    - call the calibration procedure in your draw function: "if(!calibration.calibrated) calibration.draw();"

## Procedure
-  install reactivision in your library folder
-  Launch the script; position a fiducial on the target located on top left corner of the screen; press 'c'
-  repeat for each corner of the screen

This will save your values to the "calibration.txt" file. If you want to start a new calibration, press 'n' on your keyboard. So you don't have to calibrate your system every time you launch your application.


The position of your tags should now be properly calibrated. Use the functions tx(tobj) and ty(tobj) in your code to get the correct coordinates.

See this thread for more information (https://sourceforge.net/projects/reactivision/forums/forum/515398/topic/8278640)

Code adapted from Jochen Zaunert (http://www.zaunert.de/jochenz/wii/).

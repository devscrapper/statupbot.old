Download and install GraphicsMagick (GraphicsMagick-1.3.12-Q8): 
http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick-binaries/1.3.12/GraphicsMagick-1.3.12-Q8-windows-dll.exe/download

Set the path of GraphicsMagick correctly in set_graphicsmagick.bat on Windows and set_graphicsmagick.sh on Linux/Mac. 
Example:
Change
set GM=C:\Programs\GraphicsMagick\gm
to
set GM=D:\<Your_Path_To>\GraphicsMagick\gm

Try running snapshot_new.sah on http://sahi.co.in/demo/training/

GraphicsMagick is needed for comparing images and trimming images.
APIs _assertSnapShot, _compareImages, _assertEqualImages need GraphicsMagick
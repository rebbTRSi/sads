REM RBDS compilescript
REM rebb/trsi 2016

@echo off
 cls
 rgbasm -o%1.obj  -iinc/ src/%1.asm
 if errorlevel 1 goto end
 rgblink -orom/%1.gb %1.obj
 if errorlevel 1 goto end
 rgbfix -pff -v -t%1 rom/%1.gb

 :end
del *.obj
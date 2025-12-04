# Fortran

Fortran proposed more difficulty as the x86_64 .exe didnt seem to be installable via MSYS MinGW_64 which is what I used to obtain the other languages in this repo. This made linking libraries difficult as I am on a 64 bit system, therefore, I decided to leave this one for later development.

Instead the program creates `.ppm` frames which are then glued together with magick for now as both
`sdl` and `gdi` where not working on my windows machined

Compiled with: `gfortran snow.f90 -o snow.exe`

Gif made with: `magick convert -delay 7 frames/frame_*.ppm animation.gif`

### Also in here

test.exe is the attempt to make snow with ascii characters.

### Nota bene

This is not final and I will revisit fortran and attempt it properly in the future.

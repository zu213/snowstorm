 # TBC Snow languages

 I have left two languages undeveloped due to compatibiilty issues

 ### Ada
 The ada code aims to just display a basic window, this compiles, however, it never opesn a new window when run, it is eternally waiting for a system message as the window registration fails with error code 87. This is due to the fact its calling external windows functions that are written in C such as `RegisterClassA` and `CreateWindowEx`. These classes provide serveral issues as they want C char arrays whicha re difficult ot produce in Ada due to its restrictive nature on types. Hopefully, this code could be completed for my local system in the future, but it may make more sense to attempt ada development on Linux.

 Compiled with: `C:\msys64\mingw64\bin\gnatmake.exe snow.adb -LC:/msys64/mingw64/lib`

 ### Fortran
 Fortran proposed more difficulty as the x86_64 .exe didnt seem to be installable via MSYS MinGW_64 which is what I used to obtain the other languages in this repo. This made linking libraries difficult as I am on a 64 bit system, therefore, I decided to leave this one for later development.

 Compiled with: `gfortran hello_world.f90 -o hello_world.exe`
 
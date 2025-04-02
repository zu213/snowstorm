 # Ada
 Ada provided much challenge due to `RegisterClass` not erroing but also not working with `CreateWindowEx`, instead, I ended up using a `STATIC` window. It again relies on Windows GDI library and setting up C API classes for such. It uses `gnat` for compilation and is built for x64 Windows machines. It also crucially ontop of GDI uses the mingw-w64-x86_64-crt and mingw-w64-x86_64-windows-default-manifest libraries  
   
 Compiled with: `C:\msys64\mingw64\bin\gnatmake.exe snow.adb -LC:/msys64/mingw64/lib -largs -lgdi32`
-- run "gnatmake hello.adb" to compile the program

with Ada.Text_IO;  -- Import Ada's standard text I/O library

procedure Hello is
begin
   Ada.Text_IO.Put_Line("Hello, World!");  -- Print "Hello, World!" to the console
end Hello;
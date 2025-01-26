 # D
 D lang uses the dub packages system so that I can utilise gdi32 and user32 without need for linking, it is relatively high-level compared to the rest of this repo. Notably, I had to add a manual timer to send messages and a thread to sleep to the D lang code as without it would only animate on user inputs instead of automatically.

 Compile/Build with: `dub build`/`run` (in the snow subfolder)
 
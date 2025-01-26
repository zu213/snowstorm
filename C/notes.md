 # C
 Snow in C was probably the easiest to implement, it made use of the windows message loop to animate the snow re-rendering whenever a new message was sent. It notably used `CreateWindowEx` which other languages call in such as ada and fortran.
 
 There are many ways to approach this, however, as you'll see throughout the repo I opt to use GDI where possible for the lowest level graphics experience.

 Compile with: `gcc snow.c snow -lgdi32`
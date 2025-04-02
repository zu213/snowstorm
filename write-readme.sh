#!/bin/bash

directories=(
    "./Rust"
    "./assembly"
    "./C"
    "./D"
    "./C++"
    "./ada"
)

srcs=(
    "./Rust/snow/src/main.rs"
    "./assembly/snow.asm"
    "./C/snow.c"
    "./D/snow/source/app.d"
    "./C++/snow.cpp"
    "./ada/snow.adb"

)

# Clear file
echo "# Snowstorm" > README.md
echo "Simple snow's implemented in different languages as a test for basic graphic manipulation." >> README.md
echo "" >> README.md
echo " ### Directories sizes (in bytes):" >> README.md

for directory in "${directories[@]}"
do
    echo "$directory"
    echo "$(du -sb $directory)  " >> README.md
done

echo "" >> README.md
echo " ### Source file sizes (in bytes):" >> README.md

for file in "${srcs[@]}"
do
    echo "$file"
    echo "$(du -sb $file)  " >> README.md
done

echo "" >> README.md
echo " ## Gifs:" >> README.md
echo " **Importantly, converting to .gif kills the framerate, .mkv's can be found in /videos**" >> README.md

echo "#### Rust:" >> README.md
echo "" >> README.md
echo "<img src="gifs/rust.gif" alt="snow" width="600"/>" >> README.md
echo "" >> README.md

echo "#### D:" >> README.md
echo "" >> README.md
echo "<img src="gifs/d.gif" alt="snow" width="600"/>" >> README.md
echo "" >> README.md

echo "#### C:" >> README.md
echo "" >> README.md
echo "<img src="gifs/c.gif" alt="snow" width="600"/>" >> README.md
echo "" >> README.md

echo "#### Assembly:" >> README.md
echo "" >> README.md
echo "<img src="gifs/assembly.gif" alt="snow" width="600"/>" >> README.md
echo "" >> README.md
#!/bin/bash

directories=(
    "./Rust"
    "./assembly"
    "./C"
)

srcs=(
    "./Rust/snow/src/main.rs"
    "./assembly/snow.asm"
    "./C/snow.c"
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

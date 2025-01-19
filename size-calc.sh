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
echo "Directories sizes:" > sizes.txt

for directory in "${directories[@]}"
do
    echo "$directory"
    du -sb "$directory" >> sizes.txt
done

echo "" >> sizes.txt
echo "Source file sizes:" >> sizes.txt

for file in "${srcs[@]}"
do
    echo "$file"
    du -sb "$file" >> sizes.txt
done

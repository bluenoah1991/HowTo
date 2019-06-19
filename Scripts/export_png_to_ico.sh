#!/bin/bash

# https://github.com/Pythonity/icon-font-to-png
# icon-font-to-png --css font-awesome.css --ttf fa-brands-400.ttf --size 512 blue ALL

if [ ! -d "resized" ]; then
    mkdir resized
fi

if [ ! -d "converted" ]; then
    mkdir converted
fi

for fullname in $1/*.png; do
    size_array=( 512 256 128 48 32 16 )
    filename=${fullname##*/}
    basename=${filename%.*}
    for size in "${size_array[@]}"; do
        convert $fullname -resize ${size}x${size} resized/$basename-$size.png
    done
    convert resized/${basename}-{256,48,32,16}.png converted/${basename}.ico
    echo "Exporting icon '$basename' as '$basename.ico'(256,48,32,16 pixels)"
done

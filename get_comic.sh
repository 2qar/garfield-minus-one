#!/bin/bash
# Download today's Garfield strip & remove third panel :)

today=$1
wget -q https://d1ejxu6vysztl5.cloudfront.net/comics/garfield/$(date +%Y)/$today.gif -O garfield.png
size=$(file garfield.png | cut -d',' -f3 | cut -c 2-)
width=$(echo $size | cut -d' ' -f1)
height=$(echo $size | cut -d' ' -f3)

if (( width == 1200 && height < 400)); then
    convert garfield.png -crop 796x$height out.png
    rm garfield.png
    rm out-1.png
    mv out-0.png $today.png
    echo $today.png
else
    echo BAD SIZE
fi

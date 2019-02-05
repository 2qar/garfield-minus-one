#!/bin/bash
# Download today's Garfield strip & remove third panel :)

today=$(date +%Y-%m-%d)
wget -q https://d1ejxu6vysztl5.cloudfront.net/comics/garfield/$(date +%Y)/$today.gif -O garfield.png
size=$(file garfield.png | cut -d',' -f3 | cut -c 2-)

if [ "$size" == "1200 x 357" ]; then
    convert garfield.png -crop 796x357 out.png
    rm garfield.png
    rm out-1.png
    mv out-0.png $today.png
    echo $today.png
else
    echo BAD SIZE
fi

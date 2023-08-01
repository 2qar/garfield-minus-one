#!/bin/bash
# Remove the third panel from today's Garfield comic and put it on Twitter

set -eu

NORMAL_HEIGHT=258

comic_url="$(curl -s "https://www.gocomics.com/garfield/$(date +%Y/%m/%d)" | egrep -o -m1 "https://assets\.amuniversal\.com/[0-9|a-z]{32}")"
if [ -z "$comic_url" ]; then
	echo "no comic for today, i guess"
	exit 1
fi

TMP_GARF="/tmp/garf"
wget -q "$comic_url" -O $TMP_GARF
size=$(identify -ping -format '%w %h' $TMP_GARF)
width=$(echo $size | cut -d' ' -f1)
height=$(echo $size | cut -d' ' -f2)
if (( height > NORMAL_HEIGHT)); then
    echo "BAD SIZE"
    exit 1
fi
COMIC_PATH="/tmp/garf.png"
convert $TMP_GARF -crop $(( width - width / 3 ))x$height+0+0 +repage $COMIC_PATH

media_id=$(twurl -X POST -H upload.twitter.com "/1.1/media/upload.json" --file $COMIC_PATH --file-field media | jq -r .media_id_string)
twurl "/2/tweets" \
	-d "{ \"text\": \"garfield without the third panel\", \"media\": { \"media_ids\": [\"$media_id\"] } }" \
	--header "Content-Type: application/json"
rm $TMP_GARF

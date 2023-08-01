#!/bin/bash
# Remove the third panel from today's Garfield comic and put it on Twitter

set -eu

TMP_GARF="/tmp/garf.gif"
NORMAL_HEIGHT=258

comic_url="$(curl -s "https://www.gocomics.com/garfield/$(date +%Y/%m/%d)" | egrep -o -m1 "https://assets\.amuniversal\.com/[0-9|a-z]{32}")"
if [ -z "$comic_url" ]; then
	echo "no comic for today, i guess"
	exit 1
fi

wget -q "$comic_url" -O $TMP_GARF
size=$(identify -ping -format '%w %h' $TMP_GARF)
width=$(echo $size | cut -d' ' -f1)
height=$(echo $size | cut -d' ' -f2)
if (( height > NORMAL_HEIGHT)); then
    echo "BAD SIZE"
    exit 1
fi
convert $TMP_GARF -crop $(( width - width / 3 ))x$height+0+0 +repage $TMP_GARF

total_bytes=$(wc -c $TMP_GARF | cut -d' ' -f1)
media_id=$(twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=INIT&media_type=image/gif&total_bytes=$total_bytes" | jq -r .media_id_string)
twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=APPEND&media_id=$media_id&segment_index=0" --file $TMP_GARF --file-field "media"
twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=FINALIZE&media_id=$media_id"
twurl "/2/tweets" \
	-d "{ \"text\": \"garfield without the third panel\", \"media\": { \"media_ids\": [\"$media_id\"] } }" \
	--header "Content-Type: application/json"
rm $TMP_GARF

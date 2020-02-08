#!/bin/bash
# Remove the third panel from today's Garfield comic and put it on Twitter

TMP_GARF="/tmp/garf.gif"

wget -q https://d1ejxu6vysztl5.cloudfront.net/comics/garfield/$(date +%Y)/$(date +%Y-%m-%d).gif -O $TMP_GARF
size=$(file $TMP_GARF | cut -d',' -f3 | cut -c 2-)
width=$(echo $size | cut -d' ' -f1)
height=$(echo $size | cut -d' ' -f3)
if ! (( width == 1200 && height < 400)); then
    echo BAD SIZE
    exit 1
fi
convert $TMP_GARF -crop 796x$height+0+0 +repage $TMP_GARF

total_bytes=$(wc -c $TMP_GARF | cut -d' ' -f1)
media_id=$(twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=INIT&media_type=image/gif&total_bytes=$total_bytes" | jq -r .media_id_string)
twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=APPEND&media_id=$media_id&segment_index=0" --file $TMP_GARF --file-field "media"
twurl -H upload.twitter.com "/1.1/media/upload.json" -d "command=FINALIZE&media_id=$media_id"
twurl "/1.1/statuses/update.json" -d "status=garfield without the third panel&media_ids=$media_id"

rm $TMP_GARF

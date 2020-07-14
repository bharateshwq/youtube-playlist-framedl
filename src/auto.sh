#!/bin/bash
read -p 'playlist Id': playID;
read -p 'API KEY': apikey;
read -p 'where to freeze frame ': timestampMin;
timestampSec=00
timestamp=${timestampMin}:${timestampSec}
#timestamp="1:40"
curl "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=5000&playlistId=${playID}&key=${apikey}" | cat > videoID.JSON

next_page=$(cat videoID.JSON | jq '.nextPageToken' | sed 's/"//g')
if [ "$next_page" = "null" ]
then 
	echo "failed to download file"
	
else
while [ "$next_page" != "null" ]
do
    cat videoID.JSON | jq '.items'|jq -r '.[].contentDetails.videoId'|cat > listlink.data
	NUM=1;
	while [ $NUM -le 50 ]
	do
		cleanVideoID=$(sed "${NUM}q;d" listlink.data)
	echo "https://www.youtube.com/watch?v=${cleanVideoID}" | cat > videoURL 
	cat videoID.JSON | jq '.items' | jq -r '.[].contentDetails.videoPublishedAt' | cat > time
	sed -i 's/T.*//g' time
	cat videoID.JSON | jq '.items' | jq -r '.[].snippet.title' | cat > title
	nametitle=$(sed "${NUM}q;d" title)
    nametime=$(sed "${NUM}q;d" time)
    name="${nametime} | ${nametitle}"'.jpeg'
    
    URL=$(sed "1q;d" videoURL)
    #echo "$name"
    while :
	ffmpeg -ss "$timestamp" -i $(youtube-dl -f 137 --get-url "$URL") -vframes 1 -q:v 2 './frames/'"${name}";
	faceDetected=$(python3 facedetect.py ./frames/"${name}")
	
	echo "-----------------------$name--------------------"
	if [ "$faceDetected" = "1" ]
	then
		break;
	else 
		rm ./frames/"${name}"
		if [ $timestampSec = 60 ]
		then
			((timestampMin++))
			 timestampSec=0
		 else
		((timestampSec+=5))	
  		timestamp=${timestampMin}:${timestampSec}
		fi
	fi 
do
	echo "DONE-----------------------$name--------------------DONE"
done

	((NUM++))
        done
    curl "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=5000&pageToken=$next_page&playlistId=$playID&key=$apikey" | cat > videoID.JSON
	next_page=$(cat videoID.JSON | jq '.nextPageToken' | sed 's/"//g')
done
fi
echo done

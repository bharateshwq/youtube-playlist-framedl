#!/bin/bash
read -p 'playlist Id': playID;
read -p 'API KEY': apikey;
read -p 'where to freeze frame ': timestampMin;
mkdir frames
mkdir finalframes
timestampMin=0
timestampSec=0
timestamp=${timestampMin}:${timestampSec}
count=0
down=$(cat /sys/class/net/wlp2s0/carrier_down_count) 
up=$(cat /sys/class/net/wlp2s0/carrier_up_count)
#timestamp="1:40"
while [ $( cat /sys/class/net/wlp2s0/carrier_down_count ) -gt $down ]
do 
	echo "xxxxxxxxxxxxxxxxxxxxINTERNET DOWNxxxxxxxxxxxxxxxxxxxxxxxx"
	if [[ $( cat /sys/class/net/wlp2s0/carrier_up_count ) -gt $up ]]
	then

		down=$(cat /sys/class/net/wlp2s0/carrier_down_count) 
		up=$(cat /sys/class/net/wlp2s0/carrier_up_count)
		break;
	fi
done
curl "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=5000&playlistId=${playID}&key=${apikey}" | cat > videoID.JSON

next_page=$(cat videoID.JSON | jq '.nextPageToken' | sed 's/"//g')
if [ "$next_page" = "null" ]
then 
	echo "___________________________FAILED TO DOWNLOAD________________________"
	
else
while [ "$next_page" != "null" ]
do
timestampMin=0
timestampSec=0
timestamp=${timestampMin}:${timestampSec}
    cat videoID.JSON | jq '.items'|jq -r '.[].contentDetails.videoId'|cat > listlink.data
	NUM=1;
	while [ $NUM -le 50 ]
	do
	if [ ! $count -le 1 ]
	then
	touch './finalframes/'"${name}"
	fi
	count=0
	cleanVideoID=$(sed "${NUM}q;d" listlink.data)
		
	echo "https://www.youtube.com/watch?v=${cleanVideoID}" | cat > videoURL 
	cat videoID.JSON | jq '.items' | jq -r '.[].contentDetails.videoPublishedAt' | cat > time
	sed -i 's/T.*//g' time
	cat videoID.JSON | jq '.items' | jq -r '.[].snippet.title' | cat > title
	nametitle=$(sed "${NUM}q;d" title)
    nametime=$(sed "${NUM}q;d" time)
    name="${nametime} | ${nametitle}"'.jpeg'
    faceDetected=0
    URL=$(sed "1q;d" videoURL)
	timestampMin=0
	timestampSec=0
    #echo "$name"
	
    while [ $count -le 2 ]
	do
	while [ $( cat /sys/class/net/wlp2s0/carrier_down_count ) -gt $down ]
	do 
	echo "xxxxxxxxxxxxxxxxxxxxINTERNET DOWNxxxxxxxxxxxxxxxxxxxxxxxx"
	if [[ $( cat /sys/class/net/wlp2s0/carrier_up_count ) -gt $up ]]
	then
		down=$(cat /sys/class/net/wlp2s0/carrier_down_count) 
		up=$(cat /sys/class/net/wlp2s0/carrier_up_count)
		break;
	fi
	done
	out='./finalframes/'"${name}"
	
	if [ ! -f "$out" ] && [[ ! "$name" == *"/"* ]]
	then
	ffmpeg -y -ss "$timestamp" -i $(youtube-dl -f best --get-url "$URL") -vframes 1 -q:v 2 './frames/'"${name}" ;
	faceDetected=0
	faceDetected=$(python3 facedetect2.py "${name}")
	else
		faceDetected=1
	fi
	if [ "$faceDetected" = "404" ]
	then
		echo "file not found"
	fi
	
	
	if [ "$faceDetected" = "1" ] 
	then
		count=1
		echo "FACE FOUND--------------$name--------------FACE FOUND"
		timestampMin=0
		timestampSec=0
		break;
		
	else 
		if [ $timestampSec -gt 45 ]
		then
			((timestampMin++))
			 timestampSec=0
			 ((++count))
		 else
		((timestampSec+=10))	
		fi
  		timestamp=${timestampMin}:${timestampSec}
	fi 
	echo "FINDING-----------------------$name--------$timestamp------------FINDING"
	
    done
	if [ ! -z $cleanVideoID ] 
		then
		((NUM++))
		fi	
done
    curl "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=5000&pageToken=$next_page&playlistId=$playID&key=$apikey" | cat > videoID.JSON
	next_page=$(cat videoID.JSON | jq '.nextPageToken' | sed 's/"//g')
done
fi
echo done

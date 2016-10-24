#!/bin/bash
VSRC=$1
FILENAME=$(basename $VSRC)
echo $FILENAME
#ffmpeg -i $VSRC -codec:v libx264 -profile:v high -preset slow -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=-1:480 -threads 0 -codec:a libfdk_aac -b:a 128k output_file.mp4
ffmpeg -i $VSRC -vf scale=1280:720 ${FILENAME/1080p/720p} &
ffmpeg -i $VSRC -vf scale=854:480 ${FILENAME/1080p/480p} &
ffmpeg -i $VSRC -vf scale=640:360 ${FILENAME/1080p/360p} &
ffmpeg -i $VSRC -vf scale=426:240 ${FILENAME/1080p/240p} &
wait

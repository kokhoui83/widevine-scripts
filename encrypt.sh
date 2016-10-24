#!/bin/bash
SIGNER="widevine_test"
KEY_SERVER_URL="https://license.uat.widevine.com/cenc/getcontentkey/widevine_test"
AES_SIGNING_KEY="1ae8ccd0e7985cc0b6203a55855a1034afc252980e970ca90e5202689f947ab9"
AES_SIGNING_IV="d58ce954203b7c9a9a9d467f59839249"
OUTPUT_PATH='./tmp'

VSRC=$1

## Function to package stream file
packageStream() {
  filePath=$1
  type=$2

  filename=$(basename $filePath)
  contentId=$(echo -n filename | xxd -p)

  packager \
    input=$filePath,stream=$type,output=$OUTPUT_PATH/encrypt-$filename \
  --profile on-demand \
  --enable_widevine_encryption \
  --key_server_url $KEY_SERVER_URL \
  --content_id $contentId \
  --signer $SIGNER \
  --aes_signing_key $AES_SIGNING_KEY \
  --aes_signing_iv $AES_SIGNING_IV \
  --output_media_info &
}

## Process video
for filePath in $VSRC*.mp4; do
  filename=$(basename $filePath)
  file=$OUTPUT_PATH/"encrypt-"$filename".media_info"

  if [ ! -f $file ]; then
    echo "File not encrypted: "$filename
    packageStream $filePath video
  fi
done

## Process audio
for filePath in $VSRC*.m4a; do
  filename=$(basename $filePath)
  file=$OUTPUT_PATH/"encrypt-"$filename".media_info"

  if [ ! -f $file ]; then
    echo "File not encrypted: "$filename
    packageStream $filePath audio
  fi
done

## Process subtitles
for filePath in $VSRC*.vtt; do
  filename=$(basename $filePath)
  file=$OUTPUT_PATH/"encrypt-"$filename".media_info"

  if [ ! -f $file ]; then
    echo "File not encrypted: "$filename
    packageStream $filePath text
  fi
done

## wait for all stream packaging to be done
wait

## Generate MPD file
for filePath in ./tmp/*.media_info; do
  if [[ -z $input ]]; then
    input=$filePath
  else
    input=$input","$filePath
  fi
done

mpd_generator \
--input $input \
--output $OUTPUT_PATH/"output.mpd"

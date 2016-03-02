#!/bin/bash

# search for programs
MP3_INFO_CMD=`which mp3info`
LLTAG_CMD=`which lltag`

if [ -z "$MP3_INFO_CMD" -o -z "$LLTAG_CMD" ]
then
    echo "Please ensure you have installed <mp3info> and <lltag>"
    exit
fi


if [ $# -eq 0 ]
then
    echo "Usage: $0 mp3file [ mp3file .... mp3file ]"
    exit
fi


for MP3_FILE in $*
do

    MP3_INFO_CMD "$MP3_FILE" > /dev/null 2>&1
    
    if [ $? -ne 0 ]
    then
        # untagged file found
	echo -en "Auto-tagging file [$MP3_FILE]..."
	lltag -G --yes "$MP3_FILE" > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
	    echo -en "DONE!\n"
	else
	    echo -en "ERROR!\n"
	fi
    fi
    
done

#!/bin/sh

EMACS=$(which emacs)
DIR=$1


if [ -z "$EMACS" ]; then
    echo "Emacs not found!"
    exit 1
fi



if [ -z "$DIR" ]; then
    DIR=$(pwd)
fi

if [ ! -d "$DIR" ]; then
    echo "Please specify the directory to work in"
    exit 2
fi

echo "Searching for org files in [$DIR]"
cd $DIR
for forg in *.org
do
    echo "Converting [$forg] ..."
    $EMACS --batch $forg -f org-beamer-export-to-pdf > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "ok!"
    else
        echo "KO!"
    fi
done

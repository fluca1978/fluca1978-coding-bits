#!/bin/sh

if [ ! -f "$1" -o ! -r "$1" ]
then
    echo "Il primo parametro deve essere un file leggibile!"
    exit 1
fi


if [ -z "$2" ]
then
    dirname="."
else
    dirname="$2"
fi

if [ ! -d "$dirname" -o ! -w "$dirname" ]
then
    echo "Il secondo parametro deve essere una directory scrivibile!"
    exit 2
fi

fname=$( basename "$1" )
fname="${fname}."$( date +'%Y_%m_%d__%H_%M' )
cp -v "$1" "$dirname/${fname}"

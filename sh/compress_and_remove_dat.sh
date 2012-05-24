#!/bin/bash

# Compress all the .dat files and optional files
# in the current directory or a directory specified
# as first argument.
# If a file (and its dependencies) have been compressed, then
# the file is removed.

if [ $# -eq 1 ]
then
    echo "Entering directory $1"
    cd $1
else
    echo "Working in the current directory"
fi


for a in *.dat
do
    A=`basename $a ".dat"`
    tar cjvf $A.tar.bz2 $A*
    if [ $? -eq 0 ]
    then
	rm $A*
    else
	echo "Problem with files $A"
    fi
done
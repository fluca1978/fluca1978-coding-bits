#!/bin/sh

# A Kernel Debugger launching script.
# Usage:
# start_kgdb.sh [dump-number  [dump-dir] ]
#
# example:
# start_kgdb.sh 0 /usr/crash
#
# If not specified the dump number is assumed 0, the dump directory
# is extracted from /etc/rc.conf.


# check I'm root
ID=`id -u"`
if [ $ID -ne 0 ]
then
    echo "Sorry, you need to be root to execute this script!"
    exit
fi


# first argument is the dump number or zero by default
if [ $# -gt 0 ]
then
    DUMP_NUMBER=$1
else
    DUMP_NUMBER=0
fi

# second argument is the dump directory or
# the directory defined in the rc.conf file
if [ $# -gt 1 ]
then
    DUMP_DIR=$2
else
    . /etc/rc.conf
    if [ ! -z "$dumpdir" ]
    then
	DUMP_DIR=$dumpdir
    else
	DUMP_DIR=/var/crash
    fi

fi

echo "Debugging for dump number $DUMP_NUMBER in $DUMP_DIR"

# build files for core and info
DUMP_FILE_CORE=${DUMP_DIR}/vmcore.${DUMP_NUMBER}
DUMP_FILE_INFO=${DUMP_DIR}/info.${DUMP_NUMBER}

# check that files exist
if [ ! -f $DUMP_FILE_CORE -o ! -f $DUMP_FILE_INFO ]
then
    echo "Cannot find dump core/info files!"
    echo "I was looking for $DUMP_FILE_CORE and $DUMP_FILE_INFO"
    exit
fi


# get the kernel directory and the debug file
HOSTNAME=`hostname`
HOSTNAME="@"${HOSTNAME}
KERNEL_D=`grep "${HOSTNAME}" ${DUMP_FILE_INFO} | awk -F ":" ' {print $2;}'`
KERNEL_D=${KERNEL_D}/kernel.debug
if [ !  -f $KERNEL_D ]
then
    echo "Cannot find kernel debug symbols!"
    echo "Kernel debug info was $KERNEL_D"
    KERNEL_D=""
fi

# ok start the debugger
kgdb -d $DUMP_DIR -n $DUMP_NUMBER $KERNEL_D

    
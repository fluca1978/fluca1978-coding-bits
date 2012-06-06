#!/bin/bash



# Check the /proc/mdstat for a missing volume
LINEE=`grep -e "\[.*_.*\]" /proc/mdstat | wc -l`
if test $LINEE -gt 0
then
        /bin/echo "Found problems with $LINEE arrays"
	/bin/cat /proc/mdstat 
fi


# controllo spazio disco
LINEE=`df -H | grep [9][5-9]\% | wc -l`
if test $LINEE -gt 0
then
        /bin/echo "Attention: $LINEE devices are almost full!"
	/bin/df -H 
fi

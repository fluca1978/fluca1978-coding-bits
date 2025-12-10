#!/bin/bash

#
# A simple script to simulate the race of butterflies.
# Example of invocation:
#
#   bash butterflies.sh 8
#

clear

butterflies=$1

while [ -z "$butterflies" -o $butterflies -le 0 -o $butterflies -gt 9 ]; do
    read -p "How many butterflies (1-9)? " butterflies
done

echo "You selected $butterflies butterflies for this run"
sleep 3



clear

# columns
start=0
end=60

butterflies=$(( butterflies - 1 ))
# initial positions
for b in $(seq 0 $butterflies); do
    pos[$b]=$start
done

loop="yes"


until [ -z "$loop" ]; do
    clear

    # header (better do in a function)
    echo -n "       |"
    i=$start
    while [ $i -lt $end ]; do
	echo -n " "
	i=$(( i + 1))
    done
    echo "|"


    for b in $( seq 0 $butterflies ); do
	current_pos=${pos[$b]}
	step=$( shuf -i 0-9 -n 1 )
	current_pos=$(( current_pos + step ))
	pos[$b]=$current_pos
	printf '%d (+%d) |' $b $step
	for i in $( seq 0 $current_pos ); do
	    printf ' '
	done

	printf '🦋'

	# is this a winner?
	if [ $current_pos -ge $end ]; then
	    loop=""
	    printf '\t 🍺'
	fi

	printf '\n'
    done

    sleep 1
done

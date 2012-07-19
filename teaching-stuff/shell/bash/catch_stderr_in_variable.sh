#!/bin/bash


# This script shows how the stderr can be redirect into a single shell variable
# or in an array place holder.



# Declare an array named 'error_array'.
declare -a error_array


# A shell function that will generate a message to the stderr, simulating
# therefore an error coming from an external program.
function generate_stderr() {
    echo "Error $1 !" 1>&2
} 


# iterate and call the function to simulate an external program
# that generates an error, and then redirect the stderr to a 
# variable 'current_error' that will be both printed to the stdout
# and placed into a cell of the error array
for ((i=0 ; i < 10 ; i++)); do

    # invoke the function as it was an external program
    # and redirect stderr so that the variable assignement
    # gets only the stderr
    current_error=$( { generate_stderr "$i"; } 2>&1 )

    # store the error also in an array place
    error_array[$i]=$current_error

    # print the errors
    echo "The current error variable contains  [$current_error]"
    echo "The array cell $i contains the value " ${error_array[i]}
done




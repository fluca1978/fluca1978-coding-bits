#!/usr/bin/perl

# This script accept a filename and a number and return the specified line in the file

if( $#ARGV<1){
    exit(1);
}
else{
    # open the specified file
    open(FILE,"<".$ARGV[0]) || exit(2);

    # get the line number
    $lineNumber = $ARGV[1];
    
    # read each line
    $i=1;

    while( $line=<FILE> ){
	if($i == $lineNumber){
	    print $line;
	    exit(0);
	}

	$i++;

    }


}

#!/usr/bin/perl




# global variables and flags



# check arguments
if( $#ARGV<1 || $#ARGV>2 ){
    print "Usage:\n";
    print "$0 input_file output_file [tag_file]\n\n";
    print "where:\n";
    print "input_file is a markup-based text file (such as XML,HTML,ecc.)\n";
    print "output_file is the file on which the program will write the tag content\n";
    print "tag_file is an optional file which collects only the tags (without the content)\n";
    exit(0);
}

if( defined($ARGV[0]) && -f $ARGV[0] && -r $ARGV[0]){
    $INFILE = $ARGV[0];
}
else{
    print "The specified file <$ARGV[0]> does not exist or it is not readable!";
    die("Cannot continue!\n");
}




if( defined($ARGV[1]) && ((not -f $ARGV[1]) || (-f $ARGV[1] && -w $ARGV[1]) ) ){
    $OUTFILE = $ARGV[1];
}
else{
    die("Cannot write on file $ARGV[2], file exists and is not writeable\n");
}



if( defined($ARGV[2]) && ((-f $ARGV[2] && -w $ARGV[2]) || (not -f $ARGV[2])) ){
    $TAGFILE = $ARGV[2];
}


# open the files
open(IN,"<".$INFILE) || die("Unable to open $INFILE\n");
open(OUT,">".$OUTFILE) || die("Unable to open $OUTFILE\n");

if( defined($TAGFILE) ){
    open(TAG,">".$TAGFILE) || warn("Unable to open the specified tag file <$TAGFILE>\n");
}


print "Parsing input file $INFILE";
print "\nOutput file to $OUTFILE";

if( defined($TAGFILE) ){
    print "\nTag file to $TAGFILE";
}



# parse each line
while( $line = <IN> ){

    # does it contains a tag?
    while( $line =~ /<.*>/ ){

	# this is a tagged line 
	# remove the tag in the line
	$currentTag = $line;
	$line =~ s/<.*>/$2/;


	# extract the tag
	$currentTag =~ s/(.*)(<.*>)(.*)/$2/;
	print TAG $currentTag,"\n";

    }

    # write the line to the output file
    print OUT $line;
}



# exit from the script
print "\nall done!\n";
close(OUT);
close(IN);
close(TAG);

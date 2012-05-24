#!/usr/bin/perl 


# Note about variables: each main variable can be set-up to a default value or
# from an environment variable, which must have the same name of the 
# variable with the prefix SS_.







########################################
#### SCRIPT META INFORMATION ###########
$_VERSION_ = 1.5;              # version of this program


########################################
####### FILE VARIABLES #################

$WORKING_DIR    = $ENV{"SS_WORKING_DIR"}                      || $ENV{"HOME"}."/.signatureSelector";
$FILE_EXTENSION = $ENV{"SS_FILE_EXTENSION"}                   || ".cat";
$SIGNATURE_FILE = $ENV{"SS_SIGNATURE_FILE"}                   || $ENV{"HOME"}."/.signature";
$ORIGINAL_SIGNATURE_FILE = $ENV{"SS_ORIGINAL_SIGNATURE_FILE"} || $ENV{"HOME"}."/.original_signature";
$DAILY_FILE     = $ENV{"SS_DAILY_FILE"}                       || undef();

########################################
####### TEXT VARIABLE ##################

$INTRODUCTION = $ENV{"SS_INTRODUCTION"} || "Il pensiero del giorno e':";
$HEADER       = $ENV{"SS_HEADER"}       || "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
$FOOTER       = $ENV{"SS_FOOTER"}       || $HEADER."\n";



########################################
###### DEBUG VARIABLES #################

$_DEBUG_ = $ENV{"SS_DEBUG"} || undef(); # print verbose output
$_DEBUG_MESSAGE_COUNTER_ = 0;  # counts how many messages have been printed
$_SEE_;                        # if defined, the $_SEE_ variable will force the
                               # script to show on stdout the final signature 
                               # content => no debugging available


########################################
###### LOG VARIABLES ###################

$_LOG_FILE_ = $ENV{"SS_LOG_FILE"} || "$WORKING_DIR/.signatureSelector.log";   
                                              # the log file name
$_LOG_MESSAGE_COUNTER_ = 0;                   # counts how many messages have been logged.



########################################
###### CREDITS #########################

$_CREDITS_ = $ENV{"SS_CREDITS"} || undef();   # used to place credits on the
                                              # signature
                                              # the signature

$_CREDITS_STRING = "signature generated automatically thru\n <$0> v.$_VERSION_   \nby Luca Ferrari";





#########################################
##### FORMAT FOR PRINTING HELP ##########
format HELP_TOP =
    Parameter           Description                       Environment variable
+-----------------+--------------------------------------+--------------------+
.

format HELP_LINE =
 @<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>>>>>>>>>>>>>>>
   $f_par               $f_desc                              $f_env
.


# Debug message should be printed using this function, which prints
# messages to STDOUT only if the $_DEBUG_ variable is set to a value
# not null.
#
# The parameter of this function is the string that must be printed.
# Each message appears with the message counter, that is contained in the 
# variable $_DEBUG_MESSAGE_COUNTER_.
sub debugMessage($){
    if($_DEBUG_){
	$_DEBUG_MESSAGE_COUNTER++;
	print "[Debug] <msg num.$_DEBUG_MESSAGE_COUNTER> $_[0]\n";
    }
    if($_LOG_){
	logMessage($_[0]);
    }
}


# Shows a warning message on the STDERR.
#
# The parameter of this function is the string to print on the STDERR file.
sub warningMessage($){
    print STDERR "[Warning] $_[0]\n";

    if($_LOG_){
	logMessage($_[0]);
    }

}




# Function to initialize logging.
sub initializeLog(){
    if(not $_LOG_){
	return;
    }

    debugMessage("Initializing log to $_LOG_FILE_");
    open(LOG_FILE_HANDLER,">$_LOG_FILE_") || (unset($_LOG_));
    if($_LOG_){
	debugMessage("Log initialized!");
    }
}




# A function to log messages to a log file
# The log file handler is contained in the handler LOG_FILE_HANDLER
sub logMessage($){
    if($_LOG_){
	$_LOG_MESSAGE_COUNTER++;
	print LOG_FILE_HANDLER "<$0 - msg: $_LOG_MESSAGE_COUNTER> $_[0]\n";
    }
}


# Function which returns the current day of the month (1-31).
sub getDayOfMonth(){
    my ($_day) = (localtime())[3];
    debugMessage("Day of the month is: $_day (getDayOfMonth subroutine)");
    return $_day;
}

# A function to get the current month.
sub getMonth(){
    my ($_month_) = (localtime())[4];
    $_month_++;
    return $_month_;
}






# Function to compute the file name to open. The file is composed by the
# following variables:
# $WORKING_DIR/day_of_month.cat
#
#
# Note: if the $_CALENDAR_MODE_ is defined, the file is computed as month+day, not only
# as day file.
#
#
# The day of month is computed thru the getDayOfMonth function.
# The function will return the file name.
sub computeFileName(){
    
    my $_file;

    # first of all test and validate the working directory
    if(defined($WORKING_DIR) && (-d "$WORKING_DIR")){
	debugMessage("The directory $WORKING_DIR exists, calculating the file name");
	if( not defined($_CALENDAR_MODE_) ){
	    $_file = "$WORKING_DIR/".getDayOfMonth()."$FILE_EXTENSION";
	}
	else{
	    # calendar mode, get also the month
	    debugMessage("Working in calendar mode\n");
	    $_file = "$WORKING_DIR/".getMonth()."/".getDayOfMonth()."$FILE_EXTENSION";
	}
	debugMessage("The file is $_file");

        # now test the existance of the file
	if( -f "$_file" && -r "$_file" ){
	    return $_file;
	}else{
	    debugMessage("The file does not exist or is not readable!");
	    return undef();
	}
    }else{
	debugMessage("No working directory available!");
	return undef();
    }
}



# The function that merges the original signature file with the dayily file.
# The merging is done as follows:
# 1) first the original signature is read ($ORIGINAL_SIGNATURE_FILE)
# 2) the $INTRODUCTION and $HEADER are appended on a new line
# 3) the content of the file of the day is appended 
# 4) the FOOTER is appended
# 5) the result is saved to the signature file
#
#
# Parameters of this function are:
# $_[0] => the daily file to append
#
# other parameters are extracted from global variables
sub createSignature
{
    my ($_dailyFile) = (@_);

    # check parameters
    if( not defined($_dailyFile) ){
	debugMessage("Cannot work with a null daily file!");
	warningMessage("Cannot work with a null daily file!\n\tLeaving every file unchanged!\n");
	return;
    }


    # try to open the .signature file
    # if the -see option is activated the file must coincide with the
    # standard output
    debugMessage("Creating the new signature file");
    if( defined($_SEE_) ){
	*SIGNATURE_HANDLER = *STDOUT;
    }
    else{
	open(SIGNATURE_HANDLER,">$SIGNATURE_FILE") || return;
    }
    
    # place the original signature
    debugMessage("Opening the original signature file <$ORIGINAL_SIGNATURE_FILE>");
    open(ORIGINAL_SIGNATURE_HANDLER,"<$ORIGINAL_SIGNATURE_FILE") || return;
    while( $line = <ORIGINAL_SIGNATURE_HANDLER> ){
	debugMessage("Copying the row <$line>");
	print SIGNATURE_HANDLER "$line";
    }
    close(ORIGINAL_SIGNATURE_HANDLER);
    

    # place the daily file in the new signature one
    debugMessage("Copying the daily file");
    open(DAILY_HANDLER,"<$_[0]") || return; 
    print SIGNATURE_HANDLER "$HEADER\n$INTRODUCTION\n\n";
    while( $line = <DAILY_HANDLER> ){
	debugMessage("Copying the line <$line>");
	print SIGNATURE_HANDLER "$line";
    }
    close(DAILY_HANDLER);
    print SIGNATURE_HANDLER "$FOOTER";


    if(defined($_CREDITS_) ){
	debugMessage("Inserting credits in the signature");
	print SIGNATURE_HANDLER "\n\n$_CREDITS_STRING";
    }

    debugMessage("All done, closing the file");
    close(SIGNATURE_HANDLER);

    # should I show the result signature file?
    if( defined($_SHOW_) ){
	open(SIGNATURE_HANDLER,"<$SIGNATURE_FILE") || return;
	
	print "\nResult signature file $SIGNATURE_FILE contains:\n";

	while( $line = <SIGNATURE_HANDLER> ){
	    print "$line";
	}

	print "\n";
	close(SIGNATURE_HANDLER);
    }
    
}





# A function to parse command line arguments.
sub parseCommandLine(){

    # iterate each element and try to understand if it is a parameter.
    # parameter have a prefix of $_PARAMETER_PREFIX
    
    my $_PARAMETER_PREFIX = "--";
    my $current;

    for($i=0; $i<=$#ARGV; $i++){
	$current = $ARGV[$i];

	if( $current =~ /($_PARAMETER_PREFIX)(.)*/ ){
	    # this argument seems a parameter
	    debugMessage("Found a parameter at position $i ($current)");

	    # clean the parameter removing the $_PARAMETER_PREFIX string
	    $current =~ s/($_PARAMETER_PREFIX)//;
	    chomp($current);
	    debugMessage("Cleaned parameter is $current");


	    # switch among all parameters
	    if( $current =~ /working_dir/ ){
		$WORKING_DIR = $ARGV[++$i];

		# check for the working dir
		if( not ( -d $WORKING_DIR ) ){
		    print "Please provide a valid working dir!";
		    exit;
		}
	    }
	    elsif( $current =~ /^file_extension/ ){
		$FILE_EXTENSION = $ARGV[++$i];
	    }
	    elsif( $current =~ /^signature/ ){
		$SIGNATURE_FILE = $ARGV[++$i];
	    }
	    elsif( $current =~ /^original_signature_file/ ){
		$ORIGINAL_SIGNATURE_FILE = $ARGV[++$i];
	    }
	    elsif( $current =~ /^introduction/ ){
		$INTRODUCTION = $ARGV[++$i];
	    }
	    elsif( $current =~ /^header/){
		$HEADER = $ARGV[++$i];
	    }
	    elsif( $current =~ /^footer/ ){
		$FOOTER = $ARGV[++$i];
	    }
	    elsif( $current =~ /^log_file/ ){
		$_LOG_FILE_ = $ARGV[++$i];
		$_LOG_      = "true";
	    }
	    elsif( $current =~ /^debug/ || $current =~ /verbose/ ){
		$_DEBUG_ = "true";
	    }
	    elsif( $current =~ /^see/ ){
		undef($_DEBUG_);
		$_SEE_ = "true";
	    }
	    elsif( $current =~ /^show/ ){
		# show the result when done
		$_SHOW_ = "true";
	    }
	    elsif( $current =~ /^calendar/ ){
		# work in calendar mode.
		$_CALENDAR_MODE_ = "true";
	    }
	    elsif( $current =~ /^create-calendar/ ){
		# create the calendar structure
		createCalendar();
		exit();
	    }
	    elsif( $current =~/^rotate/ ){
		# swap quote files and exit
		rotate();
		exit(0);
	    }
	    elsif( $current =~ /^daily_file/ ){
		# the user wants to specify a daily file to use, check
		# if it active
		$DAILY_FILE = $ARGV[++$i];
		if( not ( -f $DAILY_FILE && -r $DAILY_FILE) ){
		    # try to use the file in the working dir
		    $DAILY_FILE = $WORKING_DIR."/".$DAILY_FILE;
		    if( not (-f $DAILY_FILE && -r $DAILY_FILE ) ){
			print "Please provide a valid daily file!";
			exit;
		    }
		}
	    }
	    elsif( $current =~ /^date/ ){
		# the user wants to force a particular date
		$DAILY_FILE = $WORKING_DIR."/".$ARGV[++$i].$FILE_EXTENSION;
		debugMessage("Working with the file $DAILY_FILE");
	    }
	    elsif( $current =~ /^h/ ){
		# display help
		displayHelp();
		displayHelp2();
		exit();
	    }
	    elsif( $current =~ /^credits/ ){
		# put credits in the signature file
		$_CREDITS_ = "true";
	    }
	    elsif( $current =~ /log/ ){
		# simply activate the log facility (no matter if the user has specified the 
		# log file position)
		$_LOG_ = "true";
		
	    }
	    elsif( $current =~ /^edit/ ){
		# the user wants to edit the file, use the default editor
		if( not defined( $ENV{"EDITOR"} ) ){
		    warningMessage("\nCannot open the default editor, please set the EDITOR environment variable\n");
		    exit;
		}
		else{
		    # I need to check if the user has given a valid date 
		    # (1<x<31)
		    $date = $ARGV[++$i];
		    if( $date > 31 || $date < 1 ){
			warningMessage("Cannot edit a file with date $date!How many days do you think there are in a month?");
			exit;
		    }
		    $file = $WORKING_DIR."/".$date.$FILE_EXTENSION;
		    debugMessage("Opening the default editor for $file");
		    exec($ENV{"EDITOR"}, $file);
		}
	    }

	}
	else{
	    # not a parameter
	    debugMessage("Found a not-parameter argument ($current)");
	}
    }
}




# A function to create the directory structure to contain the calendar.
sub createCalendar(){
    if( (not defined($WORKING_DIR)) || not (-d $WORKING_DIR && -w $WORKING_DIR) ){ return undef(); }

    # create each directory, if abscent
    for($_i=1; $_i<=12; $_i++){
	$_directory = $WORKING_DIR."/".$_i;
	if( not -d $_directory ){
	    mkdir($_directory,"700") || debugMessage("Cannot create calendar dir $_directory\n$!");
	}
    }

    # now replicate the file structure in the each directory
    opendir(DIR_HANDLE,$WORKING_DIR) || return;
    @files = readdir(DIR_HANDLE);
    closedir(DIR_HANDLE);

    for($_j=1;$_j<=12;$_j++){
	$directory = $WORKING_DIR."/".$_j;

	foreach $_i (@files){
	    print "\nfile $_i\n";
	    $_src = $WORKING_DIR."/".$_i;
	    $_dst = $directory."/".$_i;

	    if( -f $_src ){
		# create the basename of the file

		debugMessage("\nLink to $_dst from $_src");
		link($_src,$_dst);
	    }
	    
	}
    }

    
}

# Display help
sub displayHelp(){
    print << "END_HELP";
" ***** $0 v. $_VERSION_ HELP *****
$0 is a script which can create an e-mail signature each day
different. To do this this program merges two files, called
original signature file and daily file. The former is a file
that contains all the stuff that you want to appear in the signature
(such as your username, address, etc.). The latter is a file which
contains stuff related to today's signature (such as a quote).

In particular the result signature file will be constructed as follows:

original signature file
         +
header
         +
introduction
         +
footer
         +
credits (optional)

Where header,footer and introduction are strings that can be set-up from
the command line or by environment variables.
         


HOWTO USE:

you can use the program manually, launching it from a command line or you can
place a call to the program in cron or in a startup script. For example, the
following is a cron entry which updates your signature every day at 8.00 AM:
00 8 * * * /home/luca/bin/signatureSelector.pl

Nevertheless the use of cron is not really suitable for a laptop or a 
workstation that can be turned off. In this case I suggest you to place a 
wrapper around the script, thus you can execute at your machine startup.
A good idea is to place a script call in your shell login file, such as
~/.profile or ~/.bash_profile, thus each time you'll log in the script will
generate a new version of the signature file. To avoid the routinely execution
of the script against multiple logins, wrap it around with an environment 
variable check. Here's an example from my .profile file:

if test -z SIGNATURE_SELECTOR_RAN
then
    export SIGNATURE_SELECTOR_RAN=`date`
    signatureSelector.pl 
fi

Each time a new login happens, the  SIGNATURE_SELECTOR_RAN shell variable is 
checked. If it is null (first login), than it is set to the current time and 
date and the script is called for differnt e-mail signatures. 


IMPLEMENTATION DETAILS:

The script has a working dir, that is a directory that contains all daily files
and generated logs. The directory must exist and daily files must be readable.
Each daily file must have a name composed by a number and an extension. 
The number is the day-of-month the daily file will be used, the extension is 
used to easily and quickly recognize files (by default it is $FILE_EXTENSION).
You can manually generate the daily file or you can use the --edit option,
providing the date you want to edit. The edit option uses the exec perl 
function, that means this script is stopped and your editor is executed 
instead. In other words you will have to run again the script to execute
with the modified data.

The script reads line by line the file to be merged, that means you want 
something special, such as a new line at the end of the new signature file, you
have to provide it by yourself in the daily files. If the daily file cannot be
found, only the original signature is placed in the new signature file. 



PARAMETERS:

The script behaviour can be changed setting up defined parameters.
Most parameters can be set-up either trhu the command line or with
environment variables. In the latter case (environment variables)
each variable is capitalized, with a prefix of SS_ and a name equal to
the variable used in the script. For example, to change the 
$INTRODUCTION script variable, you have to set an environment variable
such as SS_INTRODUCTION.


Each command line parameter must begin with $_PARAMETER_PREFIX. Some parameters
can require argument (e.g., the log_file one requires the file name you want
to use for logging).
"




END_HELP

}

# Function to display parameter help using a perl format as a table.
sub displayHelp2()
{


    print "The following is a list of supported parameters:\n\n";

    # print the first format (header)
    $~ = HELP_TOP;
    write;

    # switch to the other format
    $~ = HELP_LINE;

    # now print all lines
    $f_par  = "$_PARAMETER_PREFIXdebug";
    $f_desc = "Prints verbose output.";
    $f_env  = "SS_DEBUG";
    write;

    $f_par  = "$_PARAMETER_PREFIXverbose";
    $f_desc = "Prints verbose output.";
    $f_env  = "SS_DEBUG";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."h";
    $f_desc = "Displays this message and exits.";
    $f_env  = "";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."debug";
    $f_desc = "Prints verbose output.";
    $f_env  = "SS_DEBUG";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."working_dir";
    $f_desc = "Sets the current working dir.";
    $f_env  = "SS_WORKING_DIR";
    write;
    $f_par  = "";
    $f_desc = "The work. dir is the dir where daily files are";
    $f_env  = "";
    $f_par  = "";
    $f_desc = "By default it is ";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$WORKING_DIR";
    $f_env  = "";
    write;


    $f_par  = "$_PARAMETER_PREFIX"."extension";
    $f_desc = "Defines the daily file extension..";
    $f_env  = "SS_FILE_EXTENSION";
    write;
    $f_par  = "";
    $f_desc = "By default it is $FILE_EXTENSION";
    $f_env  = "";
    write;


    $f_par  = "$_PARAMETER_PREFIX"."signature";
    $f_desc = "The file in which write the";
    $f_env  = "SS_SIGNATURE_FILE";
    write;
    $f_par  = "";
    $f_desc = "signature.By default it is";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$SIGNATURE_FILE";
    $f_env  = "";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."original_signature_file";
    $f_desc = "The original signature file.";
    $f_env  = "SS_ORIGINAL_SIGNATURE_FILE";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."daily_file";
    $f_desc = "Forced file to use.";
    $f_env  = "SS_DAILY_FILE";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."date";
    $f_desc = "Force a date in the program.";
    $f_env  = "";

    $f_par  = "$_PARAMETER_PREFIX"."introduction";
    $f_desc = "Sets the introduction phrase.";
    $f_env  = "SS_INTRODUCTION";
    write;
    $f_par  = "";
    $f_desc = "By default it is";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$INTRODUCTION";
    $f_env  = "";
    write;
    

    $f_par  = "$_PARAMETER_PREFIX"."header";
    $f_desc = "Sets the header.";
    $f_env  = "SS_HEADER";
    write;
    $f_par  = "";
    $f_desc = "By default it is";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$HEADER";
    $f_env  = "";
    write;
	

    $f_par  = "$_PARAMETER_PREFIX"."footer";
    $f_desc = "Sets the footer.";
    $f_env  = "SS_FOOTER";
    write;
    $f_par  = "";
    $f_desc = "By default it is";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$FOOTER";
    $f_env  = "";
    write;

    $f_par  = "$_PARAMETER_PREFIX"."log_file";
    $f_desc = "The log file.";
    $f_env  = "SS_LOG_FILE";
    write;
    $f_par  = "$_PARAMETER_PREFIX"."log";
    $f_desc = "Activates the loggin facility on the default file $_LOG_FILE_ (or whatever the user has specified thru the log_file argument).";
    $f_env  = "";
    write;
    
    $f_par  = "";
    $f_desc = "Specifying a log file will";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "automatically turn-on logging.";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "By default it is";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "$_LOG_FILE_";
    $f_env  = "";
    write;


    $f_par  = "$_PARAMETER_PREFIX"."see";
    $f_desc = "Print the signature that will be";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc = "and do nothing else.";
    $f_env  = "";
    write;


    $f_par  = "$_PARAMETER_PREFIX"."show";
    $f_desc = "Shows the result file when done";
    $f_env  = "";
    write;



    $f_par  = "$_PARAMETER_PREFIX"."credits";
    $f_desc = "Put credtis in the signature file";
    $f_env  = "SS_CREDITS";
    write;
    $f_par  = "";
    $f_desc = "A credit string will be printed.";
    $f_env  = "";
    write;


    $f_par  = "$_PARAMETER_PREFIX"."edit";
    $f_desc  = "Opens the default editor for editing";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc  = "a date file";
    $f_env  = "";
    write;
    


    $f_par  = "calendar";
    $f_desc  = "Runs in calendar mode, with a different file";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc  = "for each day in the month.";
    $f_env  = "";
    write;


    $f_par  = "create-calendar";
    $f_desc  = "Creates the structure for the calendar";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc  = "with a directory for each month. Furthermore";
    $f_env  = "";
    write;
    $f_par  = "";
    $f_desc  = "it links the original files in each month.";
    $f_env  = "";
    write;
 
 
    
}




# Function to end the script.
sub endScript()
{
    debugMessage("$0 terminating");
    debugMessage("Merged files <$ORIGINAL_SIGNATURE_FILE, $DAILY_FILE>");
    debugMessage("into <$SIGNATURE_FILE>");
}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#################### REAL SCRIPT #############################


# parse the command line
parseCommandLine();


# Prepare the log (if needed!)
initializeLog();


# Compute the file name
# The file name must be computed only the user has not specified a daily file 
# to use.
if( not defined($DAILY_FILE) ){
    $DAILY_FILE = computeFileName();
}

# merge files
# I need to merge only if I'm not running in a store_counter mode or I'm
# running it but the date is changed.
createSignature($DAILY_FILE);


# end the script
endScript();



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




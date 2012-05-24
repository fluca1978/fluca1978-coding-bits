#!/usr/bin/perl

# A perl script to connect to the vypress messenger, sending a message.

# Use a package as container of the functions and variables of this script.
package vypress;







##########################################################################################
##########################################################################################
################### GLOBAL VARIABLES #####################################################
##########################################################################################
##########################################################################################

$port        = $ENV{"VY_PORT"}        || 7777;
$destination = $ENV{"VY_DESTINATION"} || undef();
$message     = $ENV{"VY_MESSAGE"}     || undef(); 
$protocol    = $ENV{"VY_PROTO"}       || "tcp";
$subject     = $ENV{"VY_SUBJECT"}     || undef();
$priority    = $ENV{"VY_PRIORITY"}    || 0;
$repeating   = $ENV{"VY_REPEATING"}   || 1;
$sleeping    = $ENV{"VY_SLEEPING"}    || undef();
$email       = $ENV{"MAIL"}           || $ENV{"VY_MAIL"} || undef();



##########################################################################################
###################### COMPLEMENTARY VARIABLES ###########################################
##########################################################################################

# destination vector
# Each destination addresse will be contained in this vector.
@DESTINATIONS;

# message vector
# In case of multiple messages, each message will be stored in this vector.
@MESSAGES;

# This hash will be used in case of statistic reports. The hash will keep a counter for each addressee
# that indicates how many succesfull messages have been sent to it.
%_STATISTICS_ = {};


##########################################################################################
#################### META-DATA VARIABLES #################################################
##########################################################################################

# The version of this program.
$_VERSION = 0.5;

# Extract the relative name of this script.
@_name_ = split("/",$0);
$_NAME_ = $_name_[$#_name_];
undef(@_name_);






#//////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////////////////////////////////////////////////////
################## FORMATS FOR PRINTING STATISTICS ########################################
#//////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////////////////////////////////////////////////////

format STATISTICS_TOP =

 _____________________________________________________________________________
/                            ACTIVITY REPORT                                  \
+---------------------+--------------------+------------------+---------------+
| Destination:        |   Tried messages   |   Sent messages  | Success Ratio |
+---------------------+--------------------+------------------+---------------+
.

format STATISTICS_LINE =
| @<<<<<<<<<<<<<<<<<<<| @>>>>>>>>>>>>>>>>> | @>>>>>>>>>>>>>>> |      @>>>>>   |
      $_line_1               $_line_2           $_line_3             $_line_4
.

format STATISTICS_BOTTOM = 
+---------------------+--------------------+------------------+---------------+
.




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



# A function to parse the command line.
sub parseCommandLine(){
    for($i=0; $i<=$#ARGV; $i++){
	$current = $ARGV[$i];
	
	if( $current =~ /(--)(.)+/ ){
	    # the current parameter is an option tag
	    $current =~ s/(--)//;

	    if( $current =~ /port/ ){
		# the destination port
		$port = $ARGV[++$i];
	    }
	    elsif( $current =~ /to/ ){
		# the destination IP/machine
		# it could be a multiaddress such as 192.168.1.21,192.168.2.22,ecc.
		# each address separated by a comma
		@DESTINATIONS = split( ",",$ARGV[++$i] );
	    }
	    elsif( $current =~ /message/ ){
		# the message text, should be quoted
		$MESSAGES[++$#MESSAGES] = $ARGV[++$i];
	    }
	    elsif( $current =~ /proto/ ){
		# the protocol to use
		$protocol = $ARGV[++$i];
	    }
	    elsif( $current =~ /priority/ ){
		# the priority to use
		$priority = $ARGV[++$i];
	    }
	    elsif( $current =~ /subject/ ){
		# the subject of the message
		$subject = $ARGV[++$i];
	    }
	    elsif( $current =~ /help/ ){
		# show help
		displayHelp();
		exit;
	    }
	    elsif( $current =~ /statistics/ ){
		# i need also to print statistics
		$_stats = "true";
	    }
	    elsif( $current =~ /repeat/ ){
		# repeat the whole structure
		chomp ($repeating = $ARGV[++$i]);
	    }
	    elsif( $current =~ /sleep/ ){
		# sleeping factor
		chomp( $sleeping = $ARGV[++$i] );
		if( $sleeping <= 0){ undef($sleeping); }
	    }
	    elsif( $current =~ /email/ ){
		# the user email info
		$email = $ARGV[++$i];
	    }
	    elsif( $current =~ /see/ ){
		# just see what's going on the network
		$_seeMode_ = "true";
	    }
	    elsif( $current =~ /file/ ){
		# message from a file
		$file = $ARGV[++$i];
		if( -f $file && -r $file ){
		    open(FIN,"<$file") || warn("\nCannot open the message file!\n$1\n");
		    $#MESSAGES++;
		    while( $line = <FIN> ){
			$MESSAGES[$#MESSAGES].=$line;
		    }
		    close(FIN);
		}
	    }
	}
    }
}





# A function to display help.
sub displayHelp()
{
    print "\n+----------------------------------------------------------------------------------------------+";
    print "\n         $_NAME_ v. $_VERSION - Perl line command interface for Vypress Messenger               ";
    print "\n+----------------------------------------------------------------------------------------------+";
    print "\nUsage:\n";
    print << "END_HELP";

    $_NAME_ --to host1[,host2,...,hostn] [--port destination_port] --message \"Text message (better if quoted)\"
         [--proto protocol] [--priority priority] [--subject subject] 
         [--statistics]
         [--file]
         [--repeat repeat_number] [--sleep sleeping_factor]
	 [--see]
      
    $_NAME_ --help
  
    where:
    --to           is the address (either IP or DNS) of the destination machine(s). If multiple addresses are
                   provided, they must be comma separated
    --port         is the destination port, if different from the default $port
    --message      is the text message you want to send
    --email        specifies the user e-mail info
    --proto        is the protocol to use (tcp,udp) if different from the default ($protocol)
    --priority     is the message priority, if different from the default $priority
    --subject      is the message subject, that will be shown in the message window title
    --help         displays help and exits
    --see          just print the message on the stdout, instead of sending it over the network
    --statistics   prints a statistic report of sent message. The report will look like the following
                      +---------------------+--------------------+------------------+---------------+
                      | Destination:        |   Tried messages   | Delivered mesgs. | Success Ratio |
                      +---------------------+--------------------+------------------+---------------+
                      | 192.168.2.17        |                  2 |                1 |          50%  |
                      +---------------------+--------------------+------------------+---------------+
                   where, for each addressee, it is speicified how many messages have been sent 
		   and the success ratio. Furthermore, below the report table, a summary string will appear.


    --file         get a message from a text file
    --repeat       asks the program to redo-all for repeat_number times. WARNING: this options is more
                   spam-prone than the multiple messages/addressees use.
    --sleep        asks the program to sleep spleeping_factor seconds before starts repeating. 
                   It does not make sense the use of this option without the --repeat one.

    It is possible to send multiple message to multiple/single user(s). To do this you have 
    to specify more than one --message option on the command line. There is no check about command line
    option repetition, that means that if you specify the same option more than once, only the last definition
    will be kept. Specific options, such as --message, that directly allow the use of multiple definition are
    excluded from the above.

    A lot of parameter can also be set by environment variables. Each variable must have a VY_ prefix, and be
    uppercase. The name of the variable contains the same name of the Perl variable. In particular, 
    the following variables can be used:
    VY_PORT, VY_DESTINATION, VY_MESSAGE, VY_SUBJECT, VY_PRIORITY, VY_SLEEPING, VY_REPEATING, MAIL

END_HELP
}




# A function to check command line arguments.
sub checkArguments(){
    # a destination host must be provided
    if( (not defined(@DESTINATIONS)) || $#DESTINATIONS < 0 ){
	print "\nPlease give a valid destination, see $_NAME_ --help for further details\n";
    }
    
    # the message must be provided
    if( (not defined(@MESSAGES)) || $#MESSAGES < 0 ){
	print "\nPlease give a message text, see $_NAME_ --help for further details\n";
    }
}






# Function to connect and send the message.
# Arguments to this function:
# destination, message
#
# Return value: undef if there are problems with the socket, "true" otherwise.
sub sendMessage($$){

    # get current messages
    my ($destination,$message) = @_;

    # check parameters
    if( not (defined($destination) && defined($message) ) ){ return undef(); }

    
    my $AF_INET = 2;
    my $SOCK_STREAM = 1;
        # the template string for a network address: S=short integer n=network big endian a4=4 data x8=8 null bytes
    my $sockaddr = 'S n a4 x8';


    # print some informations
    print "\nSending a message to $destination over $protocol to port $port...";

    # get the current hostname and place it in the $hostname variable
    chop($hostname = `hostname`);

    # decide where to connect
    # get the line of the /etc/protocols file with the protocol name and attributes
    ($name,$aliases,$proto) = getprotobyname($protocol);
    # get the line of the /etc/services file that matches with the specified port and protocol,
    # but only if the port contains something different from a digit(s)
    ($name,$aliases,$port)  = getservbyname($port,$proto) unless $port =~ /^\d+$/;;
    # get this host address and name
    ($name,$aliases,$type,$len,$thisaddr) = gethostbyname($hostname);
    # get the destination host address and name
    ($name,$aliases,$type,$len,$thataddr) = gethostbyname($destination);
    
    # create a string that describes the destination,url,etc.
    $this = pack($sockaddr, $AF_INET, 0, $thisaddr);
    $that = pack($sockaddr, $AF_INET, $port, $thataddr);

    # keep a variable for the success of the current operation
    $success = "true";

    if( not defined($_seeMode_) ){
	# create the socket file handle and store it into the SOCKET_HANDLE filehandle
	socket(SOCKET_HANDLE, $AF_INET, $SOCK_STREAM, $protocol) || return undef();
	# connect to the server
	connect(SOCKET_HANDLE, $that) || return undef();
	# buffer the socket
	# I need to select the SOCKET_HANDLE as the default output, then I have to set $| variable to 1 in order
	# to make the stream buffered. Finally I have to reselect the STDOUT as default output (when no specified in
	# function as print).
	select(SOCKET_HANDLE); 
	$| = 1; 
	select(STDOUT);
    }
    else{
	# want to see, just print on the stdout
	*SOCKET_HANDLE = *STDOUT;
	print SOCKET_HANDLE "\n\n";
    }


    # print the message. The message has a format as specified in the following:
    # username/$0text/$1systemname/$2subject/$3priority/$4e-mail
    # /$7/$5sender_ip:port/$6attachment name (xxx Byte);00001/$7\n
    $attachment = "prova.txt";
    $attachmentSize = 5;
    print SOCKET_HANDLE $ENV{"USERNAME"}."/\$0$message/\$1$hostname/\$2$subject/\$3$priority/\$4$email";
    print $ENV{"USERNAME"}."/\$0$message/\$1$hostname/\$2$subject/\$3$priority/\$4$email";
    print SOCKET_HANDLE "/\$7/\$5$hostname:$port/\$6$attachment($attachmentSize Bytes);00001/\$7";
    print "/\$7/\$5$hostname:$port/\$6$attachment($attachmentSize Bytes);00001/\$7";
    print SOCKET_HANDLE "\n";
    print "\n";


    # sparo un pacchetto da 1460 bytes
    open(FILE,"<$attachment");
    while(<FILE>){
	print SOCKET_HANDLE $_,"\n";
	print $_, "\n";
    }
    close(FILE);


    # place statistics
    $_STATISTICS_{$destination}++ if( defined($_stats) && defined($success) );

    # close  the socket
    close(SOCKET_HANDLE) if( not defined($_seeMode_) );

    # everything seems ok, return a no-false value
    return "true";
}





# a function to print statistics
sub printStatistics(){
    if( (not defined($_stats) ) ){
	return;
    }


    # store into a summary string hosts with errors
    $errors = "";

    # use formats to print statistics
    $~ = STATISTICS_TOP;
    write;

    # iterate each line
    $~ = STATISTICS_LINE;

    # get each address from the address list
    foreach $key ( @DESTINATIONS ){
	$_line_1 = $key;
	$_line_2 = $TOTAL_MESSAGES;
	$_line_3 = $_STATISTICS_{$key} || 0;
	$_line_4 = ($_line_3/$_line_2)*100 if($_line_2 != 0);
	$_line_4.= "%"                     if($_line_2 != 0);
	$_line_4 = "N/A"                   if($_line_2 == 0);
	write;
	undef($_line_1);
	undef($_line_2);
	undef($_line_3);
	undef($_line_4);

	# does this host any error?
	if( $_STATISTICS_{$key} != $TOTAL_MESSAGES ){
	    $errors .= $key." ";
	}
    }

    # the bottom of the report
    $~ = STATISTICS_BOTTOM;
    write;

    # print a summary about errors
    if( length($errors) > 0 ){
	print "\nThe following addressees have errors:\n$errors\n";
    }
}






##########################################################################################
##########################################################################################
######################################## SCRIPT ##########################################
##########################################################################################
##########################################################################################

# Parse the command line
parseCommandLine();

# check if the message and the addressee have been provided
checkArguments();

# total number of messages per each addressee
$TOTAL_MESSAGES = ($#MESSAGES+1)*$repeating;

# iterate on each message and destination, wait for the sleeping factor and for the repeating ratio
while( $repeating > 0 ){

    for( $i=0; $i<=$#DESTINATIONS; $i++ ){
	$destination = $DESTINATIONS[$i];
	for( $j=0; $j<=$#MESSAGES; $j++ ){
	    $message = $MESSAGES[$j];
	    if( not sendMessage( $destination, $message) ){ print " \tERROR\n"; }
	}
    }
    
    # prepare for the next cicle
    $repeating--;
    sleep($sleeping) if( defined($sleeping) && $repeating > 0 );
}

# show statistics (if the option has set the related flag)
printStatistics();

#!/usr/bin/perl


# A simple script for ip address addition to /etc/hosts.
# The script works as follows:
# it parses each parameter of the command line assuming it's a hostname. If the string is in numeric format
# (e.g., 155.185.48.111) it will be skipped, otherwise the resolv command (e.g., host)
# will be invoked and the result will be parsed to extract the host address.
# It supports the search for SAMBA hosts with the parameter --samba before the host.
# If the --domain parameter is specified, then each following host will be added by the domain string.


# Global variables
$HOST_FILE             = "/etc/hosts";
$RESOLV_COMMAND        = "host";
$FILE                  = 1;             # 1 => write to file, 0 write to stdout
$SAMBA_RESOLVE_COMMAND = "nmblookup";









##########################################################################################
##########################################################################################

# parse commands
if($#ARGV<0){
    print "\nUsage:\n";
    print "$0 [--samba] hostname [--samba] hostname ....\n";
    print "\nIf you don't have rights to write on $HOST_FILE the output will be printed";
    print "\non stdout\n";
    print "\nExample of invocation:\n";
    print "\naddHostsEntry.pl --samba winMachine github.com --samba homeNas sun02.aule.unimore.it";
    print "\nExample of the domain option:\n";
    print "\naddHostsEntry.pl ferrari.ing.unimo.it --domain aule.unimore.it sun01 sun02 ";
    print "\n\nthat is equivalent to invoke the script as:\n";
    print "\naddHostsEntry.pl ferrari.ing.unimo.it  sun01.aule.unimore.it sun02.aule.unimore.it";
    
    exit(1);
}


$index      = 0;
$SAMBA_MODE = 0;





open(FILE,">>".$HOST_FILE) || ($FILE = 0);

if( $FILE == 0 ){
    warn("\nWriting to stdout (maybe you don't have permissions to open $HOST_FILE?)\n");
    *FILE = *STDOUT;
}



# parse each argument
for( $index=0; $index<=$#ARGV; $index++){


    # check if the current argument contains an option (maybe the samba mode)
    if( $ARGV[$index] =~ /^--.*/ ){
	# it's a parameter
	
	# samba parameters
	if( $ARGV[$index] =~ /^--samba$/ ){ $SAMBA_MODE = 1; $index++;}
	# search domain
	elsif( $ARGV[$index] =~ /^--domain$/ ){ $domain = $ARGV[++$index]; $index++;}
	
    }
    else{
	$SAMBA_MODE = 0;
    }
    


    # get the current host string.
    $host = $ARGV[$index];

    # if we have a domain string append it to the host
    $host .= ".".$domain if( $domain );



    # check if the host is already an address
    if( $host =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/ ){
	warn("\n$host is already an IP address, skipping...");
    }
    elsif( $SAMBA_MODE == 0) {
	# resolv an host querying the DNS

	# ATTENTION: host could return more than one line per host (multiple addresses)
	@output = `$RESOLV_COMMAND $host`;
	
	# supposing that the host address is the last part of the command output
	foreach $line (@output){
	    @parts   = split(" ",$line);
	    $address = $parts[$#parts];
	    $host    = $parts[0];
	}
	
    }
    elsif( $SAMBA_MODE == 1 ){
	# resolve the host with the samba command

	@output = `$SAMBA_RESOLVE_COMMAND $host`;

	# parse the output
	foreach $line (@output){
	    if( $line =~ /$host/ ){
		# this line contains the host address
		$address = (split(" ",$line))[0];
	    }
	}
    }



    # get the relative host name
    $relative_host = $host;
    while( $relative_host =~ /(.*)\.(.*)/ ){
	$relative_host =~ s/(.*)(\.(.*))+/$1/g;
    }
    
    
    # add the address to the /etc/hosts file
    if( $host && $relative_host && $address){
	print FILE "\n$address $host $relative_host\t# automatically added by addHostsEntry.pl";
	}
    

}

# close the file
print FILE "\n";
close(FILE) if( $FILE == 1 );


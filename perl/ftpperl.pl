#!/usr/bin/perl -w

# A simple Perl wrapper for doing simple FTP Transferts.
# Script arguments are:
# 1) remote ftp site
# 2) username
# 3) password
# 4) download/upload/rdownload (rdownload = recursive download)
# 5) binary/text mode
# 6) remote folder
# 7) loca   folder
# 8) file name
#
# Usage examples:
# perl ftpperl.pl 192.168.1.7    workart r48xx download  binary . . "Ambientazione Master.tif"
# perl ftpperl.pl 192.168.1.7    workart r48xx upload    binary . . ftpperl.pl inserimento_persona.pl 
# perl ftpperl.pl 192.168.201.63 root    root    rdownload binary /usr/bbx ./backup_opensco .



# use the Perl Net::FTP module
use Net::FTP;
use Net::FTP::Recursive;





# get parameters from command line or from environment
$remote_host = $ARGV[0]      || $ENV{'FTPHOST'};
$username    = $ARGV[1]      || $ENV{'USER'}    || $ENV{'USERNAME'};
$password    = $ARGV[2]      || $ENV{'FTPPASSWORD'};
$upload      = $ARGV[3]      || $ENV{'FTPMODE'} || "upload";
$binary      = $ARGV[4]      || "binary";
$remote_dir  = $ARGV[5]      || $ENV{'FTPREMOTEDIR'};
$local_dir   = $ARGV[6]      || $ENV{'FTPLOCALDIR'};
$verbose     = $ENV{'DEBUG'} || $ENV{'VERBOSE'} || undef();



# check if we have all what we need
if( not ($remote_host && $username && $password && $upload && $binary) ){
    print "\nCannot execute the script!";
    print "\nUsgae:";
    print "\n$0 <host_remoto> <username> <password> <upload/download> <text/binary> <remote_dir> <local_dir> <file> <file> ...<file>";
    print "\n\n";
    exit(1);
}



# for debug purposes set this variable
#$verbose=1;


# if "rdownload" then there is the need for a recursive download
if( $upload eq "rdownload" ){
    print "\nRecursive download mode..."                       if($verbose);
    $ftp = Net::FTP::Recursive->new("$remote_host");
    print "ready!"                                             if($verbose);
}
else{
    # normal (non-recursive) mode
    print "\nNormal FTP mode (non recursive)..."               if($verbose);
    $ftp = Net::FTP->new("$remote_host")        || die("\nCannot connect to remote host\n", $ftp->message);
    print "ready!"                                             if($verbose);
}


# do login
print "\nlogin to the remote site..."                      if($verbose);
$ftp->login( "$username", "$password" )     || die("\nCannot do FTP login\n", $ftp->message);
print "done!!"                                             if($verbose);


# enter the remote folder
print "\nEntering remote folder <$remote_dir>"             if($verbose);
$ftp->cwd("$remote_dir");
# enter the local folder
print "\nEntering local folder <$local_dir>"               if($verbose);
chdir("$local_dir");

# set the transport mode
print "\nTransfer type <$binary>"                          if($verbose);
if( $binary eq "binary" ){
    $ftp->binary();
}
elsif( $binary eq "text" || $binary eq "ascii" ){
    $ftp->ascii();
}



# repeat the action for all the files in the command line
for( $i=7; $i<=$#ARGV; $i++ ){

    $file = $ARGV[$i];
    print "\nProcessing file <$file>"                             if($verbose);
    
    # upload o download ?
    if( $upload eq "upload" ){
	print "\nUploading <$file>..."                            if($verbose);
	$ftp->put("$file");
	print "done!"                                             if($verbose);
    }
    elsif( $upload eq "download" ){
	print "\nDownloading <$file>..."                          if($verbose);
	$ftp->get("$file");
	print "done!"                                             if($verbose);
    }
    elsif( $upload eq "rdownload" ){
	print "\nDownloading (recurse mode) <$file>..."           if($verbose);
	$ftp->rget();
	print "done!"                                             if($verbose);
    }
}



# close the connection
print "\nClosing FTP connection ..."                             if($verbose);
$ftp->quit() || die("\nCannot close FTP connection!!\n");
print "all done, bye\n"                                          if($verbose);






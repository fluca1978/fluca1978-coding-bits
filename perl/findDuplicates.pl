#!/usr/bin/perl

use strict;
use File::Util;
use Digest::SHA qw( sha1 sha256 sha256_base64);
use Data::Dumper;

my $cwd = ".";

my $files_for   = {};
my $max_file_size = int( 100 * 1024 * 1024 );
my $handle_cwd  = new File::Util;
my $handle_file = new File::Util( readlimit => $max_file_size  );
my @directories;

# if the user has specified a list of directories, then copy then into the
# @directories array, otherwise just place the current working directory
if ( ! @ARGV ){
    push @directories, ".";
}
else{
    push @directories, @ARGV;
}

print "\nWill look into the following directories: @directories \n";

for my $cwd ( @directories ){
    print "\n $cwd :\tSearching for files and computing hashes (this may take a while)...";

    for my $current_file_name ( $handle_cwd->list_dir( $cwd,  qw( --no-fs-dots --files-only --recurse)  ) ){
	next if ( ! -e $current_file_name || ! -r $current_file_name );

	# load the content of the file into a string
	# then compute the hash of the file content
	# and place the file name into the hash structure
	# with the file-hash as the key

	my $current_file_content = $handle_file->load_file( $current_file_name );
	my $current_file_hash    = sha256_base64( $current_file_content );
	push @{ $files_for->{ $current_file_hash } }, $cwd . "/" . $current_file_name;

    }

    print "done!";
}


#  show which files are duplicated...
for my $current_file_hash ( keys %$files_for ){
    next if $#{ $files_for->{ $current_file_hash } } <= 0;

    print "\nUhm...these files seem to be the same to me:";
    for my $current_file_name ( @{ $files_for->{ $current_file_hash } } ){
	print "\n\t- ", $current_file_name;
    }
}


print "\n\n\nall done, bye!\n";

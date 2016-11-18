#!/usr/bin/perl

use v5.10;
use Time::HiRes qw( usleep );

open my $fh, $ARGV[0] || die "\nCannot open input file\n$!";
$/ = \1; # set one char at time (input record separator)
$| = 1;  # force autoflush
while ( <$fh> ){
    print;
    usleep( ( /[a-zA-Z]/ ? 1 : ( /[.!?\n]/ ? 10 : 2 )  ) * 75000  );
}

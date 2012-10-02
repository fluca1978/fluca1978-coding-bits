#!/usr/bin/env perl

# A simple Perl program to demonstrate calling contexts.

use strict;

# This method returns a different set of values
# depending on the status of the calling context.
# The method uses the "wantarray" operator to understand
# which context is in progress.
sub understand_calling_context{
    my (@params) = @_;

    if( wantarray ){
	# called in a LIST context
	return ( "Called in a list context",
		 ($#_ + 1) . " arguments",
		 @params
	    );
    }
    else{
	# called in a SCALAR context
	return "Called in a scalar context with " . ($#_ + 1) . " arguments: " . join( ",", @params );
    }
}



print "\nWelcome to the context simple example\n";

# a scalar context is obtained when the result is assigned to a scalar
print "\nTesting a scalar context\n";
my $scalar = understand_calling_context( 'A', 'B', 'C' );
print "\nThe result is as follows\n\t$scalar\n";

# a list context is obtained when assigning to a list/array
print "\nTesting a list context\n";
my (@array) = understand_calling_context( 'A', 'B', 'C' );
print "\nThe result is as follows\n\t@array\n";

# let see what the ref operator says...
print "\nUsing the ref operator to understand what results...\n";
print "\nSCALAR in an assignement to a scalar variable: " . ref( \$scalar ) . "\n";
print "\nLIST   in an assignement to an array: " . ref( \@array ) . "\n";

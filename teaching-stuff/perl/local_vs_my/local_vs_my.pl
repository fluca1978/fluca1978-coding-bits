#!/usr/bin/perl

# This is a demo program to demonstrate differences between the usage of 'my'
# and 'local' operators when declaring variables. This program declares a
# global variable '$argument' and two subroutines that contain a
# variable with the same name but scoped with either 'my' or 'local'.
#
# Each subroutine then defines another inner anonymous subroutine
# and provides back the reference to the subroutine, so that the latter
# can be called also from the outside context (i.e., the main context).
#
# With the usage of 'my' the '$argument' variable is attached to the scope
# where it has been defined and this is true also for the inner subroutine, that
# is, independently from where the subroutine is called, the variable keeps
# the value it had when the subroutine was defined.
#
# With the 'local' operator, the '$argument' variable keeps the value
# it has in the current context, and therefore when invoking the subroutine
# from the main context, the variable has back its original value. In other words,
# with 'local' global variables are masked out temporarily.
#
#
#  The output of the program is as follows:
#
#
#  Welcome to the my vs local demo program		        #
#  							        #
#  [using_my] argument is Hello MY world!		        #
#  [my_inner_sub] argument is Hello MY world!		        #
#  [my_inner_sub] argument is Hello MY world!		        #
#  [using_my] argument is And again, Hello MY world!	        #
#  [my_inner_sub] argument is And again, Hello MY world!        #
#  [my_inner_sub] argument is And again, Hello MY world!        #
#  [using_local] argument is Hello LOCAL world!		        #
#  [local_inner_sub] argument is Hello LOCAL world!	        #
#  [local_inner_sub] argument is Hello Main World!	        #
#  [using_local] argument is And again, Hello LOCAL world!      #
#  [local_inner_sub] argument is And again, Hello LOCAL world!  #
#  [local_inner_sub] argument is Hello Main World!	        #



sub using_my{
    my ($argument) = shift;
    
    print "\n[using_my] argument is $argument";

    my ($my_inner_sub) = sub {
	print "\n[my_inner_sub] argument is $argument";
    };

    $my_inner_sub->();

    return $my_inner_sub;
}


sub using_local{
    local ($argument) = shift;
    
    print "\n[using_local] argument is $argument";

    local ($local_inner_sub) = sub {
	print "\n[local_inner_sub] argument is $argument";
    };

    $local_inner_sub->();

    return $local_inner_sub;
}



##########################################

print "\nWelcome to the my vs local demo program\n";
$argument = "Hello Main World!";
$subref = using_my( "Hello MY world!" );
$subref->();
$subref = using_my( "And again, Hello MY world!" );
$subref->();

$subref = using_local( "Hello LOCAL world!" );
$subref->();
$subref = using_local( "And again, Hello LOCAL world!" );
$subref->();

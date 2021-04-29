#!env raku
#
#
# You are given a string containing only digits (0..9).
# The string should have between 4 and 12 digits.
# 
# Write a script to print every possible valid IPv4 address that can be made by partitioning the input string.
# 
# For the purpose of this challenge, a valid IPv4 address consists of four “octets” i.e. A, B, C and D, separated by dots (.).
# 
# Each octet must be between 0 and 255, and must not have any leading zeroes. (e.g., 0 is OK, but 01 is not.)
# Example
# 
#   Input: 25525511135,
# 
#   Output:
# 
#     255.255.11.135
#     255.255.111.35
# 

sub MAIN( Int $string = 25525511135 ) {
    say "Numeric value is $string";

      for $string ~~ m:ex/ ^ ( <[0..9]> ** 1..3 ) ** 4  $/ {
        my @ip = $_[0].map( *.Int );
        say @ip.join( '.' ) if @ip.grep( 0 <= * <= 255).elems == @ip.elems;
    }
}

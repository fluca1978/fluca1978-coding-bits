#!env perl6

# see <https://perlweeklychallenge.org/blog/perl-weekly-challenge-043/>
# Task 1: Olympic Rings
# We have allocated some numbers to these rings as below:
# Blue: 8
# Yellow: 7
# Green: 5
# Red: 9

# The Black ring is empty currently.
# You are given the numbers 1, 2, 3, 4 and 6.
# Write a script to place these numbers in the rings so that the sum of numbers in each ring is exactly 11.
#
#
# Example output
#
# % perl6 pwc_43_1.p6
# Ring Red has numbers 9,2
# Ring Yellow has numbers 7,1,3
# Ring Black has numbers 1,4,6
# Ring Green has numbers 5,4,2
# Ring Blue has numbers 8,3


my %available-numbers = 1 => True, 2 => True, 3 => True, 4 => True, 6 => True;
my %rings =
Blue => [8, Nil],
Red => [9, Nil],

Yellow => [7, 'Black', 'Blue'],
Green => [5, 'Black', 'Red'],

Black => [];

my @solving-order = <Blue Red Yellow Green Black>;


for @solving-order -> $color {

    # first try to solve the 2-elements rings
    if ( %rings{ $color }.elems == 2 ) {
        my $wanted = 11 - %rings{ $color }[ 0 ];
        if ( %available-numbers{ $wanted } ) {
            %rings{ $color }[ 1 ] = $wanted;
            %available-numbers{ $wanted } = False;
        }
    }
    elsif ( $color !~~ /Black/ ) {
        %rings{ $color }[ 2 ] = %rings{ %rings{ $color }[ 2 ] }[ 1 ];
        my $wanted = 11 - %rings{ $color }.grep( * ~~ Int ).sum;
        %rings{ $color }[ 1 ] = $wanted;
        %rings<Black>.push: $wanted;
    }
}


my $wanted = 11 - %rings<Black>.grep( * ~~ Int ).sum;
%rings<Black>.push( $wanted ) if %available-numbers{ $wanted };

for %rings.kv -> $color, @numbers {
    "Ring %s has numbers %s\n".printf: $color, @numbers.join( ',' );
}

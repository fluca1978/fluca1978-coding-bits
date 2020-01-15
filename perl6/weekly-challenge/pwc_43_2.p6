#!env perl6

# see <https://perlweeklychallenge.org/blog/perl-weekly-challenge-043/>
# Task 2: Descriptive Numbers
# Write a script to generate Self-descriptive Numbers in a given base.

# In mathematics, a self-descriptive number
# is an integer m that in a given base b is b digits long
# in which each digit d at position n (the most significant digit being at position 0 and the least significant at position b - 1) counts how many instances of digit n are in m.

# For example, if the given base is 10, then script should print 6210001000.


my $m = 6210001000;

my $base = 10;
my Range $range = "1" x $base .. "9" x $base;

for $range.list  {
    next if  $_ !~~ / ^ \d ** 10 $ /;
    say "let's try $_";
    say $_ if validate( $_.Int );
}


# say validate( $m );


# Splits the number into an array of single digits, so that the first element is
# the most important digit of the number.
# Then greps the digit in the whole array and counts how many times it appears.
# If the digit appears the right number of times, the number is fine.
sub validate( Int $number ){
    my @digits = $number.Str.split( '', :skip-empty );
    my $ok = True;
    for @digits {
        my $digit    = $_;
        my $position = $++;
        $ok &&= @digits.grep( * == $position ).elems == $digit;
        return False if ! $ok;
    }

    return True;
}

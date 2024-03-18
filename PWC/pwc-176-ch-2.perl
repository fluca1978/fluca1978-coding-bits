-- Perl Weekly Challenge 176
-- Task 2

CREATE SCHEMA IF NOT EXISTS pwc176;

CREATE OR REPLACE FUNCTION
pwc176.task2_plperl( int )
RETURNS SETOF INT
AS $CODE$

my ( $limit ) = @_;
$limit //= 100;

for my $current ( 1 .. $limit ) {
    my $sum = $current + reverse( $current );
    my @digits = split( '', $sum );
    return_next( $current ) if ( ! grep( { $_ % 2 == 0 } @digits ) );
}

return undef;


$CODE$
LANGUAGE plperl;

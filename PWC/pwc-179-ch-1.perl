-- Perl Weekly Challenge 179
-- Task 1

CREATE SCHEMA IF NOT EXISTS pwc179;

CREATE OR REPLACE FUNCTION
pwc179.task1_plperl( int )
RETURNS text
AS $CODE$
    my @units = qw/
                first
                second
                third
                foruth
                fifth
                sixth
                seventh
                eigth
                nineth
                tenth
                /;

    my @teens = qw /
              eleven
              twelve
              thriteen
              fourteen
              fifteen
              sixteen
              seventeen
              eigtheen
              nineteen
              /;
    my @non_teens = qw/
                    twenty
                    thirty
                    fourty
                    fifty
                    sixty
                    seventy
                    eighty
                    ninety
                    /;

     my ( $n ) = @_;
     return 'Cannot spell'                 if ( $n >= 100 );     
     return $units[ $n - 1 ]               if ( $n <= 10 );
     return $teens[ ( $n - 1 ) % 10  ]     if ( $n > 10 && $n < 20 );
     return $non_teens[ ( $n / 10 ) - 2 ]  if ( $n >= 20 && $n % 10 == 0 );
     return $non_teens[ ( $n / 10 ) - 2 ] . $units[ ( $n % 10 ) - 1 ] if ( $n > 20 );


$CODE$
LANGUAGE plperl;

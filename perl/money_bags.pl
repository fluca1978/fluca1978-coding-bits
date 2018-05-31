use v5.20;
use DateTime;
my $now = DateTime->now();

for ( 1..823 ){
    $now->set( day => 1, month => $_ )
        &&
        say "Year " . $now->year . " month " . $now->month
        . " has 5 " . join ', ', qw( Mon Tue Wed Thu Fri Sat Sun )
        [ map {  $_ , ( $_ + 1 ) % 7 , ( $_ + 2 ) % 7  } ( $now->day_of_week - 1 ) ]
        for ( grep { ( $_ % 2 == 0 && $_ > 7 ) || ( $_ % 2 == 1 && $_ <= 7 ) } ( 1..12 ) );

    $now->add( years => 1 );
}

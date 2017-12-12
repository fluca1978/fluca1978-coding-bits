#!env perl

use v5.20;
use File::Find;
use Data::Dumper;

my $posts = {};

my $filter = sub {

    return if ( ! -f $_ );
    return if ( $_ !~ /^\d{4}-\d{2}.*$/ );

    if ( $_ =~ /^(\d{4})-(\d{2})-\d{2}.*$/ ){
        my ( $year, $month ) = ( $1, $2 );
        $posts->{ $year }->{ "$year-$month" }++;
    }
};

find( $filter, $ARGV[ 0 ] );

say Dumper( $posts );

for my $year ( sort keys %$posts ){
    my $data_file = "/tmp/posts-$year.csv";
    open my $csv, '>', $data_file ;
    say {$csv} "$_;$posts->{ $year }->{ $_ };" for ( sort keys %{ $posts->{ $year } } );
    close $csv;


    open my $gnuplot, '>', "/tmp/plot-$year.gnuplot";
    say {$gnuplot} << "GNUPLOT";
#!env gnuplot
reset
set terminal png

set title "Post Ratio"
set xlabel "Month"
set xdata time
set timefmt '%Y-%m'
set format x "%b/%y" # Or some other output format you prefer
set xtics "$year-01", 7776000 rotate by 60 right
set datafile separator ';'
set ylabel "Post count"
set grid
set style fill solid 1.0
set boxwidth 0.9 relative

plot "$data_file"  using 1:2 title "" with boxes linecolor rgb "#bbFFFF"
GNUPLOT
    close $gnuplot;

}


my $counter;
for my $year ( sort keys %$posts ){
    $counter->{ $year } += $posts->{ $year }->{ $_ }  for ( sort keys %{ $posts->{ $year } } );
}

say Dumper( $counter );

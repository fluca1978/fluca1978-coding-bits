#!env perl

use v5.20;
use File::Find;
use Data::Dumper;

use File::Slurp;
use Text::FrontMatter::YAML;

my $posts = {};

my $filter = sub {

    return if ( ! -f $_ );
    return if ( $_ !~ /^\d{4}-\d{2}.*$/ );

    my ( $year, $month );

    if ( $_ =~ /^(\d{4})-(\d{2})-\d{2}.*$/ ){
        ( $year, $month ) = ( $1, $2 );
        $posts->{ $year }->{ "$year-$month" }++;
    }

    open my $fh, "<", $File::Find::name;
    my @tags = ();
    my $found = undef;
    while ( my $line = <$fh> ) {
        $found = 1 if ( $line =~ /^tag(s)?:/ );
        if ( $found && $line =~ /^\-\s+(\w+)$/ ){
            push @tags, lc $1;
        }
        last if ( $found && $line =~ /^[-]{3}$/ );
    }
    close $fh;

    for my $tag ( @tags ){
        next if ( ! $tag );
        $posts->{ TAGS }->{ $tag }++;
    }

};

find( $filter, $ARGV[ 0 ] );

say Dumper( $posts );
my $plots = {};


for my $year ( sort keys %$posts ){
    my $data_file = "/tmp/posts-$year.csv";
    open my $csv, '>', $data_file ;
    say {$csv} "$_;$posts->{ $year }->{ $_ };" for ( sort keys %{ $posts->{ $year } } );
    close $csv;

    my $plot = "/tmp/plot-$year.gnuplot";
    $plots->{ $year } = $plot;
    open my $gnuplot, '>', $plot;
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

plot "$data_file"  using 1:2 title "" with boxes linecolor rgb "#bb00FF"
GNUPLOT
    close $gnuplot;


    $plot = "/tmp/plot-tags.gnuplot";
    $plots->{ tags } = $plot;
    my $data_file = "/tmp/posts-tags.csv";
    open my $csv, '>', $plot;
    my $top = 0;
    my @keys = sort  { $posts->{ TAGS }->{ $b } <=> $posts->{ TAGS }->{ $a } } keys %{ $posts->{ TAGS } };

    for $_ ( @keys ){
        say {$csv} "$_;$posts->{ TAGS }->{ $_ };";
        $top++;
        last if ( $top >= 10 );
    }
    close $csv;


    open my $gnuplot, '>', "/tmp/plot-tags.gnuplot";
    say {$gnuplot} << "GNUPLOT";
#!env gnuplot
reset
set terminal png

set title "Post Ratio"
set auto x
set xlabel "Tag"
set xtics rotate by 60 right
set datafile separator ';'
set ylabel "Post count"

set style fill solid 1.0
set boxwidth 0.9 relative
plot "$data_file"  using 2:xtic(1) title "" with boxes linecolor rgb "#bb00FF"
GNUPLOT

    close $gnuplot;
}


my $counter;
for my $year ( sort keys %$posts ){
    $counter->{ $year } += $posts->{ $year }->{ $_ }  for ( sort keys %{ $posts->{ $year } } );
}

say Dumper( $counter );


for my $year ( sort keys %$plots ){
    `gnuplot $plots->{$year} > $ARGV[1]/$year.png`;
}

#!perl

use v5.30;


use constant KB => 1024;
use constant MB => 1024 * 1024;
use constant GB => 1024 * 1024 * 1024;
use constant TB => 1024 * 1024 * 1024 * 1024;


sub human_size {
  no warnings;
  my ( $size ) = $_[0];
  given( $size ) {
    when ( $_ >= TB ) { sprintf "%.2f TB", $_ / TB; }
    when ( $_ >= GB ) { sprintf "%.2f GB", $_ / GB; }
    when ( $_ >= MB ) { sprintf "%.2f MB", $_ / MB; }
    when ( $_ >= KB ) { sprintf "%.2f kB", $_ / KB; }
    default           { sprintf "%d bytes", $_;     }
  }
}





use constant SIZE_NAMES => qw/ tera giga mega kilo /;

sub human_size_fancy {
    my ( $size ) = @_;
    my @scale = (SIZE_NAMES);
    while ( $size < ( 1024 ** @scale ) ) {
	shift @scale;
    }

    sprintf '%.2f %sbytes', ( $size / ( 1024 ** @scale ) ), $scale[ 0 ];
}


sub human_size_more_fancy {
    my ( $size ) = @_;
    for my $i ( 0 .. scalar (SIZE_NAMES) ) {
	next if $size < ( 1024 ** ( scalar (SIZE_NAMES) - $i ) );
	return sprintf '%.2f %sbytes', ( $size / ( 1024 ** ( scalar (SIZE_NAMES) - $i ) ) ), (SIZE_NAMES)[ $i ];
    }
}




say human_size_fancy( 800 );
say human_size_fancy( 123_456 );
say human_size_fancy( 987_654_321 );


say human_size( 800 );
say human_size( 123_456 );
say human_size( 987_654_321 );


say human_size_more_fancy( 800 );
say human_size_more_fancy( 123_456 );
say human_size_more_fancy( 987_654_321 );

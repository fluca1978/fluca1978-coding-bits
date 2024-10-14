#!raku
#
# Example of invocation
#
# % raku imager.raku --input=src9.png --output=shuffled.png --force
#
#

use MagickWand;
use MagickWand::Enums;

sub MAIN( Str:D :$input,
	  Str:D :$output,
	  Int :$size = 3,
	  Bool :$force
	       where { $input.IO.e
		       && $size > 1 && $size !%% 2
		  && ( $force || ! $output.IO.e ) } = False ) {

    my ( $src, $dst ) = MagickWand.new xx 2;
    $src.read: $input;

    die Q｢Serve un'immagine "abbastanza" quadrata!｣ unless ( 0.9 < $src.width / $src.height < 1.1 );

    my ( $crop-x, $crop-y ) = ( ( $src.width, $src.height ) <</>> ( $size xx 2 ) ).map( *.Int );
    my ( $center-x, $center-y ) = ( $size / 2 ).Int xx 2;

    my @blocks = ( ( 0 ..^ $size ) X ( 0 ..^ $size ) )
		     .map( { %( row    => $_[ 1 ],
				col    => $_[ 0 ],
				center => $_[ 1 ] == $center-x && $_[ 0 ] == $center-y,
				image  => $src.clone ) } );
    for @blocks  {
	$_<image>.crop: $_<row> * $crop-x, $_<col> * $crop-y, $crop-x, $crop-y;
	next if $_<center>;
	$_<image>.blur( 0, 10 );
    }

    $dst = MagickWand.montage( @blocks.map( *<image> ),
			       "{$size}x+0+0",
			       "{$crop-x}x{$crop-y}+0+0",
			       FrameMode, '0x0+0+0');
    $dst.write( $output );

}

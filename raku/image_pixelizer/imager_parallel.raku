#!raku
#
# Example of invocation
#
# % raku imager.raku --input=trinity.png --output=guess.png --force
#
#

use MagickWand;
use MagickWand::Enums;

sub MAIN( Str  :$input!,
	  Str  :$output!,
	  Int  :$size = 3,
	  Bool :$force?
	       where { $input.IO.e
		       && $size > 1 && $size !%% 2
		  && ( $force || ! $output.IO.e ) } ) {

    my $src = MagickWand.new;
    $src.read: $input;

    die Q🐪Serve un'immagine "abbastanza" quadrata!🐪 unless ( 0.9 ≤ $src.width / $src.height ≤ 1.1 );

    my ( $crop-x, $crop-y ) = ( ( $src.width, $src.height ) «/» $size ).map( *.Int );

    my @blocks = ( ( 0 ..^ $size ) X ( 0 ..^ $size ) )
		     .map( { %( row    => $_[ 1 ],
				col    => $_[ 0 ],
				center => $_[ 1 ] == $_[ 0 ] == ( $size / 2 ).Int,
				image  => $src.clone ) } );

    @blocks .= map( { start {
	  $_<image>.crop: $_<row> * $crop-x, $_<col> * $crop-y, $crop-x, $crop-y;
	  $_<image>.blur( 0, 10 ) unless $_<center>;
	  $_<image>;
        } } );

    await @blocks;
    MagickWand.montage( @blocks.map( *.result ),
			"{$size}x+0+0",
			"{$crop-x}x{$crop-y}+0+0",
			FrameMode, '0x0+0+0')
    .write: $output;

}

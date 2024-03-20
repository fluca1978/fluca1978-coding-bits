#!python

import sys
import itertools
import glob
import shlex
import subprocess

# Example of invocation: img_pixelier.py src9.png

if __name__ == '__main__':
    src_file = sys.argv[ 1 ]

    output = subprocess.run(['convert', src_file , '-crop', '250x250', '+repage', '+adjoin', 'segment-%d.png' ],
                            stdout=subprocess.PIPE)


    dst_image_counter = 1

    files = glob.glob( "segment-?.png" )
    file = files.sort()
    center_segment = int( len( files ) / 2  )
    print( f'Center segment is {center_segment}' )

    for segment in files:
        if segment == f'segment-{center_segment}.png':
            continue

        print( f'Blurring {segment}' )
        # convert -scale 10% -scale 1000% original.jpg pixelated.jpg
        args = shlex.split( f'convert {segment} -blur 25x25 {segment}' )
        subprocess.run( args )

    args = shlex.split( 'montage '+ ' '.join( files ) + ' blurred.png' )
    merge = subprocess.run( args )


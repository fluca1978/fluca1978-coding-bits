#!python

import sys
import itertools
import glob
import shlex
import subprocess

# Example of invocation: img_shuffle_parts.py src.png

if __name__ == '__main__':
    src_file = sys.argv[ 1 ]

    output = subprocess.run(['convert', src_file , '-crop', '250x250', '+repage', '+adjoin', 'segment-%d.png' ],
                            stdout=subprocess.PIPE)

    how_many_segments = 0
    dst_image_counter = 1

    files = glob.glob( "segment-?.png" )
    print( files )

    def all_permutations( x ):
        for r in range( 1, len( x ) + 1 ):
            yield from itertools.permutations( x, r )

    combinations = list( map( ' '.join, all_permutations( files ) ) )
    for to_merge in combinations:
        dst = f'shuffled-%02d.png' % dst_image_counter
        dst_image_counter += 1

        args = shlex.split( 'montage ' + to_merge + ' ' + dst )
        merge = subprocess.run( args )
        print( "Created image " + dst )

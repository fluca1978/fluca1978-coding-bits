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


    dst_image_counter = 1

    files = glob.glob( "segment-?.png" )
    combinations = list( map( ' '.join, itertools.permutations( files, len( files ) ) ) )
    for to_merge in combinations:

        dst = f'shuffled-%02d.png' % dst_image_counter
        dst_image_counter += 1

        args = shlex.split( 'montage ' + to_merge + ' ' + dst )
        merge = subprocess.run( args )
        print( "Created image " + dst )

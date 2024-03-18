#!python

import sys
import subprocess
import itertools
import shlex
import io

# Example of invocation: img_shuffle_parts.py src.png

if __name__ == '__main__':
    src_file = sys.argv[ 1 ]

    output = subprocess.run(['convert', src_file , '-crop', '250x250', '+repage', '+adjoin', 'segment-%d.png' ],
                            stdout=subprocess.PIPE)

    how_many_segments = 0
    dst_image_counter = 0

    args = shlex.split( 'ls segment-?.png' ) # argh! not working, lists everything!
    print( args )
    proc = subprocess.Popen([ 'ls',  'segment-?.png'],stdout=subprocess.PIPE, shell=True)
    for line in io.TextIOWrapper(proc.stdout, encoding="utf-8"):
        if line.startswith( 'segment' ):
            how_many_segments += 1

    for p in list( itertools.permutations( range( 0, how_many_segments ) ) ):
        to_merge = []
        dst = 'dst-p' + str( dst_image_counter ) + '.png'
        dst_image_counter += 1

        for i in p:
            to_merge.append( 'segment-' + str( i ) + '.png' )

        args = shlex.split( 'montage ' + ' '.join( to_merge ) + ' ' + dst )
        merge = subprocess.run( args )
        print( "Created image " + dst )

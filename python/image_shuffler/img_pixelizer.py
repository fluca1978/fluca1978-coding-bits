#!python

import sys
import itertools
import glob
import shlex
import subprocess
from wand.image import Image

# Example of invocation: img_pixelier.py src9.png

if __name__ == '__main__':
    src_file = sys.argv[ 1 ]

    src_image  = Image( filename = src_file )
    src_width  = src_image.width
    src_height = src_image.height

    pieces      = 3
    crop_width  = int( src_width / pieces )
    crop_height = int( src_height / pieces )

    dst_image = Image( width = src_width, height = src_height )
    for r in range(0, pieces):
        for c in range(0, pieces):
            start_at_x = c * crop_width
            start_at_y = r * crop_height
            segment = Image( filename = src_file )
            segment.crop( start_at_x, start_at_y, width = crop_width, height = crop_height )
            if c != r or c != int( pieces / 2 ) or r != int( pieces / 2 ):
                segment.blur( sigma = 20 )

            dst_image.composite( image = segment, left = start_at_x, top = start_at_y )

    dst_image.save( filename = 'blurred.png' )

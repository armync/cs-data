#!/bin/bash

mkdir -p /tmp/smallfiles # directory to copy to

find "/test" -maxdepth 1 -type f -size -20k -exec ls -lh {} \; -exec cp -v {} /tmp/smallfiles/ \;

# start searching in the dir choosen
# maxdepth - only look inside that directory; not subdirs
#          0: the dir itself
#          1: only files and folders inside dir
#          2: two levels deep (e.g. ./subdir/file2)
# find only files
# match files smaller than 20 KiB
# exec as for each file found list  its details and size (human readable)
# copy elements to set dir
#
# {} - replaced with file name
# \; - end of exec

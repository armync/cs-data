#!/bin/bash

d="$(dirname "$(command -v sh)")" # gets full path of executable
                                  # then takes full path and returns
				  # only the directory, no filename				   

shopt -s nullglob # ignore unmatched  so literal 'git*' is not printed

# loop over files with git*
for f in "$d"/git*; do # if no match, expand to nothing 
	if [ -f "$f" ]; then # check regular file
		basename "$f" # print file name (no dir)
	fi
done

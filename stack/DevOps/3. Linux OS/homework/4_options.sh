#!/bin/bash

if [ "$#" -eq 0 ]; then
	printf "There should be at least 1 arg..."
	printf "e.g. ./4_options.sh [-l] <arg_1> [arg2]"
	exit 1;
fi

LAST=false

if [[ "$1" == "-l" ]]; then
	LAST=true
	shift # removes -l flag from the list of 
fi

if [[ "$#" -eq 0 ]]; then
	printf "There should be a SEPARATE argument besides the flag/option [-l]!"
	exit 1;
fi

if [[ "$LAST" == "true" ]]; then
	printf "%s\n" "$@" | sort -f | tail -n 1
else
	printf "%s\n" "$@" | sort -f | head -n 1
fi

# - "#@" expands to all args as separate words
# - prints per line
# - sorts with fold case (ignore casing)
# - takes first/last arg out of the sorted line

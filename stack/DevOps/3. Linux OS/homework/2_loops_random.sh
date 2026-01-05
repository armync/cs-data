#!/bin/bash

RANDOM=$$ # PID seed - avoid conflicts

COUNT=0

while true; do
	if [[ "$COUNT" -lt 5 ]]; then
		NUM=$RANDOM
		if [[ $((NUM % 2)) -eq 0 && $((NUM % 3)) -ne 0 ]]; then
	       		printf "$NUM\n"
			COUNT=$(( COUNT+1 ))
		fi
	else
		exit 0;
	fi
done

#!/bin/bash

## display environment variables of all processes
## belonging to all bash sessions of the current user
#

bash_pids=$(pgrep -u "$USER" -x bash 2>/dev/null || true)
# pgrep: find and list all process IDs (pids)
# only processes owned by current user
# --x bash: exact name match
# redirects standard error to null (discards)
# set to true even if nothing found

[ -n "${bash_pids}" ] || exit 0
# if empty, exits

for b in ${bash_pids}; do
 
 	sid=$(ps -o sid= -p "$b" 2>/dev/null)
 	# -o sid= -> output format: shows only the
	# SID (session id) and = removes header
	# -p -> specify the PID (process id) to inspect (iterates through all)

  
 	[ -n "${sid:-}" ] || continue
	# go over next iteration if no sid



 	pids_in_sid=$(ps --no-headers -eo pid=,sid=,lstart= --sort=lstart | awk -v sid="$sid" '$2==sid {print $1}')
	# suppress the column header
	# -e: show every processes (system wide)
	# -o: custom output: print PID, SID, process (long) start time
	# .. =: removes header from each column
	# sort all processes by start time (oldest first)
	#- awk filters rows whose sid equals the target sid and prints only pid

	for p in ${pids_in_sid}; do
    		printf "pid $p:"
		
	


		if [[ -r "/proc/$p/environ" ]]; then # checks file exists/readable
			cat "/proc/$p/environ" 2>/dev/null | tr '\0' '\n' | grep -vE '^(XDG_|LC_)'
		fi
		# the file "/proc/$p/environ" contains the environment
		# variables of a running process. each one is stored
		# as a null-sepparated string. ('nul' byte, invisible)
		#
		# tr: translate characters -> replaces null bytes (\0)
		# with newlines (\n)
		#
		# redirects the file as input to tr.
		#
		# after formatting, grep filters.
		# 	-v : invert matches (show what don't match)
		# 	-E: extended regular expressions (e.g. ^)
		# ... it doesn't print any noisy env var such as XDG

    printf "\n\n========================\n\n" # iteration separator
  done
done

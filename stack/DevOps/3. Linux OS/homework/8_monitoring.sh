#!/bin/bash

pct=20 # alert if less than %
mb=0 # mb check (disabled by default)
excludes="" # skip mount with specific string

while [[ $# -gt 0 ]]; do
        case "$1" in # check flag passed and sets threshold
                -p) pct=$2; shift 2 ;; # shift 2 remove flag and value from $@
                                       # so all these remain on flag $1
                -m) mb=$2; shift 2 ;;
                -e) excludes="$excludes $2"; shift 2 ;;
                *) printf " [-p PERCENT] [-m MB] [-e TEXT]"; exit 1 ;;
        esac
done

warn=0 # increase to 1 if any mount is low on space

while read -r fs size used avail usep mount; do

# disk usage table in MB
#       -m -> MB
#       -P -> POSIX/simple
# ... tail removes header line
# read - splits each line into vars:
#       fs: filesystem
#       size = total MB
#       used = used MB
#       avail = available MB
#       usep = used %
#       mount = mount point (e.g. /)

        freepct=$((100 - ${usep%%%})) # compute free percent; removes the % sign

        skip=0
        
	for x in $excludes; do 
    		[[ -n "$x" && "$mount" == *"$x"* ]] && { skip=1; break; }
	done
	((skip)) && continue


# checks if any excluded string is found in the mountpoint
# if true, increases skip and goes on next while filesystem
# * - wildcard
# -n -> checks if non-empty
# (( x )) - numeric test; is it true? do ... (after &&)

        if (( freepct < pct )) || ( (( mb > 0 )) && (( avail < mb )) ); then
                printf "LOW: %s - %d%% free (%dMB left)\n" "$mount" "$freepct" "$avail"
                warn=1
        fi
done < <(df -Pm | tail -n +2)

exit $warn # returns 1 if anything happened


#!/bin/bash

## user parameter
#

user="${1:-user}" # if no (first) arg passed, fallback (param:-default) to 'user'
user="$( tr '[:lower:]' '[:upper:]' <<< "${user:0:1}" )${user:1}"

# $(var:offset:len)
# :0:1 -> extract 1 char from position 0 (first letter)
# :1 everything after the first leter
# <<< feed from string

## short hostname
#

machine="$(hostname -f)" # -full hostname (e.g. laptop.example.com)
machine="${machine%%.*}" # trims everything after the first dot (.)
                         # %% = remove the longest match of pattern from the end,
			 #      basically everything from right to dot.

## system uptime
#

running="$(uptime --pretty)"        # human readable; e.g. up 3h, 15min...
running="${running/up/running for}" # take values of $running, replaces first inside
                                    # occurence -- the text "up" with "running for"
				    # and stores the result back into $running
				    # usage: ${val/pattern/repl}
				    #             // -> all matches
				    #             # -> only if at start
				    #             % only if at the end

## heredoc message
#

cat <<EOF > /tmp/message.txt
Hello $user!
Please log off from ${machine} in 5 minutes!
This machine has been ${running}.
EOF

## file perm
#

chmod 600 /tmp/message.txt

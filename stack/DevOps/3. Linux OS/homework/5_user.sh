#!/bin/bash

read -p "Give an user name: " username

if grep -q  "^$username" /etc/passwd; then # quiet, no display; check for matches
	printf "$username exists!"
else
	printf "$username doesn't exist!"
        exit 1;
fi

# "^" ensure exact username field - pattern at very first start
# of line (avoids false positives such as  "notusername")

home=$(awk -F: -v u="$username" '$1==u {print $6}' /etc/passwd)
shell=$(awk -F: -v u="$username" '$1==u {print $7}' /etc/passwd)

# field separator is " : " as passwd has colons
# pass "$username" as a variable called "u"
# matches only the line where field 1 (username) equals variable "u"

printf '\nThe home of user %s is %s and login shell is %s\n' "$username" "$home" "$shell"


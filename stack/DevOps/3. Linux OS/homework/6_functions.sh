#!/bin/bash

## concatenate all args
#

concat_str(){
	final_str=""

	for str in "$@"; do
		final_str+="$str"
	done

	printf "$final_str\n"
}

## populate associative array with str < 3
##

small_str(){
	declare -A final_arr=()

	for str in "$@"; do
		if (( ${#str} <  3 )); then
			final_arr["$str"]=${#str} # value as length
		fi
	done

	## outputs the content
	#
	
	
	for arr in "${!final_arr[@]}"; do
		printf '%s : %s\n' "$arr" "${final_arr[$arr]}"
	done
}

## main function - pass arg
#

main(){

	if (( $# == 0 )); then
		printf "Arguments needed!\n"
		exit 1;
	fi

	## call subfunctions, per each arg
	#
	
	concat=$(concat_str "$@")
	printf "Concatenated: $concat\n"

	small=$(small_str "$@") 
	# multi-line string, not an associative array anymore
	# e.g. ok : 2\ny : 1
	
	printf "Small array: $small\n"

	concat_len=${#concat}

	
	small_len=$(printf "$small" | wc -c)
	# checks the number of bytes
	# e.g.: o k : 2 \n y : 1 -> 6 + 1 + 6 = 13 bytes (ASCII)
	
	#sum=0
	#small_len=$(awk -F ':' '{sum += $2} END {print sum}' <<< "$small")
	# parse the numeric value out of "$small" 
	# --  e.g. key : value; sums up the values

	if (( concat_len > small_len )); then
		printf "Concat is larger than small\n"
	elif (( concat_len < small_len )); then
		printf "Small is larger than concat\n"
	else printf "Same length\n"
	fi
}

main "$@" # calls main and passes arg

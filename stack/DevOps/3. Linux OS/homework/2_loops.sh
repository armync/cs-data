#!/bin/bash

SUM=0
for i in {1..100..2} # 2 by 2 step
do
	(( SUM=SUM+i )) # arithmetic assignment (NO $)
done

printf "Suma este '$SUM'".

DIV=$(( SUM/100 ))

printf "\n'$SUM' / 100 este: '$DIV'\n"

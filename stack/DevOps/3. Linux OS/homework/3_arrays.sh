#!/bin/bash

declare -a ro_cars de_cars cars
declare -A country_of # associative array

while read -r items; do
	ro_cars+=("$items")
done < <(echo -e "Dacia\nAro")

de_cars+=("BMW" "Audi" "Mercedes")

de_cars+=("Opel")

echo "ro_cars: ${ro_cars[@]}"
echo "de_cars: ${de_cars[@]}"


cars+=( "${ro_cars[@]}" "${de_cars[@]}" )

unset 'cars[1]' # removes Aro

cars=( "${cars[@]}" ) # reindex to close the hole caused by removal

printf "Cars (*): %s\n" "${cars[*]}"

printf "Cars (@): %s\n" "${cars[@]}"

for car in "${ro_cars[@]}"; do
       country_of["$car"]="Romania"
done

for car in "${de_cars[@]}"; do
	country_of["$car"]="Germany"
done

for make in "${!country_of[@]}"; do
	printf 'Brand name: %s, Country of origin: %s\n' "$make" "${country_of[$make]}"
done


count=0

start=$(date +%s%3N)

for file in /test/*; do
	matches=$(grep -or test "$file" | wc -l)
	count=$((count+matches))
done

end=$(date +%s%3N)

total=$((end-start))

echo "Total occurrences: $count"
echo "Total time elapsed: ${total} ms"

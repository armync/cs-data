FILENAME=/tmp/test1

if [ ! -f "$FILENAME" ]
then
	touch "$FILENAME"
	chmod 777 "$FILENAME"
fi

CURR_USER=$(id -u -n)

FILE_OWNER=$(stat -c "%U" "$FILENAME")

if [[ "$CURR_USER" != "$FILE_OWNER" ]]; then
	echo -e "File "$FILENAME" not owned by the user "$CURR_USER" !"
	echo -e "Giving permissions..."

	chown "$CURR_USER":"$CURR_USER" "$FILENAME"
fi

LINES=$(wc -l < "$FILENAME")

if [[ "$LINES" -eq 0 ]]; then
	printf "no lines"
else
	printf "'$LINES' lines in file"
fi

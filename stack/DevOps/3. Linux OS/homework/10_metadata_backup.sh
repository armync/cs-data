#!/bin/bash

set -e	# stop the script if error

BACKUP_DIR="/tmp/backup"
mkdir -p "$BACKUP_DIR"

TARGET="${1:-$0}" # use argument or default to this script file
TIMESTAMP=$(date +%Y%m%d_%H%M%S) # current date-time for unique archive name

## directory
#

if [ -d "$TARGET" ]; then
	BASE=$(basename "$TARGET") # just the folder name, no path
	OUT="$BACKUP_DIR/${BASE}_${TIMESTAMP}.tar.gz"

	printf "Backing up directory: %s\n" "$TARGET"

	tar -czf "$OUT" -C "$TARGET" $(find "$TARGET" -type f \( -name "*.sh" -o -name "*.txt" -o -name "*.log" \) -printf "%P\n")
	# -c: create new archive
	# -z: compress via gzip
	# -f: write archive to the file ...
	# -C: change directory path
	#
	# runs find command for multiple types .sh OR .txt OR .log

	printf "Backup saved to: %s\n" "$OUT"
	exit 0;
fi

## file
#

if [ -f "$TARGET" ]; then
	BASE=$(basename "$TARGET") # get filename only
	COPY="$BACKUP_DIR/$BASE" # destination path in backup folder
	OUT="$BACKUP_DIR/${BASE}_${TIMESTAMP}.tar.gz"

        printf "Backing up file: %s\n" "$TARGET"


	# if a previous copy exists, rename it to <name>_old
	[ -e "$COPY" ] && mv "$COPY" "${COPY}_old"

	# copy the file to backup folder
	cp "$TARGET" "$COPY"

	# file metadata
	OWNER=$(stat -c %U "$TARGET")	# file owner
	PERMS=$(stat -c %A "$TARGET")	# permissions (symbolic)
	CHANGED=$(stat -c %y "$TARGET")	# last modification date

	# add metadata on header
	{
		printf "# owner: $OWNER"
		printf "# permissions: $PERMS"
		printf "# changed date: $CHANGED"
		cat "$COPY"
	} > "${COPY}.tmp" && mv "${COPY}.tmp" "$COPY"	# replace original file

	# create compressed archive of the backup file
	tar -czf "$OUT" -C "$BACKUP_DIR" "$BASE"

	
        printf "Backup file saved to: %s\n" "$OUT"

	exit 0;
fi

# if the target is neither a file nor a directory
echo "'$TARGET' missing"
exit 1;


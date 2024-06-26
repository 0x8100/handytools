#!/bin/sh
set -e

# update_gzip.sh
# 
# Search *.(css|js|txt|html) files under the specified directory and gzip
# whose timestamps have changed. Files lost from the list will have their
# corresponding gzip files deleted.

# Usage: ./check_files.sh target_directory TIMESTAMP_FILE.txt
TARGET_DIR=$1
TIMESTAMP_FILE=$2

# Set owner of gzip files
SET_OWNER="sudo -u www"

# Check if target directory and output file are provided
if [ -z "$TARGET_DIR" ] || [ -z "$TIMESTAMP_FILE" ]; then
  echo "Usage: $0 target_directory TIMESTAMP_FILE.txt"
  exit 1
fi

# Create tmpfile
tmpfile=$(mktemp)
function rm_tmpfile {
  [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
trap rm_tmpfile EXIT
trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

# Save current timestamps to a temporary file
find "$TARGET_DIR" -type f \( -iname "*.txt" -or -iname "*.css" -or -iname "*.js" -or -iname "*.html" \) \
                                                                  -exec stat -f "%m %N" {} \; > "$tmpfile"

# Save $TIMESTAMP_FILE and exit if the file has not exists
if [ ! -e "$TIMESTAMP_FILE" ]; then
  cp "$tmpfile" "$TIMESTAMP_FILE"
  exit
fi

# Compress files with new or Remove gzip if missing
while IFS= read -r line; do
  TIMESTAMP=$(echo "$line" | awk '{print $1}')
  FILE=$(echo "$line" | awk '{print $2}')

  if [ -e "$FILE" ]; then
    CURRENT_TIMESTAMP=$(stat -f "%m" "$FILE")
    if [ "$CURRENT_TIMESTAMP" -gt "$TIMESTAMP" ]; then
      $SET_OWNER gzip -kf "$FILE"
    fi
  else
    $SET_OWNER rm "$FILE.gz"
  fi
done < "$TIMESTAMP_FILE"

# Compress new files
grep -Fvxf "$TIMESTAMP_FILE" "$tmpfile" | while IFS= read -r line; do
  FILE=$(echo "$line" | awk '{print $2}')
  $SET_OWNER gzip -kf "$FILE"
done

# Update TIMESTAMP_FILE with the current timestamps
cp "$tmpfile" "$TIMESTAMP_FILE"

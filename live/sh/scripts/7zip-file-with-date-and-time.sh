#!/usr/bin/env  sh


# Compress a file and append the date and time to its filename.
# Note that 7-zip does not store the owner/group of the file.


date_and_time=` \date  --utc  +'%Y-%m-%d-%H-%M' `
filename="$1 - $date_and_time".7z

echo \7z  a  \
  ` # maximum compression ` \
  -mx9 \
  "$filename" \
  "$1"
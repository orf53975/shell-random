#!/usr/bin/env  sh



# Goal
# Given a series of directories.
# Open a text file located within each directory.
# Prefer loading some files first, so they will appear as the first tabs.


# Windows Subsystem for Linux
if [ -d '/mnt/c' ]; then
  l='/mnt/d/live'
else
  l='/l'
fi


# FIXME - If run multiple times, it will attempt to open a new tab with a nonexistent file.
#         This is likely because I have a leading or trailing printf in the final command.

# TODO - read a file which has a list of directories to skip
# TODO - skip directories containing a directory or file named `ECRYPTFS_FNEK_ENCRYPTED.*`

setup() {
  \echo  ' * begin'
  NEW_PROJECT_MESSAGE="New project notes started ` \date `"
  # Case-insensitivity.
  LC_COLLATE=en_US ; export LC_COLLATE
  # IFS (Internal Field Separator), change to a carriage return.
  IFS_original=$IFS
  IFS=` \printf "\r" `
}


build_array_of_directories() {
  if [ -z "$1" ]; then continue; fi
  for i in "$1"/*; do
    if [ -z "$i" ]; then continue; fi
    # Skip non-directories
    # Note that this will not skip symlinks.
    if ! [ -d "$i" ]; then
      \echo  "skipping non-directory  $i"
      continue
    fi
    #\echo  "processing - $i"
    # I don't know why this won't work:
    #array_of_directories="$array_of_directories$IFS$i"
    # Technically I shouldn't be adding a \r to the beginning of the array, but it doesn't seem to matter.
    array_of_directories="$array_of_directories` \printf \"\r\" `$i"
  done
  #echo --v
  #for i in $array_of_directories; do
    #echo $i
  #done
  #echo --^
  #return
}


build_array_of_files() {
  if [ -z "$1" ]; then continue; fi
  # $1 is an array of directories
  # This $1 must not be quoted! :
  for i in $1; do
    if [ -z "$i" ]; then continue; fi
    file="$i/` \basename  "$i" `".txt
    # Create files as necessary
    # TODO? - Skip files in an array of exclusions
    # TODO - check if this will work properly with symlinks.
    if ! [ -f "$file" ]; then
      \echo .
      \echo  "   New project $i, inserting message:"
      \echo  "$NEW_PROJECT_MESSAGE"
      \echo .
      \touch  "$file"
      \echo  "$NEW_PROJECT_MESSAGE" >> "$file"
    fi
    size_of_file=` \stat  --printf="%s"  "$file"  |  \cut -f 1 `
    if [ "$size_of_file" = "0" ] ; then
      \echo  "skipping 0-byte file:  $file"
      continue
    fi
    \echo  "processing - $file"
    array_of_files="$array_of_files` \printf \"\r\" `$file"
  done
  #echo --v
  #for i in $array_of_files; do
    #echo $i
  #done
  #echo --^
  #return
}


open_array_of_files() {
  if [ -d '/mnt/c' ]; then
    \geany  --new-instance \
      $l/__/__.txt \
      $l/live/projects/projects.txt \
      $l/_outbox--0/_outbox--0.txt \
      $array_of_files \
      $l/__/__.txt \
    &
  else
    #echo  \geany  $array_of_files
    #\geany  $array_of_files
    \geany  --new-instance \
      $l/__/__.txt \
      $l/live/projects/projects.txt \
      ` # A major project of mine which ought to be reviewed very regularly. ` \
      '/l/unplugging/unplugging.txt' \
      $l/_outbox--0/_outbox--0.txt \
      '/mnt/1/windows-data/live/_outbox--0/_outbox--0.txt' \
      '/mnt/1/windows-data/live/_outbox--1/_outbox--1.txt' \
      $array_of_files \
      $l/__/__.txt \
    &
  fi
}



teardown() {
  IFS=$IFS_original
  \echo  ' * end'
}



# --
# --  The actual work
# --

setup
if [ -d '/mnt/c' ]; then
  # Windows Subsystem for Linux
  build_array_of_directories  $l
else
  build_array_of_directories  $l
  build_array_of_directories  $l/live/projects
  build_array_of_directories  '/mnt/1/windows-data/live'
  build_array_of_directories  '/mnt/1/windows-data/live/projects'
fi
build_array_of_files  "$array_of_directories"

open_array_of_files
teardown

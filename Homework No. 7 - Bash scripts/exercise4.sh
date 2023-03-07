#!/bin/bash

# prompt the user for a file or directory name
echo "Enter the name of a file or directory: "
read name

# Check if it is a regular file, a directory, or another type of file
if [ -f "$name" ]
then 
    echo "$name is a regular file."
elif [ -d "$name" ]
then
    echo "$name is a directory."
else
    echo "$name is another type of file."
fi

# Perform an ls command with long listing option
ls -l "$name"

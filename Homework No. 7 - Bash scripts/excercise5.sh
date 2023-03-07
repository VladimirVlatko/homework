#!/bin/bash

# Check that three arguments were provided
if [ $# -ne 3 ]
then
    echo "Error: Must provide three arguments."
    exit 1
fi

# Print the three arguments
echo "The first argument is: $1"
echo "The second argument is: $2"
echo "The third argument is: $3"
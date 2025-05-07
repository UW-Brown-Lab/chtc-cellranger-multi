#!/bin/bash

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 directory"
    exit 1
fi

# Iterate through each .fastq.gz file in the directory and its subdirectories
find "$1" -type f -name "*.fastq.gz" | while read -r file; do
    # Replace _S###_ with _S1_ in the filename
    new_file=$(echo "$file" | sed 's/_S[0-9]\{3\}_/_S1_/')
    # Rename the file
    mv "$file" "$new_file"
    echo "Renamed $file to $new_file"
done

echo "Renaming complete."

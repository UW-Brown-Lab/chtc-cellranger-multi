#!/bin/bash

# Check if the input CSV file argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_csv>"
    exit 1
fi

# Input CSV file
input_csv="$1"

# Temporary file for storing modified CSV content
temp_csv="temp.csv"

# Check if input CSV file exists
if [ ! -f "$input_csv" ]; then
    echo "Error: Input CSV file not found!"
    exit 1
fi

# Process each line of the input CSV file
awk -F',' -v OFS=',' -v pwd="$PWD" '{
    # Iterate through fields in each line
    for (i=1; i<=NF; i++) {
        # Replace occurrences of $PWD with the actual value
        gsub(/\$PWD/, pwd, $i)
    }
    # Print the modified line
    print
}' "$input_csv" > "$temp_csv"

# Replace the original CSV file with the modified one
mv "$temp_csv" "$input_csv"

echo "Replacement completed successfully."


#!/bin/bash

# Function to rename files
rename_files() {
    local dir="$1"
    for FILE in "$dir"/*; do
        if [ -d "$FILE" ]; then
            # If it's a directory, recursively call the function
            rename_files "$FILE"
        elif [ -f "$FILE" ]; then
            echo "Processing file: $FILE"
            
            # Get the creation date of the file in YYYY-MM-DD format
            CREATION_DATE=$(stat -f "%SB" -t "%Y-%m-%d" "$FILE")
            echo "Creation date: $CREATION_DATE"

            # Get the base name of the file (without the directory path)
            BASE_NAME=$(basename "$FILE")

            # Generate the new file name with date prefix
            NEW_NAME="${dir}/${CREATION_DATE}-${BASE_NAME}"
            echo "New name: $NEW_NAME"

            # Rename the file
            mv "$FILE" "$NEW_NAME"
            echo "File renamed to: $NEW_NAME"
            echo "------------------------"
        fi
    done
}

# Check if a directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory containing the files to be renamed
DIRECTORY="$1"

echo "Script started. Working in directory: $DIRECTORY"

# Call the function to rename files
rename_files "$DIRECTORY"

echo "Script completed."
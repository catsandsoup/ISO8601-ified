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

            # Ensure unique filenames
            if [ -e "$NEW_NAME" ]; then
                COUNTER=1
                while [ -e "${dir}/${CREATION_DATE}-${COUNTER}-${BASE_NAME}" ]; do
                    COUNTER=$((COUNTER + 1))
                done
                NEW_NAME="${dir}/${CREATION_DATE}-${COUNTER}-${BASE_NAME}"
            fi

            echo "New name: $NEW_NAME"

            if [ "$DRY_RUN" = false ]; then
                # Rename the file
                mv "$FILE" "$NEW_NAME"
                if [ $? -eq 0 ]; then
                    echo "File renamed to: $NEW_NAME" | tee -a "$LOG_FILE"
                else
                    echo "Failed to rename: $FILE" | tee -a "$LOG_FILE"
                fi
            else
                echo "Dry run: File would be renamed to: $NEW_NAME"
            fi
            echo "------------------------"
        fi
    done
}

# Check if a directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory> [--dry-run]"
    exit 1
fi

# Directory containing the files to be renamed
DIRECTORY="$1"
DRY_RUN=false

# Check for dry run option
if [ "$2" == "--dry-run" ]; then
    DRY_RUN=true
fi

# Log file
LOG_FILE="${DIRECTORY}/rename_log.txt"

echo "This script will rename all files in the following directory and its subdirectories:"
echo "$DIRECTORY"
echo "Files will be prefixed with their creation date in YYYY-MM-DD format."
echo

# Prompt for confirmation
read -p "Do you want to proceed? (y/n): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Script started. Working in directory: $DIRECTORY"

# Clear the log file
> "$LOG_FILE"

# Call the function to rename files
rename_files "$DIRECTORY"

echo "Script completed. Log saved to $LOG_FILE"
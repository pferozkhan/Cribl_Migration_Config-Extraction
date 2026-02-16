#!/bin/bash

# Variable declaration
#=====================#
CRIBL_HOME="/opt/cribl"
BACKUP_DIR="/home/cribl/cribl_backup"
ARCHIVE_NAME="Cribl_Config_Backup_$(date +%F).tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
TAR_OUTPUT_FILE="Tar_Output_$(date +%F_%H%M%S).log"
TAR_OUTPUT_PATH="$BACKUP_DIR/$TAR_OUTPUT_FILE"
LOG_FILE="Script_Output_$(date +%F_%H%M%S).log"
LOG_PATH="$BACKUP_DIR/$LOG_FILE"

# Check if atleast one folder name is provided as an argument
#============================================================#
if [ "$#" -lt 1 ]; then
    echo ""
    echo "No folder name given ...."
    echo "Usage: $0 <folder_name1> <folder_name2> <folder_name3> ..."
    echo "Exiting ...."
    echo ""
    exit 1
fi

# Printing all variable declarations
#===================================#
echo "" >> "$LOG_PATH"
echo "CRIBL_HOME = $CRIBL_HOME" >> "$LOG_PATH"
echo "ARCHIVE_FILE_NAME = $ARCHIVE_NAME" >> "$LOG_PATH"
echo "ARCHIVE_PATH = $ARCHIVE_PATH" >> "$LOG_PATH"
echo "LOG_PATH = $LOG_PATH" >> "$LOG_PATH"
echo "" >> "$LOG_PATH"

# Create backup directory if it does not exist
#=============================================#
if [ ! -d "$BACKUP_DIR" ]; then
    echo "" >> "$LOG_PATH"
    echo "Backup directory does not exist - creating ..." >> "$LOG_PATH"
    echo "" >> "$LOG_PATH"
    mkdir -p "$BACKUP_DIR"
    echo "" >> "$LOG_PATH"
    echo "Created backup directory: $BACKUP_DIR" >> "$LOG_PATH"
    echo "" >> "$LOG_PATH"
fi

# Build group paths array
#========================#
GROUP_PATHS=()

for GROUP in "$@"; do
    if [ -d "$CRIBL_HOME/groups/$GROUP" ]; then
        GROUP_PATHS+=("groups/$GROUP")
    else
        echo "" >> "$LOG_PATH"
        echo "Warning: $CRIBL_HOME/groups/$GROUP does not exist — skipping" >> "$LOG_PATH"
        echo "" >> "$LOG_PATH"
    fi
done

# Exit if no valid folder name is given
#======================================#
if [ "${#GROUP_PATHS[@]}" -eq 0 ]; then
    echo "" >> "$LOG_PATH"
    echo "No valid group folders found. Exiting." >> "$LOG_PATH"
    echo "" >> "$LOG_PATH"
    exit 1
fi

# Construct the folder structure that needs to be Archived
#=========================================================#
echo "Creating archive: $ARCHIVE_PATH" >> "$LOG_PATH"
echo "" >> "$LOG_PATH"
echo "Folders Included:" >> "$LOG_PATH"
echo "  - $CRIBL_HOME/local" >> "$LOG_PATH"
for GP in "${GROUP_PATHS[@]}"; do
    echo "  - $CRIBL_HOME/$GP" >> "$LOG_PATH"
done
echo "" >> "$LOG_PATH"

tar -czvf "$ARCHIVE_PATH" -C "$CRIBL_HOME" local "${GROUP_PATHS[@]}" 2>&1 | tee "$TAR_OUTPUT_PATH"

# Validate if the Archive file got created successfully
#======================================================#
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Archive creation failed!"
    exit 1
else
    echo "" >> "$LOG_PATH"
    echo "Archive created successfully: $ARCHIVE_PATH" >> "$LOG_PATH"
    echo "Output Log File created: $LOG_PATH" >> "$LOG_PATH"
    exit 1
fi

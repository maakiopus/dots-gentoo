#!/bin/bash

REMOTE_USER="maaki"
REMOTE_HOST="armboi"
WEB_ROOT="/usr/share/nginx/html/media"
BASE_URL="https://maaki.0x.no/media"
IDENTITY_FILE=""
UPLOADED_URLS=()

usage() {
    echo "Usage: $0 [-i identity_file] [-d file_to_delete | file1 [file2 ...]]"
    echo "  -i identity_file  Path to SSH identity file (optional)"
    echo "  -d file_to_delete File to delete from the remote server"
    echo "  -l 				  List Files"
    exit 1
}

list() {
	ssh $SSH_OPTIONS $REMOTE_USER@$REMOTE_HOST -- ls $WEB_ROOT
	exit 0
}

sanitize_filename() {
    echo "$1" | tr ' ' '_'
}

delete_file() {
    local FILE_TO_DELETE
    FILE_TO_DELETE=$(sanitize_filename "$1")
    SSH_OPTIONS=""
    if [ -n "$IDENTITY_FILE" ]; then
        SSH_OPTIONS="-i $IDENTITY_FILE"
    fi

    echo "Deleting '$FILE_TO_DELETE' from '$REMOTE_USER@$REMOTE_HOST:$WEB_ROOT'..."
    ssh $SSH_OPTIONS "$REMOTE_USER@$REMOTE_HOST" "rm -f $WEB_ROOT/$FILE_TO_DELETE"

    if [ $? -eq 0 ]; then
        echo "File '$FILE_TO_DELETE' deleted successfully."
    else
        echo "Error: Failed to delete '$FILE_TO_DELETE'."
    fi
}

while getopts "i:d:l" opt; do
    case $opt in
        i) IDENTITY_FILE="$OPTARG" ;;
        d) DELETE_FILE="$OPTARG" ;;
        l) list ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))

if [ -n "$DELETE_FILE" ]; then
    delete_file "$DELETE_FILE"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    usage
fi

SSH_OPTIONS=""
if [ -n "$IDENTITY_FILE" ]; then
    SSH_OPTIONS="-i $IDENTITY_FILE"
fi

for FILE in "$@"; do
    if [ ! -f "$FILE" ]; then
        echo "Error: File '$FILE' does not exist."
        continue
    fi

    FILE_NAME=$(basename "$FILE")
    SANITIZED_FILE_NAME=$(sanitize_filename "$FILE_NAME")

    if [ "$FILE_NAME" != "$SANITIZED_FILE_NAME" ]; then
        echo "Renaming '$FILE_NAME' to '$SANITIZED_FILE_NAME'..."
        mv "$FILE" "$(dirname "$FILE")/$SANITIZED_FILE_NAME"
        FILE="$(dirname "$FILE")/$SANITIZED_FILE_NAME"
    fi

    echo "Syncing '$FILE' to '$REMOTE_USER@$REMOTE_HOST:$WEB_ROOT/$SANITIZED_FILE_NAME'..."
    rsync -avz -e "ssh $SSH_OPTIONS" "$FILE" "$REMOTE_USER@$REMOTE_HOST:$WEB_ROOT/"

    if [ $? -eq 0 ]; then
        URL="$BASE_URL/$SANITIZED_FILE_NAME"
        UPLOADED_URLS+=("$URL")
    else
        echo "Error: Failed to sync '$FILE'."
    fi
done

if [ ${#UPLOADED_URLS[@]} -gt 0 ]; then
    echo "Uploaded files:"
    for URL in "${UPLOADED_URLS[@]}"; do
        echo "$URL"
    done
fi

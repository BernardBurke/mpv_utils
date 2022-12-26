#!/bin/bash
# filenames should just contain alphanumerics!
# source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

if [[ ! -d "$1" ]]; then
    message "$1 is not a directory"    
    exit 1
else
    WORK_DIR="$1"
fi

CURRENT_DIR="$PWD"

cd "$WORK_DIR"


for file in *

    do 

    BARE_NAME="$file"
    BASE_NAME=$(basename -- "$file")
    FILE_EXTENSION="${BASE_NAME##*.}"
    FILE_NAME="${BASE_NAME%.*}"
    #ALPH_NAME="${FILE_NAME//[^[:alnum:]_-]/}" 
    OUTFILENAME=$(echo $FILE_NAME | sed "s/\[.*$//g" | sed -r "s/\(.*$//g" | sed "s/\./ /g" | sed "s/  / /g")
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^a-zA-Z0-9_-]//')
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^[:alnum:]\ ]//g' | tr -s " ")
    TARGET_NAME="$OUTFILENAME.$FILE_EXTENSION"
    if [[ "$BASE_NAME" != "$TARGET_NAME" ]]; then
        echo "mv -v \"$BASE_NAME\" \"$TARGET_NAME\""
    fi
done

cd "$CURRENT_DIR"
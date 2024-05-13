#!/usr/bin/env bash

# this function takes a filename as $1 that contains a ⧸ and returns all characters after the last ⧸
# if there is no ⧸ in the filename, the filename is returned

function split_name(){
    # check if $1 contains a ⧸
    if [[ "$1" == *⧸* ]]; then
        # get the last part of the filename
        RESULT="${1##*⧸}"
        # trim lead spaces
        RESULT="${RESULT#"${RESULT%%[![:space:]]*}"}"
        # replace ( and ) with spaces
        RESULT="${RESULT//\(/ }"
        RESULT="${RESULT//\)/ }"
        # return the result
        echo $RESULT
    else
        # return the filename
        echo "$1"
    fi
}

for file in "$1"/*.mp4; do
    # get the filename without the path
    filename=$(split_name "$file")
    # rename $file to $filename, prompting the user before the mv
    # just echo the mv command for now
    echo "mv -i \""$file"\" "$1/$filename""
    read -p "Press enter to continue"
    mv -i "$file" "$1/$filename"
done




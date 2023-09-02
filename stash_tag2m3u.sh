#/!/bin/bash
# 
TMPFILE1=$(mktemp)
TEMPLATE=$MPVU/stash_tag_template.sql 



if [[ $1 == "" ]]; then
    MODE="TAG"
else
    MODE="$1"
fi

# if [[ $2 == "" ]];  then
#     REPLACE_STRING="Solid Gold"
# else
#     REPLACE_STRING="$2"
# fi

if [[ $2 == "" ]]; then
    echo "you must supply a string to replace for $MODE"
    exit 1
else
    REPLACE_STRING="$2"
fi


case $MODE in
    TAG)
    TEMPLATE=$MPVU/stash_tag_template.sql
    cp -v $TEMPLATE $TMPFILE1
    sed -i -e  "s/Solid Gold/$REPLACE_STRING/g" "$TMPFILE1"
    ;;
    NAME)
    TEMPLATE=$MPVU/stash_performer_name_template.sql
    cp -v $TEMPLATE $TMPFILE1
    sed -i -e  "s/Alex Coal/$REPLACE_STRING/g" "$TMPFILE1"
    ;;
    AGE)
        TEMPLATE=$MPVU/stash_performer_age_template.sql
    cp -v $TEMPLATE $TMPFILE1
    sed -i -e  "s/1993/$REPLACE_STRING/g" "$TMPFILE1"
    ;;
    STUDIO)
        TEMPLATE=$MPVU/stash_studio_template.sql
    cp -v $TEMPLATE $TMPFILE1
    sed -i -e  "s/Mommy/$REPLACE_STRING/g" "$TMPFILE1"
    ;;

    *)
    echo "Invalid MODE"
    exit
    ;;
esac


if [[ $3 == "" ]]; then
    SCREEN=1
else
    SCREEN="$3"
fi

if [[ $4 == "" ]]; then
    VOLUME=20
else
    VOLUME="$4"
fi



cat $TMPFILE1

export M3U_TAGGED=$USCR/stashgen$$.m3u

sqlite3 < $TMPFILE1 > $M3U_TAGGED
# sqlite3 < $TMPFILE1
# exit 0



nohup mpv --screen=$SCREEN --volume=$VOLUME --playlist=$M3U_TAGGED --shuffle  --fs-screen=$SCREEN --fullscreen &

cat $M3U_TAGGED

echo $M3U_TAGGED

clean_filename() {

    FILE_NAME="$1"
    #ALPH_NAME="${FILE_NAME//[^[:alnum:]_-]/}" 
    OUTFILENAME=$(echo $FILE_NAME | sed "s/\[.*$//g" | sed -r "s/\(.*$//g" | sed "s/\./ /g" | sed "s/  / /g")
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^a-zA-Z0-9_-]//')
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^[:alnum:]\ ]//g' | tr -s " ")
    echo $OUTFILENAME
}

H_FILENAME="$(clean_filename "$REPLACE_STRING")"

cp -v $M3U_TAGGED "$HANDUNI/$H_FILENAME.m3u"
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

export M3U_TAGGED=$HANDUNI/stashgen$$.m3u

sqlite3 < $TMPFILE1 > $M3U_TAGGED

nohup mpv --screen=$SCREEN --volume=$VOLUME --playlist=$M3U_TAGGED --shuffle  --fs-screen=$SCREEN --fullscreen &

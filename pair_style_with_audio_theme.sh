#!/bin/bash
# read a playlist of paired audio & subtitles
if [[ ! -f "$HANDUNI/$1_srt.m3u" ]]; then
    echo "No existing audio playlist specified in P1 $1"
    exit 1
fi

INFILE="$HANDUNI/$1_srt.m3u"


if [[ "$2" == "" ]]; then
    SEARCH_MASK="mom"
else
    SEARCH_MASK="$2"
fi

echo "Processing $INFILE with $SEARCH_MASK"



SELECTED_SRT=""
SELECTING_SRT=""

while [[ $SELECTING_SRT == "" ]]; do
    SELECTED_SRT="$(shuf -n 1 "$INFILE")"
    SELECTED_SRT="$(basename "$SELECTED_SRT" .srt)"
    read -p "$SELECTED_SRT (y/n)" -n 1 SELECTING_SRT
    if [[ $SELECTING_SRT == "y" ]]; then
        break
    fi
done

echo ""

SELECTING_VIDEO=""
SELECTED_VIDEO=""

while [[ $SELECTING_VIDEO == "" ]]; do
    for SELECTED_VIDEO in $HANDUNI/*$SEARCH_MASK*
        do
            read -p "$SELECTED_VIDEO (y/n)" -n 1 SELECTING_VIDEO
            if [[ $SELECTING_VIDEO == "y" ]]; then
                SELECTED_VIDEO="$(basename "$SELECTED_VIDEO" .edl)"
                break
            fi
        done
done

echo ""

VOLUME=10
SCREEN=0

SELECTING_SCREEN=""
SELECTING_VOLUME=""

while [[ $SELECTING_VOLUME == "" ]]; do
    read -p "Volume $SELECTING_VOLUME [$VOLUME]" -n 1 ANS 
        if [[ "$ANS" == "" ]]; then 
            break
        else 
            ANS="${ANS}0"
            VOLUME=$ANS
            SELECTING_VOLUME="y"
        fi
done

echo ""

while [[ $SELECTING_SCREEN == "" ]]; do
    read -p "Screen [$SCREEN]" -n 1 ANS
    if [[ "$ANS" == "" ]]; then
        break
    else
        SCREEN=$ANS
        SELECTING_SCREEN="y"
    fi
done

TMP=$(mktemp)

CMD="$MPVU/gDisplay.sh 1 $VOLUME $SCREEN rxe 100 \"$SELECTED_VIDEO\" \"$SELECTED_SRT\""
echo "$CMD" > $TMP
read -p "$CMD" -n 1 ANS
bash $TMP
#$MPVU/gDisplay.sh 1 $VOLUME $SCREEN rxe 100 '$SELECTED_VIDEO'  '$SELECTED_SRT'
#$CMD



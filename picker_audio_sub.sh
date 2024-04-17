#!/usr/bin/env bash

#source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"


# First, check that the search strings are passed as parameters $1 and $2
    if [[ "$1" == "" || "$2" == "" ]]; then
        echo "Usage: $0 search_string1 search_string2"
        exit 1
    fi  

    if [[ "$3" != "" ]]; then
        SCREEN=$3
    else
        SCREEN=2
    fi

    if [[ "$4" != "" ]]; then
        VOLUME=$4
    else
        VOLUME=10
    fi


    select_srt_file() {
        TMPFILE1=$(mktemp)
        search_string=$1
        oldIFS=$IFS # Save the current value of IFS
        choice="$(find $AUDEY $AUDEY2 -iname '*.srt' -exec grep -il "$1" "{}" \; | zenity --list --column="Files" --title="Select an SRT file" --text="Choose one of the following files" --width=800 --height=600 )"
        if [[ -z "$choice" ]]; then
            echo "No files found in $AUDEY or $AUDEY2 matching $search_string"
            exit 1
        fi
        
        PS3="Choose one of the following files: "
        if [[ "$choice" == "Cancel" ]]; then
            return
        fi
        if [[ -z "$choice" ]]; then
            echo "Invalid selection"
            exit 1
        fi
        IFS=$oldIFS # Restore the original value of IFS
        echo "$choice"
    }


    SRT_FILE="$(select_srt_file "$1")"

select_edl_file() {
        search_string=$1
        oldIFS=$IFS # Save the current value of IFS
        choice="$(find $USCR $HI -iname "*$1*.edl" | zenity --list --column="Files" --title="Select an SRT file" --text="Choose one of the following files" --width=800 --height=600 )"
        if [[ -z "$choice" ]]; then
            echo "No files found in $USCR or $HI matching $search_string"
            exit 1
        fi
        PS3="Choose one of the following files: "
        if [[ "$choice" == "Cancel" ]]; then
            return
        fi
        if [[ -z "$choice" ]]; then
            echo "Invalid selection"
            exit 1
        fi
        IFS=$oldIFS # Restore the original value of IFS
        echo "$choice"
    }


    EDL_FILE="$(select_edl_file "$2")"

    # get the audio file name from the srt file name
    audio_file=$(echo $SRT_FILE | sed 's/\.srt$/.mp3/')
    if [[ ! -f "$audio_file" ]]; then
        audio_file=$(echo $SRT_FILE | sed 's/\.srt$/.m4a/')
    fi
    # also check for wav files
    if [[ ! -f "$audio_file" ]]; then
        audio_file=$(echo $SRT_FILE | sed 's/\.srt$/.wav/')
    fi

    # check that the audio file exists
    if [[ ! -f "$audio_file" ]]; then
        echo "$audio_file does not exist"
        exit 1
    fi

mpv --sub-file="$SRT_FILE" --fullscreen --fs-screen=$SCREEN \
    --audio-file="$audio_file" --screen=$SCREEN --volume=$VOLUME "$EDL_FILE"
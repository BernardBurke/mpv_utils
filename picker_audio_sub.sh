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
        # find $AUDEY $AUDEY2 -iname '*.srt' -exec grep -iH "$1" "{}" \; > "$TMPFILE1"
        # more $TMPFILE1
        # Very weird... if I use the interactive find first, the choice= does  not work!
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

    TMPFILE2=$(mktemp)
    find $AUDEY $AUDEY2 -iname "*.srt" -exec grep -iH  -B 2 -A 2 "$1" "{}" \; > $TMPFILE2
    more $TMPFILE2

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
    # shrink the edl file to 500 records
    TMPFILE2=$(mktemp)
    cp -v "$EDL_FILE" > "$TMPFILE2"
    echo $EDL_HEADER_RECORD > $TMPFILE2
    shuf -n 200 "$EDL_FILE" >> "$TMPFILE2"
    EDL_FILE=$HI/$(basename "$EDL_FILE" .edl)_shuffled.edl
    cp $TMPFILE2 $EDL_FILE -v
    $MPVU/validate.sh $EDL_FILE

    #read -p "press enter to continue"



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
runfile="/tmp/mpv_commands_$$.sh"
echo "runfile: $runfile"

# first_half="nohup mpv --sub-file=\"$SRT_FILE\" --fullscreen --fs-screen=$SCREEN --audio-file=\"$audio_file\" --screen=$SCREEN --volume=$VOLUME" "
# echo $first_half \"$EDL_FILE\"  > $runfile

# cat $runfile

echo mpv --sub-file="\"$SRT_FILE"\" --fullscreen --fs-screen=$SCREEN --audio-file="\"$audio_file"\" --screen=$SCREEN --volume=$VOLUME ""$TMPFILE2""    > $runfile

cat $runfile
nohup bash $runfile & 

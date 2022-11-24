#!/bin/bash
# read an edl file and create an mpv command that plays as a list
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

PLAYER_FILE=$(mktemp)

# convert_edl_file(){
#     if [[ ! -f "$1" ]]; then
#     message "$1 does not exist"
#     exit 1
# else
#     message "Processing  $1"
#     EDL_FILE=$(mktemp)
#     cat "$1" | grep -v "#" > $EDL_FILE
# fi 

# echo "mpv --screen=0 \\" > $PLAYER_FILE
# # toDo - validate
# # validate edl "$EDL_FILE"

# while IFS=, read -r file start length; do
#     echo "--\{ \"$file\" --start=$start --length=$length --\} \\" >> $PLAYER_FILE
# done < "$EDL_FILE"

# }


# convert_seconds(){
#     message "Converting seconds"
# }
FILE="$(find $HANDUNI/ -iname '*.edl' | shuf -n 1)"
convert_edl_file "$FILE"
message "Player File is $PLAYER_FILE"
bash -x $PLAYER_FILE &

# working sample
# mpv --\{ "/mnt/d/grls/phprem/2 wow girls shaving.mp4" --start=412 --length=49 --\}
# mpv --fullscreen --screen=0 --fs-screen=0 --volume=10  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3419.08 --length=2.27 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3423.675 --length=5.29 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3431.53 --length=2.43 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3436.18 --length=1.59 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3438.532 --length=0.73 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3439.74 --length=4.55 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3445.83 --length=2.75 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3449.745 --length=2.66 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3453.826 --length=2.09 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3456.311 --length=1 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3458.43 --length=4.55 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3466.435 --length=1.43 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3469.23 --length=0.95 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3474.409 --length=1.25 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3477.63 --length=2.81 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3480.53 --length=3.93 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3485.73 --length=0.8 --^}  ^
# --^{ d:\grls\pure\MakeEveryMomentCount_s01_RyanMclane_LuluChu_720p.mp4 --start=3488.33 --length=0.88 --^}  ^
# rem

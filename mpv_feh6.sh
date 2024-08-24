#!/usr/bin/env bash
# use feh for images
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

if [[ "$1" == "" ]]; then
	SCREEN=1
else
	SCREEN=$1
fi

if [[ "$2" == "" ]]; then
	VOLUME=10
else
	VOLUME="$2"
fi

message "VOLUME is $VOLUME"

if [[ "$3" == "" ]]; then
	EDLNAME="last_week_chopped"
else
	if [[ ! -f "$HANDUNI/$3_chopped1.edl" ]]; then
		echo "no edl file found in p1 $3"
		exit 1
	fi
	EDLNAME="$3"
fi

message "EDLNAME is $EDLNAME"

		
if [[ "$4" == "" ]]; then
	IMGDIR=""
else
	if [[ ! -d "$IMGSRC/$4" ]]; then 
		echo "No valid image dir $IMGSRC/$4"
		exit 1
	else
		IMGDIR="$4"
	fi
fi


if [[ "$5" == "" ]]; then
	ONE_SCREEN=false
else
	ONE_SCREEN=$5
fi

if [[ "$6" != "" ]]; then
	message "Running in split screen mode"
	if [[ ! -f "$HANDUNI/$6_chopped6.edl" ]]; then
		message "But  $HANDUNI/$6_chopped6.edl was not found"
		exit 1
	fi
	if [[ -f $HI/mpv_split6_chopped6.edl ]]; then
		message "removing stale split6 files"
		rm -v $HI/mpv_split6_chopped?.edl
		exit 1
	fi
	split_screen=1
else
	split_screen=0
fi


message "IMGDIR is $IMGDIR"

message "Firing up on $SCREEN at volume $VOLUME with IMGDIR $IMGDIR using EDLNAME $EDLNAME - ONE_SCREEN is $ONE_SCREEN"
#read -p "Press return to execute"

save_6() {
	if [[ "$1" == "" ]]; then
		FNAME=$HANDUNI/lastweek_chopped?.edl
	else
		FNAME="$HANDUNI/$1_chopped?.edl"
	fi

	if [[ "$2" == "" ]]; then
		DEST=$HANDUNI/saved_chopped
	else
		DEST="$HANDUNI/$2"
	fi

	count=0

	for i in $FNAME 
	do 
		((count++))
		DESTNAME="$DEST$count.edl"
		cp -v "$i" "$DESTNAME" 
		$SRC/shake_an_edl.sh "$DESTNAME"
	done
}


	save_6 "$EDLNAME" mpv_feh6

if [[ $split_screen -eq 1 ]]; then
	message "Split screen mode - generating split6 files"
	save_6 "$6" mpv_split6
	message "Split screen files generated"
else
	message "Not in split screen mode"
fi



run_screen() {
		LCOUNT=$2
		LOG_FILE1="--log-file=/tmp/VIDEO1$SCREEN.log"
		LOG_FILE2="--log-file=/tmp/VIDEO2$SCREEN.log"

		if [[ $split_screen -eq 1 ]]; then
			message "Split screen mode - using split6 files"
			nohup mpv --volume=$VOLUME --screen=$1 --profile=topmid $HANDUNI/mpv_split6$LCOUNT.edl  "$LOG_FILE1" &
		else
			nohup mpv --volume=$VOLUME --screen=$1 --profile=topmid $HANDUNI/mpv_feh6$LCOUNT.edl  "$LOG_FILE1" &
		fi
		((LCOUNT++))
		nohup mpv --volume=$VOLUME --screen=$1 --profile=botmid $HANDUNI/mpv_feh6$LCOUNT.edl  "$LOG_FILE2" &
		$IMGSRC/fillet_screens.sh 6corners$1 10  "$IMGDIR"
}

LOOPCNT=$(($SCREEN + 0))

if [[ "$ONE_SCREEN" == "" ]] ; then
	message "Single screen $SCREEN"
	run_screen $SCREEN 1 "$IMGDIR"
elif [[ "$ONE_SCREEN" == "2" ]] ; then
	message "dual screens"
	run_screen 0 1 $IMGDIR
	run_screen 2 3 $IMGDIR
else
	message "Loop through screens $SCREEN"
	k=0
	for ((j=0;j<=$LOOPCNT;j++)); do
		((k++))
		run_screen $j $k "$IMGDIR"
		#nohup mpv --volume=$VOLUME --screen=$j --profile=topmid $HANDUNI/mpv_feh6$k.edl &
		((k++))
		#nohup mpv --volume=$VOLUME --screen=$j --profile=botmid $HANDUNI/mpv_feh6$k.edl &
		#$IMGSRC/fill_screens.sh 6corners$j 10  "$IMGDIR"
	done

fi



#read -p "Press return to exit"
read  -p "Press return or q " -n 1 ANS
if [[ "$ANS" == "q" ]]; then
	pkill feh &
	echo "killing mpv..."
	pkill -f topmid
	pkill -f botmid
fi

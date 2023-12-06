for i in $GRLSRC/**/*.srt
do 
	INPUT_FILE="$i"
	DIREWOLF=$(dirname "$i")
	OUTPUT_FILE="$(basename "$i" .srt)"
	OUTPUT_FILE="$DIREWOLF/$OUTPUT_FILE.vtt"
	if grep -q audio <<<"$i"; then
		echo "Audio - ignoring $i"
	else
		if [[ -f "$OUTPUT_FILE" ]]; then
			echo "$OUTPUT_FILE already exists"
		else
			echo "tt conv -i '$i' -o '$OUTPUT_FILE'"
	        	tt convert -i "$i" -o "$OUTPUT_FILE"
        		#read -p "Press return to continue:"	
		fi
	fi

done

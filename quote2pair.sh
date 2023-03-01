$BATCHSRC/get_me_a_quote.sh "$1" > $HANDUNI/quote_srt.m3u
cat $HANDUNI/quote_srt.m3u
read -p "Press return to Pair Up"
$MPVU/pair_style_with_audio_theme.sh quote "$2"

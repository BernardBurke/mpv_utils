#!/usr/bin/env bash
# read 2 edl files and create a shuffled output file
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)
TMPFILE4=$(mktemp)

if [[ ! -f "$1" ]]; then
    echo "please enter file1"
    exit 1
fi

if [[ ! -f "$2" ]]; then
    echo "please enter file2"
    exit 1
fi
LENGTH1=$(wc -l < "$1")
LENGTH2=$(wc -l < "$2")

CORRECT_ORDER="$(( LENGTH1 > LENGTH2 ))"

#echo     "$1 has $LENGTH1 records and $2 has $LENGTH2 records"

if (( CORRECT_ORDER )); then
    head -n $LENGTH2 "$1" > $TMPFILE1
    cat "$2" > $TMPFILE2
else
    head -n $LENGTH1 "$2" > $TMPFILE1
    cat "$1" > $TMPFILE2
fi

paste -d '\n' "$TMPFILE1" "$TMPFILE2" > $TMPFILE3

echo "# mpv EDL v0" > $TMPFILE4

cat $TMPFILE3 | grep -v "#" >> $TMPFILE4

SHUFFLED_OUTPUT="$USCR/shuffled_$(basename "$1" .edl)_$(basename "$2" .edl)_$$.edl"

echo "# mpv EDL v0" > "$SHUFFLED_OUTPUT"

cat $TMPFILE4 | grep -v "#" >> "$SHUFFLED_OUTPUT"
echo $SHUFFLED_OUTPUT



# while read -r line1
# do 
#     echo $line1
#     while read -r line2
#     do
#         echo $line2
#     done <"$2"

# done < "$1"

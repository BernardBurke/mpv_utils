#/bin/bash
# take all the edls in /tmp and trim them to 1000 records - way too many big edls
MAXRECORDS=1000
export SHAKE_DEFAULT=$MAXRECORDS
if [[ ! -d "$1" ]]; then
	echo "please provide an existing directory in p1"
	exit 1
fi

for f in $1/*.edl ; do
	RECORDS="$(wc -l < "$f")"
#	echo "$RECORDS"
	if [[ $RECORDS -gt $MAXRECORDS ]]
		then
			echo "$f is too big"
			$SRC/shake_an_edl.sh "$f"
	fi
done

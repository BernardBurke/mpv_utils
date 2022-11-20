export TMP_EDL_DIR=$(mktemp -d)
#for i in $USCR/*.edl; do /home/ben/mpv_utils/validate.sh "$i"; done
# read -p "Press Return to continue with $HANDUNI"
# export TMP_EDL_DIR=$(mktemp -d)
# for i in $HANDUNI/*.edl; do /home/ben/mpv_utils/validate.sh "$i"; done
# read -p "Press Return to continue with $KEYCUTUNI"
# export TMP_EDL_DIR=$(mktemp -d)
# for i in $KEYCUTUNI/*.edl; do /home/ben/mpv_utils/validate.sh "$i"; done
read -p "Press Return to continue with $RIFU"
export TMP_EDL_DIR=$(mktemp -d)
for i in $RIFU/*.edl; do /home/ben/mpv_utils/validate.sh "$i"; done
read -p "Press Return to continue with $UNIMOVIE"
export TMP_EDL_DIR=$(mktemp -d)
for i in $UNIMOVIE/*.edl; do /home/ben/mpv_utils/validate.sh "$i"; done


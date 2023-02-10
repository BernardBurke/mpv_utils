#!/bin/bash
# wrapper for validating all EDLs
source $MPVU/util_inc.sh

#ls /tmp/*.edl
#read -p "the above EDL files where found in /tmp/*.edl"
#echo "Validating $USCR"
#export TMP_EDL_DIR=$(mktemp -d)
export TMP_EDL_DIR=/tmp
#for i in $USCR/*.edl; do validate_edl "$i"; done
#echo "These edl files were found after $USCR in $TMP_EDL_DIR"
ls -al $TMP_EDL_DIR/*.edl
read -p "Press Return to continue with $HANDUNI"
#xport TMP_EDL_DIR=$(mktemp -d)
for i in $HANDUNI/*.edl; do validate_edl "$i"; done
ls -al $TMP_EDL_DIR/*.edl
read -p "Press Return to continue with $KEYCUTUNI"
# export TMP_EDL_DIR=$(mktemp -d)
# for i in $KEYCUTUNI/*.edl; do validate_edl "$i"; done
# ls -al $TMP_EDL_DIR/*.edl
# read -p "Press Return to continue with $RIFU"
# export TMP_EDL_DIR=$(mktemp -d)
# for i in $RIFU/*.edl; do validate_edl "$i"; done
# ls -al $TMP_EDL_DIR/*.edl
# read -p "Press Return to continue with $UNIMOVIE"
# export TMP_EDL_DIR=$(mktemp -d)
# for i in $UNIMOVIE/*.edl; do validate_edl "$i"; done


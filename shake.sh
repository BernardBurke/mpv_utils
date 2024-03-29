# re shuffle and existing edl and replace it
# updated to preserve source file as -shake-preserve$$
source $MPVU/util_inc.sh
# #!/usr/bin/env bash
# # written to validate EDL files, but no doubt will have other functions.
source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

if [[ ! -f "$1" ]]; then
    message "$1 does not exist"
    exit 1
fi

export SHUFFLE_RESTORE=Y 


if validate_edl  "$1" ; then
    echo "Validation succeeded"
    shuffle_edl "$1" "$2"
fi 


export SHUFFLE_RESTORE=

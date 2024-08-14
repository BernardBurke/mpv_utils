# #!/usr/bin/env bash
# # written to validate EDL files, but no doubt will have other functions.
# getting rid of source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

if [[ ! -f "$1" ]]; then
    message "$1 does not exist"
    exit 1
fi

validate_edl  "$1"
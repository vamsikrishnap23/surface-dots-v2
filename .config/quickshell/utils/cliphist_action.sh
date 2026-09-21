#!/usr/bin/env bash
ACTION=$1
ARG=$2

if [ "$ACTION" = "copy" ]; then
    # ARG is the ID
    cliphist decode "$ARG" | wl-copy
elif [ "$ACTION" = "delete" ]; then
    # ARG is the full raw line
    printf "%s\n" "$ARG" | cliphist delete
fi

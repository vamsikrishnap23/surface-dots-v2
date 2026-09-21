#!/usr/bin/env sh

case $1 in
  i) pamixer -i 5 ;;
  d) pamixer -d 5 ;;
  m) pamixer -t ;;
  mi) pamixer --default-source -t ;;
  *) echo "Usage: $0 {i|d|m|mi}" ; exit 1 ;;
esac

if [ "$1" = "mi" ]; then
  vol=$(pamixer --default-source --get-volume)
  is_muted=$(pamixer --default-source --get-mute)
  echo "${vol}:${is_muted}" > "$HOME/.cache/quickshell/mic"
else
  vol=$(pamixer --get-volume)
  is_muted=$(pamixer --get-mute)
  echo "${vol}:${is_muted}" > "$HOME/.cache/quickshell/volume"
  
  if [ "$is_muted" = "true" ]; then
    printf '%s\n%s\n%s' "$status" "$title" "$artist" > "$HOME/.cache/quickshell/media"
  fi
fi

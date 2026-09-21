#!/usr/bin/env sh

case $1 in
  i) 
    brightnessctl set +5% > /dev/null
    new_perc=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | head -1)
    echo "$new_perc" > "$HOME/.cache/quickshell/brightness"
    ;;
  d) 
    current_perc=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | head -1)
    if [ "$current_perc" -le 5 ]; then
        brightnessctl set 1% > /dev/null
    else
        brightnessctl set 5%- > /dev/null
    fi
    new_perc=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | head -1)
    echo "$new_perc" > "$HOME/.cache/quickshell/brightness"
    ;;
  *) 
    echo "Usage: $0 {i|d}" 
    exit 1 
    ;;
esac

#!/usr/bin/env bash

if [ -z "$XDG_PICTURES_DIR" ] ; then
    XDG_PICTURES_DIR="$HOME/Pictures"
fi

save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
final_screenshot="$save_dir/$save_file"

mkdir -p "$save_dir"

swpy_dir="${XDG_CONFIG_HOME:-$HOME/.config}/swappy"
mkdir -p "$swpy_dir"
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" > "$swpy_dir/config"

function print_error
{
cat << "EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p : print all screens
        s : snip current screen
        sf : snip current screen (frozen)
        m : print focused monitor
EOF
}

case $1 in
p)  # print all outputs
    grimblast copysave screen "$final_screenshot" ;;
s)  # drag to manually snip an area / click on a window to print it
    grimblast copysave area "$final_screenshot" ;;
sf)  # frozen screen, drag to manually snip an area / click on a window to print it
    grimblast --freeze copysave area "$final_screenshot" ;;
m)  # print focused monitor
    grimblast copysave output "$final_screenshot" ;;
*)  # invalid option
    print_error
    exit 1 ;;
esac

if [ -f "$final_screenshot" ] ; then
    ACTION=$(notify-send -a "Screenshot" -i "$final_screenshot" -t 5000 \
        -A "edit=Edit with Swappy" \
        "Screenshot saved" "saved at $final_screenshot")
        
    if [ "$ACTION" = "edit" ]; then
        swappy -f "$final_screenshot"
    fi
fi

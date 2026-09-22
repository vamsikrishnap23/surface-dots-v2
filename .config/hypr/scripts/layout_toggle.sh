#!/usr/bin/env bash

# Toggle the layout on the current active workspace between dwindle and scrolling

ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
[[ $ACTIVE_WORKSPACE =~ ^-?[0-9]+$ ]] || exit 1
CURRENT_LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

case "$CURRENT_LAYOUT" in
  dwindle) NEW_LAYOUT=scrolling ;;
  *) NEW_LAYOUT=dwindle ;;
esac

# Note: The original omarchy script writes to an omarchy state folder.
# We apply the layout change dynamically via hyprctl.
# (If your lua wrapper supports `hl.workspace_rule` eval, it will use that, fallback to keyword otherwise)

hyprctl eval "hl.workspace_rule({ workspace = \"$ACTIVE_WORKSPACE\", layout = \"$NEW_LAYOUT\" })" >/dev/null 2>&1 || \
  hyprctl keyword workspace "$ACTIVE_WORKSPACE, layout:$NEW_LAYOUT"

notify-send -a "Layout" -t 2000 "Workspace layout set to $NEW_LAYOUT"

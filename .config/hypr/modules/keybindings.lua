local mod     = "SUPER"
local alt     = "ALT"
local home    = os.getenv("HOME") or "/home/vamsi"
local scripts = home .. "/.config/hypr/scripts"

-- Hub & Modes
hl.bind(mod .. " + SPACE", hl.dsp.global("quickshell:hubToggle"), { description = "Toggle QuickShell Hub" })
hl.bind(mod .. " + R", hl.dsp.global("quickshell:drawerToggle"), { description = "Toggle Workspace Drawer" })

-- Apps
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"), { description = "Open Kitty Terminal" })
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("nautilus"), { description = "Open Nautilus" })
hl.bind(mod .. " + SHIFT + O", hl.dsp.exec_cmd("obsidian"), { description = "Open Obsidian" })
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("code"), { description = "Open VS Code" })
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("spotify-launcher"), { description = "Open Spotify" })
-- hl.bind(mod .. " + R", hl.dsp.exec_cmd(home .. "/.config/rofi/rofi_wide.sh"), { description = "Open Rofi" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("helium-browser"), { description = "Open Helium Browser" })
-- hl.bind(mod .. " + S", hl.dsp.exec_cmd("lens --no-decorations --sniper"), { description = "Open Lens" })
hl.bind(mod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color Picker" })


-- Window Actions
hl.bind(mod .. " + X", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mod .. " + " .. alt .. " + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
    hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600 }))
    hl.dispatch(hl.dsp.window.center())
end, { description = "Force float, resize & center" })
hl.bind(mod .. " + M", function() hl.dispatch(hl.dsp.window.fullscreen()) end, { description = "Toggle fullscreen" })
-- hl.bind(mod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudo-tiling" })
hl.bind(mod .. " + DOWN", hl.dsp.layout("togglesplit"), { description = "Toggle split down" })
hl.bind(mod .. " + UP",   hl.dsp.layout("togglesplit"), { description = "Toggle split up" })
hl.bind(mod .. " + G",    hl.dsp.group.toggle(), { description = "Toggle window group" })

hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })

hl.bind(mod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind(mod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }), { description = "Move window right" })
hl.bind(mod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind(mod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })

hl.bind(mod .. " + " .. alt .. " + F4", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"), { description = "Exit Hyprland" })
hl.bind(alt .. " + F4", hl.dsp.exec_cmd("hyprctl layers | grep -q power-menu || quickshell -p ~/.config/quickshell/utils/PowerMenu.qml"), { description = "Show Power Menu" })

hl.bind(mod .. " + left",         hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mod .. " + right",        hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mod .. " + SHIFT + up",   hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mod .. " + SHIFT + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"), { description = "Toggle magic workspace" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to magic workspace" })

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll to next workspace" })
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll to previous workspace" })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "/brightnesscontrol.sh d"), { description = "Brightness down" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "/brightnesscontrol.sh i"), { description = "Brightness up" })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "/audiocontrol.sh i"), { description = "Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "/audiocontrol.sh d"), { description = "Volume down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "/audiocontrol.sh m"), { description = "Toggle audio mute" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(scripts .. "/audiocontrol.sh mi"), { description = "Toggle mic mute" })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd(scripts .. "/mediacontrol.sh"), { description = "Play/Pause media" })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd(scripts .. "/mediacontrol.sh n"), { description = "Next track" })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd(scripts .. "/mediacontrol.sh p"), { description = "Previous track" })
hl.bind("XF86Launch3",           hl.dsp.exec_cmd("rog-control-center"), { description = "Launch ROG Control Center" })

hl.bind("Print",                    hl.dsp.exec_cmd(scripts .. "/screenshot.sh s"), { description = "Snip area" })
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd(scripts .. "/screenshot.sh p"), { description = "Screenshot all screens" })
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd(scripts .. "/screenshot.sh sf"), { description = "Snip frozen area" })
hl.bind(mod .. " + O",             hl.dsp.exec_cmd(scripts .. "/screenshot.sh m"), { description = "Screenshot focused monitor" })
hl.bind(mod .. " + V", hl.dsp.global("quickshell:clipboardToggle"), { description = "Toggle Clipboard Menu" })

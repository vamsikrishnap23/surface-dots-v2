local home = os.getenv("HOME") or "/home/vamsi"
local shader = require("shader")
local scripts = home .. "/.config/hypr/scripts"

local function set_wallpapers()
    hl.exec_cmd(scripts .. "/wallpaper.sh")
end

hl.on("hyprland.start", function()
    shader.toggle("Main")
    hl.exec_cmd("qs")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("blueman-applet")
    -- hyprpolkitagent if you have it, polkit-gnome otherwise
    hl.exec_cmd("systemctl --user start hyprpolkitagent 2>/dev/null || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- needs the oauth done first, skip it if there's no config
    hl.exec_cmd("[ -f $HOME/.config/vdirsyncer/config ] && vdirsyncer sync || true")
    hl.exec_cmd("sleep 1 && mpv --no-video --volume=100 " .. home .. "/.config/hypr/sounds/startup.wav")
    hl.timer(set_wallpapers, { timeout = 1500, type = "oneshot" }) -- after awww-daemon is up
end)

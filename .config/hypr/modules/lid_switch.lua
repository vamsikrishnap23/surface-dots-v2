local function set_wallpapers_delayed()
    hl.timer(function() hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper.sh") end, { timeout = 500, type = "oneshot" })
end

hl.bind("switch:off:Lid Switch", function()
    hl.exec_cmd("hyprctl keyword monitor eDP-1,preferred,auto,1")
    set_wallpapers_delayed()
end, { locked = true })

hl.bind("switch:on:Lid Switch", function()
    hl.exec_cmd("hyprctl keyword monitor eDP-1,disable")
end, { locked = true })

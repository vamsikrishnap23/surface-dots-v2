-- =========================================================================
-- @snes19xx Hyprland CONFIG
-- =========================================================================

local mod     = "SUPER"
local alt     = "ALT"
local home    = os.getenv("HOME") or "/home/vamsi"
local scripts = home .. "/.config/hypr/scripts"

-- Import Shader Manager and Inject Core
local shader = require("shader")

-- =========================================================================
-- Monitors
-- =========================================================================
-- The installer rewrites the blocks below from what you enter on its monitor
-- screen. Editing them by hand afterwards is fine, keep them at the top level.
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
    bitdepth = 10
})


local function set_wallpapers()
    hl.exec_cmd(scripts .. "/wallpaper.sh")
end

-- Plugging a monitor in gives it no wallpaper until awww is told about it, so
-- redraw shortly after the layout settles.
local function set_wallpapers_delayed()
    hl.timer(set_wallpapers, { timeout = 500, type = "oneshot" })
end

hl.on("monitor.added",   set_wallpapers_delayed)
hl.on("monitor.removed", set_wallpapers_delayed)

-- =========================================================================
-- Environment Variables
-- =========================================================================
require("modules.env")

-- =========================================================================
-- Autostart
-- =========================================================================
require("modules.autostart")

-- =========================================================================
-- Workspace Rules
-- =========================================================================
require("modules.workspace_rules")

-- =========================================================================
-- Core Config
-- =========================================================================
require("modules.core_config")

-- =========================================================================
-- Animations
-- =========================================================================
require("modules.animations")




-- =========================================================================
-- Gestures
-- =========================================================================
require("modules.gestures")

-- =========================================================================
-- Keybindings
-- =========================================================================
require("modules.keybindings")

-- =========================================================================
-- Workspace Binds
-- =========================================================================
require("modules.workspace_binds")

-- =========================================================================
-- Mouse Binds
-- =========================================================================
require("modules.mouse_binds")

-- =========================================================================
-- Lid Switch
-- =========================================================================
require("modules.lid_switch")

-- =========================================================================
-- Window Rules
-- =========================================================================
require("modules.window_rules")
local home = os.getenv("HOME") or "/home/vamsi"

local function theme_mode()
    local f = io.open(home .. "/.cache/quickshell/theme_mode", "r")
    if not f then return "dark" end
    local m = f:read("l") or ""
    f:close()
    return m:gsub("%s+", "") == "light" and "light" or "dark"
end

local function cursor_installed(name)
    for _, dir in ipairs({ home .. "/.local/share/icons/", "/usr/share/icons/" }) do
        local f = io.open(dir .. name .. "/index.theme", "r")
        if f then f:close() return true end
    end
    return false
end

local wanted_cursor = theme_mode() == "light" and "Saturnian-Day" or "Saturnian-Night"
local cursor_theme  = cursor_installed(wanted_cursor) and wanted_cursor or "Adwaita"

hl.env("HYPRCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_SIZE",  "32")
hl.env("XCURSOR_THEME",    cursor_theme)
hl.env("XCURSOR_SIZE",     "32")
hl.env("GDK_SCALE",       "1.5")
hl.env("GDK_BACKEND",     "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json")
hl.env("TERMINAL",        "kitty")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE",    "kvantum")
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")

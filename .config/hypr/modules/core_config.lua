hl.config({
    general = {
        gaps_in               = 1,
        gaps_out              = 3,
        border_size           = 1,
        ["col.active_border"]   = "rgba(87b158aa)",
        ["col.inactive_border"] = "rgba(595959aa)",
        resize_on_border      = false,
        allow_tearing         = false,
        layout                = "dwindle"
    },
    cursor = {
        no_hardware_cursors = false
    },
    decoration = {
        rounding         = 7,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,
        dim_inactive     = false,
        dim_strength     = 0.19,
        dim_around       = 0.6,
        shadow = {
            enabled      = true,
            range        = 3,
            render_power = 17,
            color        = "rgba(44220044)"
        },
        blur = {
            enabled           = true,
            size              = 5,
            passes            = 2,
            new_optimizations = true,
        }
    },
    animations = {
        enabled = true
    },
    dwindle = {
        preserve_split = true,
        smart_resizing = true
    },
    master = {
        new_status = "master"
    },
    group = {
        ["col.border_active"]   = "rgba(00000000)",
        ["col.border_inactive"] = "rgba(00000000)",
        groupbar = {
            enabled              = true,
            height               = 16,
            gradients            = true,
            ["col.active"]       = "rgb(87b158)",
            ["col.inactive"]     = "rgba(2D353Bff)",
            keep_upper_gap       = false,
            indicator_height     = 0,
            indicator_gap        = 0,
            gaps_in              = 0,
            gaps_out             = 9,
            gradient_rounding    = 8,
            font_family          = "Inter",
            font_size            = 11,
            font_weight_active   = "medium",
            font_weight_inactive = "medium",
            text_color           = "rgb(293136)",
            text_color_inactive  = "rgba(e5e6c5ff)",
            text_offset          = 1
        }
    },
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0.35,
        repeat_rate  = 50,
        repeat_delay = 300,
        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true
        }
    },
    xwayland = {
        force_zero_scaling = true
    },
    misc = {
        vrr                      = 1,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        animate_manual_resizes   = true,
        enable_swallow           = true,
        swallow_regex            = "^(kitty)$"
    },
layerrule = {
    "animation slide, rofi",
    "animation popin, power-menu",
    "dim_around, power-menu",
}
})

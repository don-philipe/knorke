local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local icon_vpn_noconn
local icon_vpn_conn


-- Create layout with widgets
local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}

gears.timer {
    timeout = 10,
    autostart = true,
    callback = function ()
        awful.spawn.easy_async_with_shell("ifconfig | grep \"tun.*:\"",
            function (stdout, _, _, _)
                if (stdout == "") then
                    widget.icon:set_image(icon_vpn_noconn)
                else
                    widget.icon:set_image(icon_vpn_conn)
                end
            end)
    end
}

-- Widget function that is available from the outside.
function widget.set_icons(vpn_noconn, vpn_conn)
    icon_vpn_noconn = vpn_noconn
    icon_vpn_conn = vpn_conn
end

awful.tooltip(
    {
        objects =  { widget },
        mode = "outside",
        align = "right",
        fg = "white",
        margin_leftright = 10,
        margin_topbottom = 10,
        preferred_positions = { "right", "left", "top", "bottom" },
        timer_function = function()
            local num_vpnc_proc = awful.spawn.with_shell("ps aux | grep vpnc | wc -l")
            if (tonumber(num_vpnc_proc) > 1) then
                return "VPNC"
            end
            local num_openconnect_proc = awful.spawn.with_shell("ps aux | grep openconnect | wc -l")
            if (tonumber(num_openconnect_proc) > 1) then
                return "OPENCONNECT"
            end
        end
    }
)

return widget

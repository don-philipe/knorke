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

return widget

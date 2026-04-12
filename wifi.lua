local beautiful = require("beautiful")
local gears = require("gears")
local vicious = require("vicious")
local wibox = require("wibox")

local icon_wifi
local icon_excellent
local icon_good
local icon_ok
local icon_none
local color = beautiful.bg_focus


-- Create layout with widgets
local widget = wibox.widget {
    {
        id = "sep",
        widget = wibox.widget.separator,
        shape = gears.shape["parallelogram"],
        color = color,
        forced_width = 8
    },
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   {
      id = "text",
      widget = wibox.widget.textbox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}
local container = wibox.container.margin(wibox.container.margin(widget, 3), 3)

vicious.register(widget.text, vicious.widgets.wifi,
    function (w, args)
        if args["{ssid}"] ~= "N/A" then
            if args["{linp}"] >= 66 then
                widget.icon:set_image(icon_excellent)
            elseif args["{linp}"] >= 33 then
                widget.icon:set_image(icon_good)
            elseif args["{linp}"] >= 1 then
                widget.icon:set_image(icon_ok)
            else
                widget.icon:set_image(icon_none)
            end
        else
            widget.icon:set_image(icon_wifi)
        end
        return " " .. args["{ssid}"]
    end, 2, "wlp64s0")

-- Widget function that is available from the outside.
function container.set_icons(wifi, excellent, good, ok, none)
    icon_wifi = wifi
    icon_excellent = excellent
    icon_good = good
    icon_ok = ok
    icon_none = none
end

return container

-- scan networks via `sudo iw dev wlp64s0 scan | grep SSID:`

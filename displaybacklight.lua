-- requires xorg-xbacklight installed

local awful = require("awful")
local vicious = require("vicious")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

local icon_brightness
local brightness_id


-- Create layout with widgets
local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}

local function change_brightness(amount)
    local f = io.popen("xbacklight -get")
    local bright = 0
    for line in f:lines() do
        bright = line
    end
    final_brightness = tonumber(bright) + amount
    if final_brightness < 1 then
        final_brightness = 1
    end

    awful.util.spawn("xbacklight -set " .. final_brightness)
    return final_brightness
end

-- Widget functions that are available from the outside.
function widget.set_icons(brightness)
    icon_brightness = brightness
end

function widget.notify_brightness(delta)
    local brightness = change_brightness(delta)
    notify_icon = icon_brightness
    local notify_icon_bright = naughty.notify({
            position = "top_middle",
            border_width = 0,
            icon = notify_icon,
            replaces_id = brightness_id })
    brightness_id = notify_icon_bright.id
    local notify_width = notify_icon_bright.width
    local bar = wibox.widget.progressbar()
    bar:set_value(brightness)
    bar:set_max_value(100)
    bar:set_color(beautiful.archcolor)
    bar:set_background_color(beautiful.archcolor_bg)
    wibox.widget.draw_to_svg_file(bar, "/tmp/bright-bar.svg", 128, 10)
    brightness_id_1 = naughty.notify({
            position = "top_middle",
            border_width = 0,
            icon = "/tmp/bright-bar.svg",
            width = notify_width,
            replaces_id = brightness_id_1 }).id
end

return widget

local gears = require("gears")
local vicious = require("vicious")
local wibox = require("wibox")
local naughty = require("naughty")

local icon_full
local icon_full_charg
local icon_good
local icon_good_charg
local icon_medium
local icon_medium_charg
local icon_low
local icon_low_charg
local icon_empty
local icon_empty_charg
local icon_low_notify
local low_notification = false


-- Create layout with widgets
local widget = wibox.widget {
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
vicious.register(widget.text, vicious.widgets.bat, "$2%  $3h", 61, "BAT0")

-- Widget function that is available from the outside.
function widget.set_icons(full, full_charg, good, good_charg, medium, medium_charg, low, low_charg, empty, empty_charg, low_notify)
    icon_full = full
    icon_full_charg = full_charg
    icon_good = good
    icon_good_charg = good_charg
    icon_medium = medium
    icon_medium_charg = medium_charg
    icon_low = low
    icon_low_charg = low_charg
    icon_empty = empty
    icon_empty_charg = empty_charg
    icon_low_notify = low_notify
end

gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function() 
        state = vicious.call(vicious.widgets.bat, "$1", "BAT0")
        percent_string = vicious.call(vicious.widgets.bat, "$2", "BAT0")
        percent = tonumber(percent_string)
        if state:match("-") then    -- discharging
            if percent >= 90 then
                widget.icon:set_image(icon_full)
            elseif percent >= 60 then
                widget.icon:set_image(icon_good)
            elseif percent >= 30 then
                widget.icon:set_image(icon_medium)
            elseif percent >= 10 then
                widget.icon:set_image(icon_low)
            else 
                widget.icon:set_image(icon_empty)
                if low_notification ~= true then
                    show = naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Battery low!",
                        icon = icon_low_notify,
                        destroy = function ()
                            low_notification = false
                        end,
                        text = tostring(percent) .. "%" })
                    low_notification = show ~= nil
                end
            end
        else    -- charging
            if percent >= 90 then
                widget.icon:set_image(icon_full_charg)
            elseif percent >= 60 then
                widget.icon:set_image(icon_good_charg)
            elseif percent >= 30 then
                widget.icon:set_image(icon_medium_charg)
            elseif percent >= 10 then
                widget.icon:set_image(icon_low_charg)
            else 
                widget.icon:set_image(icon_empty_charg)
            end
        end
    end
}

return widget

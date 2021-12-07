local vicious = require("vicious")
local wibox = require("wibox")

local icon_mute
local icon_low
local icon_medium
local icon_high


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
vicious.register(widget.text, vicious.widgets.volume,
    function (w, args)
        if (args[2] ~= "🔈" ) then  -- this is emoji of "off", see https://github.com/vicious-widgets/vicious/blob/master/widgets/volume_linux.lua#L37
            if args[1] >= 66 then
                widget.icon:set_image(icon_high)
            elseif args[1] >= 33 then
                widget.icon:set_image(icon_medium)
            else 
                widget.icon:set_image(icon_low)
            end
        else
            widget.icon:set_image(icon_mute)
        end
        return " " .. args[1] .. "%"
    end, 1, "Master")

-- Widget function that is available from the outside.
function widget.set_icons(mute, low, medium, high)
    icon_mute = mute
    icon_low = low
    icon_medium = medium
    icon_high = high
end

return widget

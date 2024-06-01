-- https://github.com/WillPower3309/awesome-dotfiles/blob/185684bf4946702104aadc5e64ca7a9e724d3fcc/awesome/widgets/bluetooth.lua
-- https://github.com/Mofiqul/awesome-shell/search?q=bluetooth
-- Requires bluetoothctl program being installed.

local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")

local is_on
local icon_dis
local icon_enab
local icon_conn

local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}

widget:buttons(awful.util.table.join(
    awful.button({}, 1, nil, function()
        if is_on then
            awful.util.spawn_with_shell("bluetoothctl power off")
        else
            awful.util.spawn_with_shell("bluetoothctl power on")
        end
    end
    )
))

-- Add icons vor various BT states.
-- These icons should come as beautiful.icons
function widget.set_icons(disabled, enabled, connected)
    icon_dis = disabled
    icon_enab = enabled
    icon_conn = connected
end

awful.tooltip(
   {
      objects = { widget },
      mode = "outside",
      align = "right",
      fg = "white",
      timer_function = function()
         if is_on then
            return "Bluetooth is on"
         else
            return "Bluetooth is off"
         end
      end,
      preferred_positions = {"right", "left", "top", "bottom"}
   }
)

watch("bluetoothctl show", 5,
    function(_, stdout)
        -- Check if there  bluetooth
        local checker = stdout:match("Powered: yes") -- If 'Powered: yes' string is detected on stdout
        -- TODO check for connection and set connected icon
        local widget_icon_nme
        if (checker ~= nil) then
            is_on = true
            widget.icon:set_image(icon_enab)
        else
            is_on = false
            widget.icon:set_image(icon_dis)
        end
        collectgarbage("collect")
    end,
    widget
)

return widget

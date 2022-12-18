local awful = require("awful")
local vicious = require("vicious")
local wibox = require("wibox")

local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.align.horizontal
}
local disk_usage = {}

vicious.register(widget, vicious.widgets.fs,
    function(w, args)
        disk_usage.root = tonumber(args["{/ used_mb}"]) / tonumber(args["{/ size_mb}"])
        disk_usage.home = tonumber(args["{/home used_mb}"]) / tonumber(args["{/home size_mb}"])
    end, 30)

-- These icons should come as beautiful.icons
function widget.set_icons(icon)
    widget.icon:set_image(icon)
end

-- TODO show usage bars in tooltip

-- Tooltip
awful.tooltip(
   {
      objects = { widget },
      mode = "outside",
      align = "right",
      fg = "white",
      margin_leftright = 10,
      margin_topbottom = 10,
      timer_function = function()
          return "root " .. tostring(disk_usage.root * 100):gsub("%p%d*", "") .. "%\n" ..
          "home " .. tostring(disk_usage.home * 100):gsub("%p%d*", "") .. "%"
      end,
      preferred_positions = {"right", "left", "top", "bottom"}
   }
)

return widget

local awful = require("awful")
local gears = require("gears")
local vicious = require("vicious")
local wibox = require("wibox")

local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   {
      id = "text",
      widget = wibox.widget.textbox,
      resize = true,
      forced_width = 30,
      align = "right"
   },
   layout = wibox.layout.align.horizontal
}
local cpus = {}

vicious.register(widget.text, vicious.widgets.cpu,
    function (w, args)
        for i,val in ipairs(args) do
            cpus[i] = args[i + 1]
        end
        return " " .. args[1] .. "%"
    end, 2)

-- TODO change cpu govenour
widget:buttons(awful.util.table.join(
    awful.button({}, 1, nil, function()
    end
    )
))

-- These icons should come as beautiful.icons
function widget.set_icons(cpu)
    widget.icon:set_image(cpu)
end

-- TODO show cpu bars in tooltip
awful.tooltip(
   {
      objects = { widget },
      mode = "outside",
      align = "right",
      fg = "white",
      margin_leftright = 10,
      margin_topbottom = 10,
      timer_function = function()
          local strings = {}
          for i, val in ipairs(cpus) do
              strings[i] = "CPU " .. i .. ": " .. val .. "%"
          end
          return "CPU count: " .. #(cpus) .. "\n" .. table.concat(strings, "\n")
      end,
      preferred_positions = {"right", "left", "top", "bottom"}
   }
)

return widget

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local vicious = require("vicious")
local wibox = require("wibox")

local color = beautiful.bg_focus

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
       resize = true,
       forced_width = 30,
       align = "right"
    },
    layout = wibox.layout.align.horizontal
}
local container = wibox.container.margin(wibox.container.margin(widget, 3), 3)
local pkgs = ""

vicious.register(widget.text, vicious.widgets.pkg,
    function (w, args)
        pkgs = args[2]
        return args[1]
    end, 5, "Arch")

-- These icons should come as beautiful.icons
function container.set_icons(pacman)
    widget.icon:set_image(pacman)
end

awful.tooltip(
   {
      objects = { widget },
      mode = "outside",
      align = "right",
      fg = "white",
      margin_leftright = 10,
      margin_topbottom = 10,
      timer_function = function()
          return "Installable packages: \n" .. pkgs
      end,
      preferred_positions = {"right", "left", "top", "bottom"}
   }
)

return container

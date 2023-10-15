-- requires pulseaudio-ctl and lua53-dkjson installed

local awful = require("awful")
local vicious = require("vicious")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local json = require("dkjson") --require("knorke.json")

local icon_mute
local icon_low
local icon_medium
local icon_high
local mute_state
local vol_id


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

local function change_volume(amount)
    if (amount < 0) then
        awful.util.spawn("amixer -qD pipewire sset Master " .. math.abs(amount) .. "%-")
    else
        awful.util.spawn("amixer -qD pipewire sset Master " .. math.abs(amount) .. "%+")
    end
    local f = io.popen("amixer -D pipewire get Master")
    local vol = 0
    for line in f:lines() do
        for word in string.gmatch(line, "(%d%d?%d?)%%") do
            vol = word
        end
    end
    -- add changed amount as the current value is not yet changed when calling io.popen
    return tonumber(vol) + amount
end

-- Widget function that is available from the outside.
function widget.set_icons(mute, low, medium, high)
    icon_mute = mute
    icon_low = low
    icon_medium = medium
    icon_high = high
end

function widget.notify_mute()
    -- evaluate old state as util.spawn is too slow and io.popen will be evaluated before
    local old_state = io.popen("pulseaudio-ctl full-status")
    for line in old_state:lines() do
        for val in string.gmatch(line, "%d%d?%d?%s(%w%w%w?)") do
            mute_state = val
        end
    end
    local notify_icon = beautiful.icons.vol_mute
    if mute_state == "yes" then
        notify_icon = beautiful.icons.vol_high
    end
    awful.util.spawn("amixer -qD pipewire sset Master toggle")

    vol_id = naughty.notify({
            icon = notify_icon,
            position = "top_middle",
            border_width = 0,
            icon_size = 128,
            replaces_id = vol_id }).id
end

function widget.notify_volume(delta)
    local volume = change_volume(delta)
    if (volume > 50) then
        notify_icon = beautiful.icons.vol_high
    elseif (volume == 0) then
        notify_icon = beautiful.icons.vol_mute
    else
        notify_icon = beautiful.icons.vol_low
    end
    local notify_icon_vol = naughty.notify({
            position = "top_middle",
            border_width = 0,
            icon = notify_icon,
            replaces_id = vol_id })
    vol_id = notify_icon_vol.id
    local notify_width = notify_icon_vol.width
    local bar = wibox.widget.progressbar()
    bar:set_value(volume)
    bar:set_max_value(100)
    bar:set_color(beautiful.archcolor)
    bar:set_background_color(beautiful.archcolor_bg)
    wibox.widget.draw_to_svg_file(bar, "/tmp/vol-bar.svg", 128, 10)
    vol_id_1 = naughty.notify({
            position = "top_middle",
            border_width = 0,
            icon = "/tmp/vol-bar.svg",
            width = notify_width,
            replaces_id = vol_id_1 }).id
end

-- Show audio sinks in tooltip
awful.tooltip(
    {
        objects = { widget },
        mode = "outside",
        align = "right",
        fg = "white",
        margin_leftright = 10,
        margin_topbottom = 10,
        timeout = 5,
        timer_function = function()
            local handle = io.popen("pw-dump -N", "r")
            local json_string = ""
            local results = {}
            for line in  handle:lines() do
                json_string = json_string .. line
            end
            local json_obj, pos, err = json.decode(json_string)
            if not err then
                for i = 1, #json_obj do
                    if json_obj[i].info and json_obj[i].info.props["media.class"] == "Audio/Sink" then
                        local active = ""
                        if json_obj[i].info.state == "running" then
                            active = " *"
                        end
                        table.insert(results, tostring(json_obj[i].info.props["node.description"]) .. active)
                    end
                end
            end
            handle:close()
            return table.concat(results, "\n")
        end,
        preferred_positions = {"right", "left", "top", "bottom"}
    }
)

return widget

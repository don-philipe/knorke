-- TODO: support https
-- TODO: more info from api (see: https://github.com/pyload/pyload/blob/stable/module/Api.py)
-- TODO: provide icon
-- TODO: flashing on captcha request
-- TODO: handle offline pyload server (error: ..../json.lua:352: bad argument #1 to 'len' (string expected, got nil))
local setmetatable = setmetatable
local io = { popen = io.popen }

local awful = require("awful")
local wibox = require("wibox")

local helpers = require("knorke.helpers")
local json = require("knorke.json")

local pyload = { mt = {} }
local thiswidget = wibox.widget.textbox()
local browser = "firefox"

-- all values in returned table are converted to string values
local function update_data(args)
	local pyload_state = {
		["pause"] = "N/A",	-- boolean
--		["captcha"] = "N/A",	-- boolean available in /json/status
		["queue"] = "N/A",	-- integer
		["download"] = "N/A",	-- boolean
		["reconnect"] = "N/A",	-- boolean
		["active"] = "N/A",	-- integer
		["total"] = "N/A",	-- integer
		["speed"] = "N/A"	-- float
	}

	-- first argument host, second port - with fallback to localhost:8000
	local host = args.host or "127.0.0.1"
	local port = args.port or "8000"
	local username = args.user or ""
	local password = args.passwd or ""

	local baseurl = "http://" .. host .. ":" ..port
	local loginurl = baseurl .. "/api/login"
	local statusurl = baseurl .. "/api/statusServer"
	-- the /json/status url needs activated webinterface
	
	-- the cookie from login will be passed to the secound curl command via pipe
	local json_string = io.popen("curl --connect-timeout 1 -fsm 3 --data \"username=" .. username .. "&password=" .. password .. "\" --cookie-jar - " .. loginurl .. " | curl --connect-timeout 1 -fsm 3 --cookie - " .. statusurl)
	for k, v in pairs(json.decode(json_string:read())) do
	--	if k == "pause" then
		pyload_state[k] = tostring(v)
	end
	json_string:close()
	thiswidget:set_text(helpers.sub_format_string(args.format, pyload_state))

	-- open firefox with onclick
	thiswidget:buttons(awful.util.table.join(
		awful.button({ }, 1, function()
			awful.util.spawn(browser .. " " .. baseurl)
		end)))
end

local function setup_update(args)
	mytimer = timer({timeout = tonumber(args.timeout)})
	mytimer:connect_signal("timeout", function() update_data(args) end)
	mytimer:start()
end

function pyload.new(args)
	thiswidget.update = setup_update(args)
	return thiswidget
end

function pyload.mt:__call(...)
	return pyload.new(...)
end

return setmetatable(pyload, pyload.mt)

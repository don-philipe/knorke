-- minimal widget to show how it works

local setmetatable = setmetatable
local wibox = require("wibox")

local testwidget = { mt ={} }
local w = wibox.widget.textbox()

-- cares about getting data and outputting it
local function updatedata()
	w:set_text(tostring(os.time()))
end

-- setup the update cycle an call the functions that update the data
local function setupupdate(t)
	mytimer = timer({timeout = t})
	mytimer:connect_signal("timeout", function() updatedata() end)
	mytimer:start()
end

-- create this widget
function testwidget.new(args)
	w.update = setupupdate(tonumber(args.t))
	return w
end

function testwidget.mt:__call(...)
	return testwidget.new(...)
end

return setmetatable(testwidget, testwidget.mt)

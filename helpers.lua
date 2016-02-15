-- some things copied from vicious' helper

local rawget = rawget
local helpers = {}

-- {{{ Loader for knorke modules
function helpers.wrequire(table, key)
	local module = rawget(table, key)
	return module or require(table._NAME .. "." .. key)
end
-- }}}

-- {{ Format a string with args
function helpers.format(format, args)
	for var, val in pairs(args) do
		format = format:gsub("$" .. (tonumber(var) and var or
			var:gsub("[-+?*]", function(i) return "%"..i end)),
		val)
	end

	return format
end
-- }}}

return helpers

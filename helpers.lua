-- helper functions

local helpers = {}

-- substitutes parts from format_string of the form ${var} with the value from sub_table with the key "var"
function helpers.sub_format_string(format_string, sub_table)
	return string.gsub(format_string, "%${(%w+)}", sub_table)
end

return helpers

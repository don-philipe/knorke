local setmetatable = setmetatable
local wrequire = require("knorke.helpers").wrequire

local widgets = { _NAME = "knorke.widgets" }

-- Load modules at runtime as needed
return setmetatable(contrib, { __index = wrequire })

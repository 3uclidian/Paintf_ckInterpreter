--[[
Commands:
- n: move pointer north
- e: move pointer east
- s: move pointer south
- w: move pointer west
- *: flip bit under pointer
- [: jump past matching ] if current bit is 0
- ]: jump back to the matching ] if bit is non-zero
- ignore any other char (case sensitive, so N E S W are invalid)

data grid is finite and defaults to 0 everywhere
--]]
local cmd = {
	n = function(state) do local _ENV = state
		y = (y - 1 < 1 and height) or y - 1
	end end,
	s = function(state) do local _ENV = state
		y = (y + 1 > height and 1) or y + 1
	end end,
	e = function(state) do local _ENV = state
		x = (x + 1 > width and 1) or x + 1
	end end,
	w = function(state) do local _ENV = state
		x = (x - 1 < 1 and width) or x - 1
	end end,
	['*'] = function(state) do local _ENV = state
		data(x, y, 1 - data(x, y))
	end end,
	['['] = function(state) do local _ENV = state
		if data(x, y) == 1 then
			return
		end
		local bracket = 1
		repeat pointer = pointer + 1
			if c(pointer) == ']' then
				bracket = bracket - 1
			elseif c(pointer) == '[' then
				bracket = bracket + 1
			end
		until bracket == 0 or pointer > len
	end end,
	[']'] = function(state) do local _ENV = state
		if data(x, y) == 0 then
			return
		end
		local bracket = 1
		repeat pointer = pointer - 1
			if c(pointer) == ']' then
				bracket = bracket + 1
			elseif c(pointer) == '[' then
				bracket = bracket - 1
			end
		until bracket == 0 or pointer < 1
	end end,
}

function interpreter(code, iterations, width, height)
	local len = #code
	local function c(n)
		if n < 0 or n > len then return nil end
		return code:sub(n,n)
	end
	local data = setmetatable({}, {
		__index = function(self, key)
			if key > width*height then return nil end
			return 0 
		end,
		__call = function(self, x, y, bit)
			if bit then
				self[(y-1) * width + x] = bit
			else
				return self[(y-1) * width + x]
			end
		end,
		__tostring = function(self)
			local tmp = {}
			for i = 1, width*height, width do
				table.insert(tmp, table.concat(self, "", i, i+width-1))
			end
			return table.concat(tmp, "\r\n")
		end
	})

	local state = {
		x=1,y=1,pointer=1,
		len=len,width=width,height=height,
		data=data,c=c
	}
	local i = iterations
	while i > 0 and 1 <= state.pointer and state.pointer <= len do
		local bit = c(state.pointer)
		if cmd[bit] then
			cmd[bit](state)
			i = i - 1
		end
		state.pointer = state.pointer + 1
	end
	return tostring(data)
end

return interpreter

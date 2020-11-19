--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

Class = {}

-- default (empty) constructor
function Class:init(...) end

-- create a subclass
function Class:extend(obj)
	local obj = obj or {}

	local function copyTable(table, destination)
		local table = table or {}
		local result = destination or {}

		for k, v in pairs(table) do
			if not result[k] then
				if type(v) == "table" and k ~= "__index" and k ~= "__newindex" then
					result[k] = copyTable(v)
				else
					result[k] = v
				end
			end
		end

		return result
	end

	copyTable(self, obj)

	obj._ = obj._ or {}

	local mt = {}

	-- create new objects directly, like o = Object()
	mt.__call = function(self, ...)
		return self:new(...)
	end

	-- allow for getters and setters
	mt.__index = function(table, key)
		local val = rawget(table._, key)
		if val and type(val) == "table" and (val.get ~= nil or val.value ~= nil) then
			if val.get then
				if type(val.get) == "function" then
					return val.get(table, val.value)
				else
					return val.get
				end
			elseif val.value then
				return val.value
			end
		else
			return val
		end
	end

	mt.__newindex = function(table, key, value)
		local val = rawget(table._, key)
		if val and type(val) == "table" and ((val.set ~= nil and val._ == nil) or val.value ~= nil) then
			local v = value
			if val.set then
				if type(val.set) == "function" then
					v = val.set(table, value, val.value)
				else
					v = val.set
				end
			end
			val.value = v
			if val and val.afterSet then val.afterSet(table, v) end
		else
			table._[key] = value
		end
	end

	setmetatable(obj, mt)

	return obj
end

-- set properties outside the constructor or other functions
function Class:set(prop, value)
	if not value and type(prop) == "table" then
		for k, v in pairs(prop) do
			rawset(self._, k, v)
		end
	else
		rawset(self._, prop, value)
	end
end

-- create an instance of an object with constructor parameters
function Class:new(...)
	local obj = self:extend({})
	if obj.init then obj:init(...) end
	return obj
end


function class(attr)
	attr = attr or {}
	return Class:extend(attr)
end
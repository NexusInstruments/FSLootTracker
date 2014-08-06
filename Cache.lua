------------------------------------------------------------------------------------------------
--	FSLootTracker ver. @project-version@
--	by Chronosis--Caretaker-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/chronosis/FSLootTracker
------------------------------------------------------------------------------------------------
--  cache.lua
--	A Simple Key/Value Cache
------------------------------------------------------------------------------------------------
local C_MAJOR, C_MINOR = "SimpleCache-1.0", 1
local C_Pkg = Apollo.GetPackage(C_MAJOR)
if C_Pkg and (C_Pkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

-- Set a reference to the actual package or create an empty table
local Cache = C_Pkg and C_Pkg.tPackage or {}

function Cache:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self 

	o.cache = {}
	o.count = 0
	-- initialize variables here
	return o
end

function Cache:GetValue(key)
	if self.cache[key] then 
		return self.cache[key]
	end
	return nil
end

function Cache:GetAddValue(key)
	if self.cache[key] then 
		return self.cache[key]
	else
		self.count = self.count + 1
		self.cache[key] = self.count
		return self.cache[key]
	end
	return nil
end

function Cache:GetKeyFromValue(value)
	for k, v in pairs(self.cache) do
		if v == value then
			return k
		end
	end
	return nil
end

function Cache:AddKeyValue(key, value)
	if not self:HasKey(key) then
		self.count = self.count + 1
		self.cache[key] = value
	else
		self.cache[key] = value
	end
end

function Cache:HasKey(key)
	if self.cache[key] then
		return true
	end
	return false
end

function Cache:HasValue(value)
	for idx, v in ipairs(self.cache) do
		if v == value then
			return true
		end
	end
	return false
end

function Cache:Clear()
	self.count = 0
	self.cache = {}
end

Apollo.RegisterPackage(Cache, C_MAJOR, C_MINOR, {})

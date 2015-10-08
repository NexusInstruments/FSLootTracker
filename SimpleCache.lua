------------------------------------------------------------------------------------------------
--	SimpleCache ver. @project-version@
--	by Chrono Syz--Entity-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/NexusInstruments/SimpleCache
------------------------------------------------------------------------------------------------
--  SimpleCache.lua
--	A Simple Key/Value Cache
------------------------------------------------------------------------------------------------
local PackageName, Major, Minor, Patch = "SimpleCache", 1, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local SimpleCache = Pkg and Pkg.tPackage or {}


function SimpleCache:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.cache = {}
  o.count = 0
  -- initialize variables here
  return o
end

function SimpleCache:GetValue(key)
  if self.cache[key] then
    return self.cache[key]
  end
  return nil
end

function SimpleCache:GetAddValue(key)
  if self.cache[key] then
    return self.cache[key]
  else
    self.count = self.count + 1
    self.cache[key] = self.count
    return self.cache[key]
  end
  return nil
end

function SimpleCache:GetKeyFromValue(value)
  for k, v in pairs(self.cache) do
    if v == value then
      return k
    end
  end
  return nil
end

function SimpleCache:AddKeyValue(key, value)
  if not self:HasKey(key) then
    self.count = self.count + 1
    self.cache[key] = value
  else
    self.cache[key] = value
  end
end

function SimpleCache:HasKey(key)
  if self.cache[key] then
    return true
  end
  return false
end

function SimpleCache:HasValue(value)
  for idx, v in ipairs(self.cache) do
    if v == value then
      return true
    end
  end
  return false
end

function SimpleCache:Clear()
  self.count = 0
  self.cache = {}
end

Apollo.RegisterPackage(SimpleCache, PkgMajor, PkgMinor, {})

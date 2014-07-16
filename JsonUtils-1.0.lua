-----------------------------------------------------------------------------------------------
-- JsonUtils Module Definition
-----------------------------------------------------------------------------------------------
local JSUMAJOR, JSUMINOR = "Json:Utils-1.0", 1
local JSUPkg = Apollo.GetPackage(JSUMAJOR)
if JSUPkg and (JSUPkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

-- Set a reference to the actual package or create an empty table
local JsonUtils = JSUPkg and JSUPkg.tPackage or {}

JsonUtils.embeded = JsonUtils.embeded or {}

-- upgrading of embeded is done at the bottom of the file
local mixins = {
	"PrintProps", "onEncodeError", 
	"Encode", "EncodePretty"
}   

local chars_to_be_escaped_in_JSON_string
   = '['
   ..    '"'    -- class sub-pattern to match a double quote
   ..    '%\\'  -- class sub-pattern to match a backslash
   ..    '%z'   -- class sub-pattern to match a null
   ..    '\001' .. '-' .. '\031' -- class sub-pattern to match control characters
   .. ']'

local function object_or_array(self, T, etc)
   --
   -- We need to inspect all the keys... if there are any strings, we'll convert to a JSON
   -- object. If there are only numbers, it's a JSON array.
   --
   -- If we'll be converting to a JSON object, we'll want to sort the keys so that the
   -- end result is deterministic.
   --
   local string_keys = { }
   local number_keys = { }
   local number_keys_must_be_strings = false
   local maximum_number_key

   for key in pairs(T) do
      if type(key) == 'string' then
         table.insert(string_keys, key)
      elseif type(key) == 'number' then
         table.insert(number_keys, key)
         if key <= 0 or key >= math.huge then
            number_keys_must_be_strings = true
         elseif not maximum_number_key or key > maximum_number_key then
            maximum_number_key = key
         end
      else
         self:onEncodeError("can't encode table with a key of type " .. type(key), etc)
      end
   end

   if #string_keys == 0 and not number_keys_must_be_strings then
      --
      -- An empty table, or a numeric-only array
      --
      if #number_keys > 0 then
         return nil, maximum_number_key -- an array
      elseif tostring(T) == "JSON array" then
         return nil
      elseif tostring(T) == "JSON object" then
         return { }
      else
         -- have to guess, so we'll pick array, since empty arrays are likely more common than empty objects
         return nil
      end
   end

   table.sort(string_keys)

   local map
   if #number_keys > 0 then
      --
      -- If we're here then we have either mixed string/number keys, or numbers inappropriate for a JSON array
      -- It's not ideal, but we'll turn the numbers into strings so that we can at least create a JSON object.
      --

      if JSON.noKeyConversion then
         self:onEncodeError("a table with both numeric and string keys could be an object or array; aborting", etc)
      end

      --
      -- Have to make a shallow copy of the source table so we can remap the numeric keys to be strings
      --
      map = { }
      for key, val in pairs(T) do
         map[key] = val
      end

      table.sort(number_keys)

      --
      -- Throw numeric keys in there as strings
      --
      for _, number_key in ipairs(number_keys) do
         local string_key = tostring(number_key)
         if map[string_key] == nil then
            table.insert(string_keys , string_key)
            map[string_key] = T[number_key]
         else
            self:onEncodeError("conflict converting table with mixed-type keys into a JSON object: key " .. number_key .. " exists both as a string and a number.", etc)
         end
      end
   end

   return string_keys, nil, map
end

local function backslash_replacement_function(c)
   if c == "\n" then
      return "\\n"
   elseif c == "\r" then
      return "\\r"
   elseif c == "\t" then
      return "\\t"
   elseif c == "\b" then
      return "\\b"
   elseif c == "\f" then
      return "\\f"
   elseif c == '"' then
      return '\\"'
   elseif c == '\\' then
      return '\\\\'
   else
      return string.format("\\u%04x", c:byte())
   end
end
    
function JsonUtils:PrintProps(o, b)
	local strBase = ""
	if b ~= nil then 
		strBase = b 
	end
	
	if type(o) == table then
		for key,value in pairs(o) do
			Print(strBase .. "." .. key .. ":" .. printProp(value, key));
		end
	else
		return o
	end 
end

function JsonUtils:onEncodeError(message, etc)
   if etc ~= nil then
      message = message .. " (" .. JsonUtils:encode(etc) .. ")"
   end

   if self.assert then
      self.assert(false, message)
   else
      Print(message)
   end
end

local function json_string_literal(value)
   local newval = string.gsub(value, chars_to_be_escaped_in_JSON_string, backslash_replacement_function)
   return '"' .. newval .. '"'
end

--
-- Encode
--
local encode_value
local function encode_value(self, value, parents, etc, indent) -- non-nil indent means pretty-printing
   local val = value
   if type(value) == 'userdata' then 
      local newValue
      if value.GetPropertiesKeyed then
	     newValue = value:GetPropertiesKeyed()
         val = newValue
      else
		 newValue = getmetatable(value)
		 val = newValue	
      end
   end	 
   
   if val == nil then
      return 'null'

   elseif type(val) == 'string' then
      return json_string_literal(val)

   elseif type(val) == 'number' then
      if val ~= val then
         --
         -- NaN (Not a Number).
         -- JSON has no NaN, so we have to fudge the best we can. This should really be a package option.
         --
         return "null"
      elseif val >= math.huge then
         --
         -- Positive infinity. JSON has no INF, so we have to fudge the best we can. This should
         -- really be a package option. Note: at least with some implementations, positive infinity
         -- is both ">= math.huge" and "<= -math.huge", which makes no sense but that's how it is.
         -- Negative infinity is properly "<= -math.huge". So, we must be sure to check the ">="
         -- case first.
         --
         return "1e+9999"
      elseif val <= -math.huge then
         --
         -- Negative infinity.
         -- JSON has no INF, so we have to fudge the best we can. This should really be a package option.
         --
         return "-1e+9999"
      else
         return tostring(val)
      end

   elseif type(val) == 'boolean' then
      return tostring(val)
	  
   elseif type(val) ~= 'table' then
      --self:onEncodeError("can't convert " .. type(val) .. " to JSON", etc)
	  return 'null'
   else
      --
      -- A table to be converted to either a JSON object or array.
      --
      local T = val
      if parents[T] then
         self:onEncodeError("table " .. tostring(T) .. " is a child of itself", etc)
      else
         parents[T] = true
      end

      local result_value

      local object_keys, maximum_number_key, map = object_or_array(self, T, etc)
      if maximum_number_key then
         --
         -- An array...
         --
         local ITEMS = { }
         for i = 1, maximum_number_key do
            table.insert(ITEMS, encode_value(self, T[i], parents, etc, indent))
         end

         if indent then
            result_value = "[ " .. table.concat(ITEMS, ", ") .. " ]"
         else
            result_value = "[" .. table.concat(ITEMS, ",") .. "]"
         end

      elseif object_keys then
         --
         -- An object
         --
         local TT = map or T

         if indent then

            local KEYS = { }
            local max_key_length = 0
            for _, key in ipairs(object_keys) do
               local encoded = encode_value(self, tostring(key), parents, etc, "")
               max_key_length = math.max(max_key_length, #encoded)
               table.insert(KEYS, encoded)
            end
            local key_indent = indent .. "    "
            local subtable_indent = indent .. string.rep(" ", max_key_length + 2 + 4)
            local FORMAT = "%s%" .. string.format("%d", max_key_length) .. "s: %s"

            local COMBINED_PARTS = { }
            for i, key in ipairs(object_keys) do
               local encoded_val = encode_value(self, TT[key], parents, etc, subtable_indent)
               table.insert(COMBINED_PARTS, string.format(FORMAT, key_indent, KEYS[i], encoded_val))
            end
            result_value = "{\n" .. table.concat(COMBINED_PARTS, ",\n") .. "\n" .. indent .. "}"

         else

            local PARTS = { }
			
            for _, key in ipairs(object_keys) do
			   --Print(key)
			   --Print(TT[key])
               local encoded_val = encode_value(self, TT[key],       parents, etc, indent)
               local encoded_key = encode_value(self, tostring(key), parents, etc, indent)
               table.insert(PARTS, string.format("%s:%s", encoded_key, encoded_val))
            end
            result_value = "{" .. table.concat(PARTS, ",") .. "}"

         end
      else
         --
         -- An empty array/object... we'll treat it as an array, though it should really be an option
         --
         result_value = "[]"
      end

      parents[T] = false
      return result_value
   end
end

function JsonUtils:Encode(value, etc)
   --if type(self) ~= 'table' or self.__index ~= JsonUtils then
   --   JsonUtils:onEncodeError("JSON:encode must be called in method format", etc)
   --end
   return encode_value(self, value, {}, etc, nil)
end

function JsonUtils:EncodePretty(value, etc)
   --if type(self) ~= 'table' or self.__index ~= JsonUtils then
   --   JsonUtils:onEncodeError("JSON:encode_pretty must be called in method format", etc)
   --end
   return encode_value(self, value, {}, etc, "")
end

function JsonUtils:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   return setmetatable(new, JsonUtils)
end

function JsonUtils:Embed( target )
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end
	self.embeded[target] = true
	return target
end

--- Upgrade our old embeded
for target, v in pairs( JsonUtils.embeded ) do
	JsonUtils:Embed( target )
end

-- No special on Init code
function JsonUtils:OnLoad() end
-- No dependencies
function JsonUtils:OnDependencyError(strDep, strError) return false end

Apollo.RegisterPackage(JsonUtils, JSUMAJOR, JSUMINOR, {})

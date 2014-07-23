JsonUtils
=========
A Wildstar Embeded LUA library to Decode/Encode JSON data - LUA tables.

This can be very helpful when needing to export or save data inside the add-on data storage/settings. Or useful when you want to transport encoded data between add-ons or between clients through the use of in-game comm-channels.

Usage
=====

Embedding
---------
```lua
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)

  self:JSONEncode({ a = 1 })
```

JSONDecode
----------
**Example**
```lua
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
  
  local jsonStr = "[{\"a\":1,\"b\":\"string\",\"c\":{\"a\":1,\"b\":\"string\"},\"d\":null}]"

  local tNewTable = self:JSONDecode(jsonStr)
```
**Results**
```
Value of tNewTable:
{
    a = 1, 
    b = "string", 
    c = { a = 1, b = "string" }
    d = nil
}
```

JSONEncode
----------
**Example**
```lua
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
   
  local tNewTable = {
    a = 1, 
    b = "string", 
    c = { a = 1, b = "string" }
    d = nil
  }
   
  local exportStr = self:JSONEncode(tNewTable)
```
**Results**
```
[{"a":1,"b":"string","c":{"a":1,"b":"string"},"d":null}]
```

JSONEncodePretty
----------------
**Example**
```lua
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
   
  local tNewTable = {
    a = 1, 
    b = "string", 
    c = { a = 1, b = "string" }
    d = nil
  }
   
  local exportStr = self:JSONEncodePretty(tNewTable)
```
**Results**
```
[
  {
    "a": 1,
	"b": "string",
	"c": {
	  "a": 1,
	  "b": "string"
	},
	"d": null
  }
]
```

----

Portions of this library's code attributed to:
```
 JSON-Lua Copyright 2010-2013 Jeffrey Friedl
 http://regex.info/blog/
 Latest version: http://regex.info/blog/lua/json
 Released under a Creative Commons CC-BY "Attribution" License: 
 http://creativecommons.org/licenses/by/3.0/deed.en_US
```

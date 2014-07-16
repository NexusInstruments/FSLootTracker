JsonUtils
=========

A Wildstar Embeded LUA library to Encode LUA objects into JSON strings

This Addon is a partial port of Jeffery Friedl's JSON Lua library.

See licensing information at the end.

Usage
=====
```lua
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
   
  local tNewTable = {
    a = 1, 
    b = "string", 
    c = { a = 1, b = "string" }
    d = nil
  }
   
  local exportStr = self:Encode(tNewTable)
```

Results
```
[{"a":1,"b":"string","c":{"a":1,"b":"string"},"d":null}]
```

----
Copyright 2010-2013 Jeffrey Friedl
http://regex.info/blog/

Latest version: http://regex.info/blog/lua/json
This code is released under a Creative Commons CC-BY "Attribution" License:
http://creativecommons.org/licenses/by/3.0/deed.en_US

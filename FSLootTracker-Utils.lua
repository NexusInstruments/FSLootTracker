require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

function FSLootTracker:DestroyWindowList(list)
  for key,value in pairs(list) do
    list[key]:Destroy()
  end
  list = {}
end

function FSLootTracker:CreateDownListItem(key, value, itemType, dest, color)
  if color == nil then color = "ffffffff" end
  local wnd = Apollo.LoadForm(self.xmlDoc, itemType, dest, self)
  wnd:SetTextColor(ApolloColor.new(color))
  wnd:SetText(value)
  wnd:SetData(key)
  return wnd
end

function FSLootTracker:MakeWindowLocation( x, y, w, h )
  local table = {
    nOffsets = {
      [1] = x,
      [2] = y,
      [3] = h,
      [4] = w
    },
    fPoints = {
      [1] = 0,
      [2] = 0,
      [3] = 0,
      [4] = 0
    }
  }
  return table
end

function FSLootTracker:RecursiveLoad(table, obj)
  for key, value in pairs(table) do
    if obj[key] == nil then
      obj[key] = deepcopy(table[key])
    elseif type(obj[key]) == "table" then
      self:RecursiveLoad(table[key], obj[key])
    end
  end
end

require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

---------------------------------------------------------------------------------------------------
-- ItemAddWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnAddItemButton( wndHandler, wndControl, eMouseButton )
  if not self.state.windows.AddItem then
    self.state.windows.AddItem = Apollo.LoadForm(self.xmlDoc, "ItemAddWindow", nil, self)
    self.state.windows.AddItem:Show(true)
    --self.
  end
end

function FSLootTracker:OnAddSaveButton( wndHandler, wndControl, eMouseButton )
  if self.state.windows.AddItem then
    local itemID = self.state.windows.AddItem:FindChild("ItemID"):GetText()
    local itemLooter = self.state.windows.AddItem:FindChild("ItemLooter"):GetText()
    local itemCount = self.state.windows.AddItem:FindChild("ItemCount"):GetText()
    local itemCost = self.state.windows.AddItem:FindChild("ItemCost"):GetText()
    local item

    -- Must validate the input before we get here -- so people don't enter junk data
    if itemID ~= "" then
      item = Item.GetDataFromId(tonumber(itemID))
      if item then
        Print(item:GetName())
      else
        Print("Item does not exist")
      end
    end

    self.state.windows.AddItem:Show(false)
    self.state.windows.AddItem:Destroy()
    self.state.windows.AddItem = nil
  end
end

function FSLootTracker:OnAddCloseButton( wndHandler, wndControl, eMouseButton )
  if self.state.windows.AddItem then
    self.state.windows.AddItem:Show(false)
    self.state.windows.AddItem:Destroy()
    self.state.windows.AddItem = nil
  end
end

function FSLootTracker:OnItemAddClosed( wndHandler, wndControl )
  if self.state.windows.AddItem then
    self.state.windows.AddItem:Show(false)
    self.state.windows.AddItem:Destroy()
    self.state.windows.AddItem = nil
  end
end

function FSLootTracker:OnAddLookupItem( wndHandler, wndControl, eMouseButton )
end

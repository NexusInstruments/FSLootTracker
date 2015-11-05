require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

---------------------------------------------------------------------------------------------------
-- ListItem Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:CreateEditWindow( wndHandler )
-- Get Parent List item and associated item data.
  local idx = wndHandler:GetData()
  local data = self.state.listItems.items[idx]
  -- Load the item edit panel
  if self.state.windows.edit then
    self.state.windows.edit:Destroy()
  end
  self.state.windows.edit = Apollo.LoadForm(self.xmlDoc, "ItemEditWindow", nil, self)
  self.state.windows.edit:Show(true)

  local itemData = self.state.cache.ItemCache:GetValue(data.itemID)
  local iQuality = itemData.quality
  -- give it a piece of data to refer to
  local wndItemILvl = self.state.windows.edit:FindChild("ItemILvl")
  if wndItemILvl then -- make sure the text wnd exist
    wndItemILvl:SetText("iLvl: " .. itemData.iLvl)
  end

  -- give it a piece of data to refer to
  local wndItemPower = self.state.windows.edit:FindChild("ItemNumber")
  if wndItemPower then -- make sure the text wnd exist
    wndItemPower:SetText("Item #: " .. data.itemID)
  end

  -- give it a piece of data to refer to
  local wndItemText = self.state.windows.edit:FindChild("ItemText")
  if wndItemText then -- make sure the text wnd exist
    wndItemText:SetText(itemData.name)
    wndItemText:SetTextColor(self.tItemQuality[iQuality].Color)
  end

  -- give it a piece of data to refer to
  local wndItemType = self.state.windows.edit:FindChild("ItemType")
  if wndItemType then -- make sure the text wnd exist
    wndItemType:SetText(itemData.type)
  end

  -- give it a piece of data to refer to
  local wndItemCount = self.state.windows.edit:FindChild("ItemCount")
  if wndItemCount then -- make sure the text wnd exist
    wndItemCount:SetText(data.count)
  end

  -- give it a piece of data to refer to
  local wndItemCost = self.state.windows.edit:FindChild("ItemCost")
  if wndItemCost then -- make sure the text wnd exist
    wndItemCost:SetText(data.cost)
  end

  -- give it a piece of data to refer to
  local wndItemPlayer = self.state.windows.edit:FindChild("ItemLooter")
  if wndItemPlayer then -- make sure the text wnd exist
    local strLooter = self.state.cache.LooterCache:GetKeyFromValue(data.looter)
    if strLooter then
      wndItemPlayer:SetText(strLooter)
    end
  end

  -- give it a piece of data to refer to
  local wndItemTimestamp = self.state.windows.edit:FindChild("ItemTimestamp")
  if wndItemTimestamp then -- make sure the text wnd exist
    local strFormat = self.tTimeStampFormats[self.settings.options.timeFormat]
    wndItemTimestamp:SetText("Looted at " .. Chronology:GetFormattedDateTime(data.timeReported, strFormat))
    wndItemTimestamp:SetTextColor(kcrNormalText)
  end

  -- give it a piece of data to refer to
  local wndItemBorder = self.state.windows.edit:FindChild("ItemBorder")
  if wndItemBorder then -- make sure the text wnd exist
    wndItemBorder:SetSprite(self.tItemQuality[iQuality].SquareSprite)
    local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
    if wndItemIcon then
      wndItemIcon:SetSprite(itemData.icon)
      wndItemIcon:SetData(idx)
    end
  end

  self.state.windows.edit:SetData(idx)
end

function FSLootTracker:OnGenerateTooltip( wndHandler, wndControl, eToolTipType, x, y )
  --if wndControl ~= wndHandler then return end
  wndControl:SetTooltipDoc(nil)
  local data = wndHandler:GetData()
  if data then
    local itemID = self.state.listItems.items[data].itemID
    local item = Item.GetDataFromId(tonumber(itemID))
    local itemEquipped = item:GetEquippedItemForItemType()
    Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
    -- Tooltip.GetItemTooltipForm(self, wndControl, itemEquipped, {bPrimary = false, bSelling = false, itemCompare = item})
  end
end

function FSLootTracker:OnLinkItem( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Get Parent List item and associated item data.
  local itemID = self.state.listItems.items[wndHandler:GetData()].itemID
  local oItem = Item.GetDataFromId(tonumber(itemID))
  -- Shift Right click
  if Apollo.IsShiftKeyDown() and eMouseButton == 1 then
    Event_FireGenericEvent("ItemLink", oItem)
  end
end

---------------------------------------------------------------------------------------------------
-- ItemEditWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnEditCloseButton( wndHandler, wndControl, eMouseButton )
  self.state.windows.edit:Show(false)
  self.state.windows.edit:Destroy()
end

function FSLootTracker:OnEditSaveButton( wndHandler, wndControl, eMouseButton )
  -- Get the index, set the values for this tItem index
  idx = wndHandler:GetParent():GetData()

  -- give it a piece of data to refer to
  local wndItemCount = self.state.windows.edit:FindChild("ItemCount")
  if wndItemCount then -- make sure the text wnd exist
    self.state.listItems.items[idx].count = wndItemCount:GetText()
  end

  -- give it a piece of data to refer to
  local wndItemCost = self.state.windows.edit:FindChild("ItemCost")
  if wndItemCost then -- make sure the text wnd exist
    self.state.listItems.items[idx].cost = wndItemCost:GetText()
  end

  -- give it a piece of data to refer to
  local wndItemPlayer = self.state.windows.edit:FindChild("ItemLooter")
  if wndItemPlayer then -- make sure the text wnd exist
    local strLooter = "" .. wndItemPlayer:GetText() .. ""
    local looterID = self.state.cache.LooterCache:GetAddValue(strLooter)
    self.state.listItems.items[idx].looter = looterID
  end

  self:RebuildLists()
  self.state.windows.edit:Show(false)
  self.state.windows.edit:Destroy()
end

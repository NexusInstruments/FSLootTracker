require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

-----------------------------------------------------------------------------------------------
-- FSLootTracker Main Form -- List Item Flyout
-----------------------------------------------------------------------------------------------
-- when a list item is selected
function FSLootTracker:OnLootListItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- make sure the wndControl is valid
  if wndHandler ~= wndControl then
    return
  end

  self.state.windows.contextFlyout:Show(false)

  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    self:CreateEditWindow( wndHandler )
  end

  if eMouseButton == 1 then -- Right Clicked
    -- Shift Right click
    if Apollo.IsShiftKeyDown() then
      local itemID = self.state.listItems.items[wndHandler:GetData()].itemID
      local oItem = Item.GetDataFromId(tonumber(itemID))
      Event_FireGenericEvent("ItemLink", oItem)
    else
      -- Close the last context window if you've opened a different one.
      local mousePos = Apollo.GetMouse()
      local tWinMain = self.state.windows.main:GetLocation():ToTable()
      -- Calculate Offset from main window
      local x, y = (mousePos.x - tWinMain.nOffsets[1]), (mousePos.y - tWinMain.nOffsets[2])
      -- Position it
      local t = self:MakeWindowLocation(x, y, x + self.tContextFlyoutSize.width, y + self.tContextFlyoutSize.height)
      self.state.windows.contextFlyout:MoveToLocation(WindowLocation.new(t))
      self.state.windows.contextFlyout:Show(true)
      self.state.windows.LastItemSelected = wndHandler
    end
  end
end

function FSLootTracker:OnEditBtnClicked( wndHandler, wndControl, eMouseButton )
  self.state.windows.contextFlyout:Show(false)

  -- Get Parent List item and associated item data.
  self:CreateEditWindow( self.state.windows.LastItemSelected )
end

function FSLootTracker:OnDeleteBtnClicked( wndHandler, wndControl, eMouseButton )
  -- Get Parent List item and associated item data.
  local index = self.state.windows.LastItemSelected:GetData()
  -- wndHandler:Show(false) -- derp, lol why would I hide the button.
  table.remove(self.state.listItems.items, index)
  self.state.windows.contextFlyout:Show(false)
  self:RebuildLists()
end

function FSLootTracker:OnIgnoreBtnClicked( wndHandler, wndControl, eMouseButton )
  -- Get Parent List item and associated item data.
  local index = self.state.windows.LastItemSelected:GetData()
  local item = self.state.listItems.items[index]
  local cItem = self.state.cache.ItemCache:GetValue(item.itemID)
  self.settings.user.ignored[item.itemID] = cItem.name
  -- Process item list for all ignored items and remove them
  self.state.windows.contextFlyout:Show(false)
  self:RebuildLists()
end

function FSLootTracker:OnWatchBtnClicked( wndHandler, wndControl, eMouseButton )
  -- Get Parent List item and associated item data.
  local index = self.state.windows.LastItemSelected:GetData()
  local item = self.state.listItems.items[index]
  local cItem = self.state.cache.ItemCache:GetValue(item.itemID)
  self.settings.user.watched[item.itemID] = cItem.name
  -- Process item list for all watched items and update counts
  self.state.windows.contextFlyout:Show(false)
  self:RebuildLists()
  self:ResizeAllTracker()
end

function FSLootTracker:OnMarkBtnToggle( wndHandler, wndControl, eMouseButton )
  self.state.windows.contextFlyoutMarkAs:Show(wndHandler:IsChecked())
end

function FSLootTracker:OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  --self.state.windows.contextFlyout:Show(false)
end

function FSLootTracker:OnContextClosed( wndHandler, wndControl )
  self.state.windows.contextFlyout:FindChild("FlyoutButtons"):FindChild("Mark"):SetCheck(false)
  self.state.windows.contextFlyout:Show(false)
  self.state.windows.contextFlyoutMarkAs:Show(false)
end

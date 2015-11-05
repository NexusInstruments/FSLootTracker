require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

-----------------------------------------------------------------------------------------------
-- FSLootTracker Main Form -- List Item Flyout
-----------------------------------------------------------------------------------------------
-- when a list item is selected
function FSLootTracker:OnListItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
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
      --Print(self:JSONEncode(mousePos))
      -- Position it
      self.state.windows.contextFlyout:SetAnchorOffsets(mousePos.x - self.tContextFlyoutSize.width, mousePos.y, mousePos.x , mousePos.y + self.tContextFlyoutSize.height)
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

function FSLootTracker:OnBlacklistBtnClicked( wndHandler, wndControl, eMouseButton )
  self.state.windows.contextFlyout:Show(false)
  -- Get Parent List item and associated item data.
  local index = self.state.windows.LastItemSelected:GetData()
end

function FSLootTracker:OnItemExportBtnClicked( wndHandler, wndControl, eMouseButton )
  self.state.windows.contextFlyout:Show(false)
  -- Get Parent List item and associated item data.
  local index = self.state.windows.LastItemSelected:GetData()
end


function FSLootTracker:OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  --self.state.windows.contextFlyout:Show(false)
end

function FSLootTracker:OnContextClosed( wndHandler, wndControl )
  self.state.windows.contextFlyout:Show(false)
end

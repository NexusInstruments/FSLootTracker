require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage

-----------------------------------------------------------------------------------------------
-- FSLootTracker Main Form -- Base
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function FSLootTracker:OnOK( wndHandler, wndControl, eMouseButton )
  self:SaveLocation()
  self.state.windows.main:Close() -- hide the window
  self.state.isOpen = false
end

-- when the Cancel button is clicked
function FSLootTracker:OnCancel( wndHandler, wndControl, eMouseButton )
  self:SaveLocation()
  self.state.windows.main:Close() -- hide the window
  self.state.isOpen = false
end

-- when the Clear button is clicked
function FSLootTracker:OnClear( wndHandler, wndControl, eMouseButton )
  if not self.state.windows.DeleteConfirm then
    --Show Confirm Window
    self.state.windows.DeleteConfirm = Apollo.LoadForm(self.xmlDoc, "ConfirmDeleteWindow", nil, self)
    self.state.windows.DeleteConfirm:Show(true)
  end
end

function FSLootTracker:SaveLocation()
  self.settings.positions.main = self.state.windows.main:GetLocation():ToTable()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker Main Form -- Tabs
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnSplashItemsCheck( wndHandler, wndControl, eMouseButton )
  wnd = wndHandler:GetParent():GetParent():FindChild("ItemList")
  wnd:Show(true)
end

function FSLootTracker:OnSplashItemsUncheck( wndHandler, wndControl, eMouseButton )
  wnd = wndHandler:GetParent():GetParent():FindChild("ItemList")
  wnd:Show(false)
end

function FSLootTracker:OnSplashMoneyCheck( wndHandler, wndControl, eMouseButton )
  wnd = wndHandler:GetParent():GetParent():FindChild("MoneyWindow")
  wnd:Show(true)
end

function FSLootTracker:OnSplashMoneyUncheck( wndHandler, wndControl, eMouseButton )
  wnd = wndHandler:GetParent():GetParent():FindChild("MoneyWindow")
  wnd:Show(false)
end

---------------------------------------------------------------------------------------------------
-- ConfirmDeleteWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnConfirmDelete( wndHandler, wndControl, eMouseButton )
  self:ClearLists()
  if self.state.windows.DeleteConfirm then
    self.state.windows.DeleteConfirm:Show(false)
    self.state.windows.DeleteConfirm:Destroy()
  end
  self.state.windows.DeleteConfirm = nil
end

function FSLootTracker:OnCancelDelete( wndHandler, wndControl, eMouseButton )
  if self.state.windows.DeleteConfirm then
    self.state.windows.DeleteConfirm:Show(false)
    self.state.windows.DeleteConfirm:Destroy()
  end
  self.state.windows.DeleteConfirm = nil
end

function FSLootTracker:OnRecordingStopButton( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnRecordingStartButton( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:SortItemList( wndHandler, wndControl, eMouseButton )
end

---------------------------------------------------------------------------------------------------
-- FSLootTracker UI Refresh
---------------------------------------------------------------------------------------------------
function FSLootTracker:RefreshUI()
  -- Location Restore
  if self.settings.positions.main then
    locSavedLoc = WindowLocation.new(self.settings.positions.main)
    self.state.windows.main:MoveToLocation(locSavedLoc)
  end
end

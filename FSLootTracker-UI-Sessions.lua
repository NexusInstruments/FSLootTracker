require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

---------------------------------------------------------------------------------------------------
-- ListSession Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnSessionItemClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    -- Open Edit Description
  end
  if eMouseButton == 1 then -- Right Clicked
    -- Open Context Dialog
  end
end

function FSLootTracker:OnSessionsFlyoutChecked( wndHandler, wndControl, eMouseButton )
  self.state.windows.Sessions:Show(true)
end

function FSLootTracker:OnSessionsFlyoutUnchecked( wndHandler, wndControl, eMouseButton )
  self.state.windows.Sessions:Show(false)
end

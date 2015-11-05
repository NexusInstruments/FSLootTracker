require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

function FSLootTracker:OnInfoButton( wndHandler, wndControl, eMouseButton )
  if not self.state.windows.info then
    self.state.windows.info = Apollo.LoadForm(self.xmlDoc, "AboutWindow", nil, self)
    local wndLeft = self.state.windows.info:FindChild("Left"):FindChild("Sprite")
    local wndRight = self.state.windows.info:FindChild("Right"):FindChild("Sprite")
    wndLeft:SetSprite("FSLootSprites:FSPoster")
    wndRight:SetText(self.strDefaultGuildInfoText)
    self.state.windows.info:Show(true)
  end
end

function FSLootTracker:OnInfoClose( wndHandler, wndControl, eMouseButton )
  if self.state.windows.info then
    self.state.windows.info:Show(false)
    self.state.windows.info:Destroy()
    self.state.windows.info = nil
  end
end

function FSLootTracker:OnInfoWindowClosed( wndHandler, wndControl )
  if self.state.windows.info then
    self.state.windows.info:Show(false)
    self.state.windows.info:Destroy()
    self.state.windows.info = nil
  end
end

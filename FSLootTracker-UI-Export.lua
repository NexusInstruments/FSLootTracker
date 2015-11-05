require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

---------------------------------------------------------------------------------------------------
-- ExportWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnExportData( wndHandler, wndControl, eMouseButton )
  if not self.state.windows.Export then
    self:RebuildExportList()
    self.state.windows.Export = Apollo.LoadForm(self.xmlDoc, "ExportWindow", nil, self)
    local copybtn = self.state.windows.Export:FindChild("CopyToClipboard")
    local exportStr = self:GenerateLootExportString()
    copybtn:SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard, exportStr)
    self.state.windows.Export:FindChild("ExportString"):SetText(exportStr)
    self.state.windows.Export:Show(true)
  end
end

function FSLootTracker:OnCloseExport( wndHandler, wndControl, eMouseButton )
  wndHandler:GetParent():Show(false)
  wndHandler:GetParent():Destroy()
  self.state.windows.Export = nil
end

function FSLootTracker:OnExportClosed( wndHandler, wndControl )
  local parWnd = wndHandler:GetParent()
  if parWnd then
    parWnd:Show(false)
    parWnd:Destroy()
  end
  self.state.windows.Export = nil
end

function FSLootTracker:GenerateLootExportString()
  local exportString = ""
  if self.settings.options.exportFormat == self.tExportFormats.json then
    exportString = self:JSONEncodePretty(self.state.listItems.itemsExport)
  end

  if self.settings.options.exportFormat == self.tExportFormats.bbcode then
    for i,v in ipairs(self.state.listItems.itemsExport) do
      local time = v.timeReported
      exportString = exportString .. "(" .. Chronology:GetFormattedDateTime(time) .. ") [b]" .. v.source .. "[/b] - " .. v.looter .. " - [url=" .. v.jabbitLink .. "]" .. v.itemName .. "[/url]\n"
    end
  end

  if self.settings.options.exportFormat == self.tExportFormats.html then
    for i,v in ipairs(self.state.listItems.itemsExport) do

    end
  end

  if exportString == "" then
    -- Unknown format
    exportString = "XXX"
  end

  return exportString
end

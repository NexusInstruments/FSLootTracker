require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

---------------------------------------------------------------------------------------------------
-- Export Data Functions
---------------------------------------------------------------------------------------------------
-- rebuild list used to export the data
function FSLootTracker:RebuildExportList()
  self.state.listItems.itemsExport = {}
  for idx, itemInstance in pairs(self.state.listItems.items) do
    local item = self.state.cache.ItemCache:GetValue(itemInstance.itemID)
    if item then
      local itemName = item.name

      local jabbitLink = "http://www.jabbithole.com/items/" .. self:StripCharacters(string.lower(itemName)) .. "-" .. tostring(itemInstance.itemID)

      local tNewEntry =
      {
        itemID = itemInstance.itemID,
        itemName = itemName,
        itemQuality = itemInstance.quality,
        itemILvl = item.iLvl,
        itemType = item.type,
        count = itemInstance.count,
        looter = self.state.cache.LooterCache:GetKeyFromValue(itemInstance.looter),
        source = self.state.cache.SourceCache:GetKeyFromValue(itemInstance.source),
        cost = itemInstance.cost,
        gameTimeAdded = itemInstance.timeAdded,
        timeReported = itemInstance.timeReported,
        jabbitLink = jabbitLink
      }
      table.insert(self.state.listItems.itemsExport, tNewEntry)
    end
  end
end

function FSLootTracker:StripCharacters(str)
  local s = string.gsub(str,"-","")
  s = string.gsub(s," ","-")
  s = string.gsub(s, "'","")
  s = string.gsub(s, "\"","")
  return s
end
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
    exportString = self:DoJSONExport()
  elseif self.settings.options.exportFormat == self.tExportFormats.bbcode then
    exportString = self:DoBBCodeExport()
  elseif self.settings.options.exportFormat == self.tExportFormats.html then
    exportString = self:DoHTMLExport()
  elseif self.settings.options.exportFormat == self.tExportFormats.eqdkpxml then
    exportString = self:DoEQDKPXMLExport()
  elseif self.settings.options.exportFormat == self.tExportFormats.csv then
    exportString = self:DoCSVExport()
  end


  if exportString == "" then
    -- Unknown format
    exportString = "XXX"
  end

  return exportString
end

function FSLootTracker:DoJSONExport()
  return self:JSONEncodePretty(self.state.listItems.itemsExport)
end

function FSLootTracker:DoBBCodeExport()
  local str = ""
  for i,v in pairs(self.state.listItems.itemsExport) do
    local time = v.timeReported
    str = str .. "(" .. Chronology:GetFormattedDateTime(time) .. ") [b]" .. v.source .. "[/b] - " .. v.looter .. " - [url=" .. v.jabbitLink .. "]" .. v.itemName .. "[/url]\n"
  end
  return str
end

function FSLootTracker:DoHTMLExport()
  local str = "<html><body><table>\n<tr><th>TIMESTAMP</th><th>ID</th><th>NAME</th><th>COUNT</th><th>LOOTER</th><th>SOURCE</th><th>COST</th><th>QUALITY</th><th>ILVL</th><th>TYPE</th></tr>\n"
  for i,v in pairs(self.state.listItems.itemsExport) do
    local time = v.timeReported
    str = str .. "<tr><td>" .. Chronology:GetFormattedDateTime(time) .. "</td><td>" .. v.itemID .. "</td><td><a href='" .. v.jabbitLink .. "'>" .. v.itemName .. "</a></td><td>" .. v.count .. "</td><td>" .. v.looter .. "</td><td>" .. v.source .. "</td><td>" .. v.cost .. "</td><td>" .. v.itemQuality .. "</td><td>" .. v.itemILvl .. "</td><td>" .. v.itemType .. "</td></tr>\n"
  end
  str = str .. "</table></body></html>"
  return str
end

function FSLootTracker:DoCSVExport()
  local str = "TIMESTAMP, ID, NAME, COUNT, LOOTER, SOURCE, COST, QUALITY, ILVL, TYPE\n"
  for i,v in pairs(self.state.listItems.itemsExport) do
    local time = v.timeReported
    str = str .. "" .. Chronology:GetFormattedDateTime(time) .. ", " .. v.itemID .. ", " .. v.itemName .. ", " .. v.count .. ", " .. v.looter .. ", " .. v.source .. ", " .. v.cost .. ", " .. v.itemQuality .. ", " .. v.itemILvl .. ", " .. v.itemType .. "\n"
  end
  return str
end

function FSLootTracker:DoEQDKPXMLExport()
end

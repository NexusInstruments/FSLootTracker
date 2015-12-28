require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnConfigure
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnConfigure()
  if self.state.windows.options == nil then
    self.state.windows.options = Apollo.LoadForm(self.xmlDoc, "LootTrackerOptionsWindow", nil, self)
    self.state.windows.optionsTabs = self.state.windows.options:FindChild("TabList")
    self.state.windows.optionsExportFormatType = self.state.windows.options:FindChild("TabWindow1"):FindChild("Export"):FindChild("ExportDropdown")
    self.state.windows.optionsIgnoredList = self.state.windows.options:FindChild("TabWindow2"):FindChild("IgnoreItemList")
    self.state.windows.optionsWatchedList = self.state.windows.options:FindChild("TabWindow3"):FindChild("WatchItemList")
    self.state.windows.optionsTrackedQuality = self.state.windows.options:FindChild("TabWindow4"):FindChild("QualityBtns")
    self.state.windows.optionsTrackedSources = self.state.windows.options:FindChild("TabWindow4"):FindChild("SourceBtns")

    self.state.windows.options:Show(true)
    self:PopulateExportFormatDropdown()
    self:PopulateIgnoredList()
    self:PopulateWatchedList()
    self:RefreshUIOptions()
  end
  self.state.windows.options:ToFront()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker Configuration UI Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnOptionsSave( wndHandler, wndControl, eMouseButton )
  -- Tab1
  self.settings.options.defaultCost = self.state.windows.options:FindChild("TabWindow1"):FindChild("ItemCost"):FindChild("OptionsConfigureCostsEditBox"):GetText()
  self.settings.options.persistSession = self.state.windows.options:FindChild("TabWindow1"):FindChild("PersistButton"):IsChecked()
  self.settings.user.debug.enabled = self.state.windows.options:FindChild("TabWindow1"):FindChild("DebugButton"):IsChecked()
  self.settings.options.exportFormat = self.state.windows.options:FindChild("TabWindow1"):FindChild("Export"):FindChild("ExportSelection"):GetData()
  self.settings.options.defaultCost = self.state.windows.options:FindChild("TabWindow1"):FindChild("ItemCost"):FindChild("OptionsConfigureCostsEditBox"):GetText()
  if self.state.windows.options:FindChild("TabWindow1"):FindChild("12h"):IsChecked() then
    self.settings.options.timeFormat = "12h"
  else
    self.settings.options.timeFormat = "24h"
  end
  self.settings.options.pollingInterval = self.state.windows.options:FindChild("PollingIntervalValue"):GetData()
  self.settings.options.graphLength = self.state.windows.options:FindChild("GraphLengthValue"):GetData()

  -- Tab4
  for k,v in pairs(self.settings.options.qualityFilters) do
    self.settings.options.qualityFilters[k] = self.state.windows.optionsTrackedQuality:FindChild(self.tItemQuality[k].Name):IsChecked()
  end

  for k,v in pairs(self.settings.options.sourceFilters) do
    self.settings.options.sourceFilters[k] = self.state.windows.optionsTrackedSources:FindChild(self.tLootSourcesNames[k]):IsChecked()
  end

  -- Tab5
  self.settings.user.debug.flags["Items"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugItemsButton"):IsChecked()
  self.settings.user.debug.flags["Money"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugMoneyButton"):IsChecked()
  self.settings.user.debug.flags["Kills"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugKillsButton"):IsChecked()
  self.settings.user.debug.flags["Encounters"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugEncountersButton"):IsChecked()
  self.settings.user.debug.flags["ListRebuilds"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugListRebuildsButton"):IsChecked()
  self.settings.user.debug.flags["Cache"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugCacheButton"):IsChecked()
  self.settings.user.debug.flags["Generic"] = self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugGenericButton"):IsChecked()

  self:CloseOptions()
end

function FSLootTracker:OnOptionsCancel( wndHandler, wndControl, eMouseButton )
  self:CloseOptions()
end

function FSLootTracker:OnOptionsClosed( wndHandler, wndControl )
  self:CloseOptions()
end

function FSLootTracker:CloseOptions()
  self.state.windows.options:Show(false)
  self.state.windows.options:Destroy()
  self.state.windows.options = nil
  self.state.windows.optionsTabs = nil
  self.state.windows.optionsTrackedQuality = nil
  self.state.windows.optionsTrackedSources = nil
  self.state.windows.optionsExportFormatType = nil
end

function FSLootTracker:OnExportFormatBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.optionsExportFormatType:Show(bChecked)
  self:ToggleOptionButtons(not bChecked)
  if bChecked == true then
    self.state.windows.optionsExportFormatType:ToFront()
  end
end

function FSLootTracker:OnExportTypeSelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.optionsExportFormatType:GetParent()
    local select = wnd:FindChild("ExportSelection")
    local item = self.tExportFormatNames[idx]
    select:SetCheck(false)
    select:SetText(item)
    select:SetData(idx)
    wnd:FindChild("ExportDropdown"):Show(false)
    self:ToggleOptionButtons(true)
  end
end

function FSLootTracker:PopulateExportFormatDropdown()
  local listWindow = self.state.windows.optionsExportFormatType
  local list = self.state.listItems.exportFormats
  local listItemName = "ExportTypeListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Loop through remaining items
  for key,value in pairs(self.tExportFormatNames) do
    local wnd = self:CreateDownListItem(key, value, listItemName, listWindow, nil)
    table.insert(list, wnd)
  end
  listWindow:ArrangeChildrenVert()
end

function FSLootTracker:PopulateIgnoredList()
  local listWindow = self.state.windows.optionsIgnoredList
  local list = self.state.windows.ignoredItems
  local listItemName = "FilteredListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Loop through remaining items
  if self.settings.user.ignored then
    for key,value in pairs(self.settings.user.ignored) do
      local wnd = self:CreateDownListItem("ignore|" .. key, value, listItemName, listWindow, nil)
      table.insert(list, wnd)
    end
  end
  listWindow:ArrangeChildrenVert()
end

function FSLootTracker:PopulateWatchedList()
  local dropdown = self.state.windows.optionsWatchedList
  local list = self.state.windows.watchedItems
  local listItemName = "FilteredListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Loop through remaining items
  if self.settings.user.watched then
    for key,value in pairs(self.settings.user.watched) do
      local wnd = self:CreateDownListItem("watch|" .. key, value, listItemName, dropdown, nil)
      table.insert(list, wnd)
    end
  end
  dropdown:ArrangeChildrenVert()
end

function FSLootTracker:ToggleOptionButtons(state)
  local persistButton = self.state.windows.options:FindChild("PersistButton")
  local debugButton = self.state.windows.options:FindChild("DebugButton")
  local h12Button = self.state.windows.options:FindChild("12h")
  local h24Button = self.state.windows.options:FindChild("24h")
  local cancelButton = self.state.windows.options:FindChild("CancelButton")
  local saveButton = self.state.windows.options:FindChild("SaveButton")
  local editBox = self.state.windows.options:FindChild("OptionsConfigureCostsEditBox")
  local graphLength = self.state.windows.options:FindChild("GraphLengthSlider")
  local pollingInterval = self.state.windows.options:FindChild("PollingIntervalSlider")
  self.state.closeOptionDropdown = state
  persistButton:Enable(state)
  debugButton:Enable(state)
  h12Button:Enable(state)
  h24Button:Enable(state)
  cancelButton:Enable(state)
  saveButton:Enable(state)
  editBox:Enable(state)
  graphLength:Enable(state)
  pollingInterval:Enable(state)
end

function FSLootTracker:OnPollingTimerSliderChanged( wndHandler, wndControl, fNewValue, fOldValue )
  self.settings.options.pollingInterval = math.floor(fNewValue)
  self.state.windows.options:FindChild("PollingIntervalValue"):SetText(self.tPollingIntervals[self.settings.options.pollingInterval].text)
  self.state.windows.options:FindChild("PollingIntervalValue"):SetData(self.settings.options.pollingInterval)
end

function FSLootTracker:OnGraphLengthSliderChanged( wndHandler, wndControl, fNewValue, fOldValue )
  self.settings.options.graphLength = math.floor(fNewValue)
  self.state.windows.options:FindChild("GraphLengthValue"):SetText(self.tGraphWindowLengths[self.settings.options.graphLength].text)
  self.state.windows.options:FindChild("GraphLengthValue"):SetData(self.settings.options.graphLength)
end

---------------------------------------------------------------------------------------------------
-- LootTrackerOptionsWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnConfigTabEnter( wndHandler, wndControl, x, y )
  if self.state.closeOptionDropdown then
    wndHandler:SetBGColor(self.tabColors.hover)
    self.state.optionsHovered = true
  end
end

function FSLootTracker:OnConfigTabExit( wndHandler, wndControl, x, y )
  if self.state.closeOptionDropdown then
    self.state.optionsHovered = false
    self:RefreshUIOptions()
  end
end

function FSLootTracker:OnConfigTabPress( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if self.state.closeOptionDropdown then
    tab = wndHandler:GetParent()
    tabName = tab:GetName()
    tabID = tonumber(tabName)

    if self.state.curOptionTab ~= tabID then
      self.state.curOptionTab = tabID
      self:RefreshUIOptions()
    else
      -- Do Nothing
    end
  end
end

function FSLootTracker:RefreshUIOptions()
  -- Set Tabs
  for i=1,5 do
    tab = self.state.windows.optionsTabs:FindChild("" .. i):FindChild("BG")
    tabWindow = self.state.windows.options:FindChild("TabWindow" .. i)
    if i == self.state.curOptionTab then
      if self.state.optionsHovered == false then
        tab:SetBGColor(self.tabColors.selected)
      end
      tabWindow:Show(true)
    else
      tab:SetBGColor(self.tabColors.normal)
      tabWindow:Show(false)
    end
  end

  -- Set Options
  -- Tab1
  self.state.windows.options:FindChild("TabWindow1"):FindChild("PersistButton"):SetCheck(self.settings.options.persistSession)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("DebugButton"):SetCheck(self.settings.user.debug.enabled)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("Export"):FindChild("ExportSelection"):SetText(self.tExportFormatNames[self.settings.options.exportFormat])
  self.state.windows.options:FindChild("TabWindow1"):FindChild("Export"):FindChild("ExportSelection"):SetData(self.settings.options.exportFormat)
  self.state.windows.options:FindChild("TabWindow1"):FindChild(self.settings.options.timeFormat):SetCheck(true)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("ItemCost"):FindChild("OptionsConfigureCostsEditBox"):SetText(self.settings.options.defaultCost)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("GraphLengthSlider"):SetValue(self.settings.options.graphLength)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("GraphLengthValue"):SetText(self.tGraphWindowLengths[self.settings.options.graphLength].text)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("GraphLengthValue"):SetData(self.settings.options.graphLength)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("PollingIntervalSlider"):SetValue(self.settings.options.pollingInterval)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("PollingIntervalValue"):SetText(self.tPollingIntervals[self.settings.options.pollingInterval].text)
  self.state.windows.options:FindChild("TabWindow1"):FindChild("PollingIntervalValue"):SetData(self.settings.options.pollingInterval)

  -- Tab4
  -- initialize filter states
  for k,v in pairs(self.settings.options.qualityFilters) do
    self.state.windows.optionsTrackedQuality:FindChild(self.tItemQuality[k].Name):SetCheck(v)
  end

  for k,v in pairs(self.settings.options.sourceFilters) do
    self.state.windows.optionsTrackedSources:FindChild(self.tLootSourcesNames[k]):SetCheck(v)
  end

  -- Tab5
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugItemsButton"):SetCheck(self.settings.user.debug.flags["Items"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugMoneyButton"):SetCheck(self.settings.user.debug.flags["Money"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugKillsButton"):SetCheck(self.settings.user.debug.flags["Kills"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugEncountersButton"):SetCheck(self.settings.user.debug.flags["Encounters"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugListRebuildsButton"):SetCheck(self.settings.user.debug.flags["ListRebuilds"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugCacheButton"):SetCheck(self.settings.user.debug.flags["Cache"])
  self.state.windows.options:FindChild("TabWindow5"):FindChild("DebugGenericButton"):SetCheck(self.settings.user.debug.flags["Generic"])
end

---------------------------------------------------------------------------------------------------
-- FilteredListItem Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnDeleteFilteredItem( wndHandler, wndControl, eMouseButton )
  local data = wndHandler:GetParent():GetData() -- this should return the lua object
  local result = data:split("|")
  local type = result[1]
  local key = tonumber(result[2])
  local list = {}
  if type == "ignore" then
    list = self.settings.user.ignored
    list[key] = nil
    self:PopulateIgnoredList()            -- Refreshes the list
    self:RebuildLists()
  elseif type == "watch" then
    list = self.settings.user.watched
    list[key] = nil
    self:PopulateWatchedList()            -- Refreshes the list
    self:RebuildLists()
    self:ResizeAllTracker()
  end
end

---------------------------------------------------------------------------------------------------
-- Tabs UI Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnListItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Highlight
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidPressed")
  self.state.windows.selectedItem = wndHandler
end

function FSLootTracker:OnListItemEntered( wndHandler, wndControl, x, y )
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidFlyby")
end

function FSLootTracker:OnListItemExited( wndHandler, wndControl, x, y )
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidNormal")
end

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
    self.state.windows.editConfigCosts = self.state.windows.options:FindChild("TabWindow1"):FindChild("OptionsConfigureCosts"):FindChild("EditBox")
    self.state.windows.editConfigTimeFormat = self.state.windows.options:FindChild("TabWindow1"):FindChild("OptionsConfigureTimeFormat")
    self.state.windows.editConfigTypes = self.state.windows.options:FindChild("TabWindow3"):FindChild("QualityBtns")
    self.state.windows.editConfigSources = self.state.windows.options:FindChild("TabWindow3"):FindChild("SourceBtns")

    -- Load Options

    -- self.state.windows.options:FindChild("AutoMLButton"):SetCheck(self.settings.options.autoSetMasterLootWhenLeading)
    -- self.state.windows.options:FindChild("EnableInDungeon"):SetCheck(self.settings.options.autoEnableInDungeon)
    -- self.state.windows.options:FindChild("EnableInRaid"):SetCheck(self.settings.options.autoEnableInRaid)
    -- self.state.windows.options:FindChild("AutoDisableButton"):SetCheck(self.settings.options.autoDisableUponExitInstance)
    -- self.state.windows.options:FindChild("PartyLootRuleSelection"):SetData(self.settings.options.masterLootRule)
    -- self.state.windows.options:FindChild("PartyLootRuleSelection"):SetText(self.tLootRules[self.settings.options.masterLootRule])
    -- self.state.windows.options:FindChild("ThresholdSelection"):SetData(self.settings.options.masterLootQualityThreshold)
    -- self.state.windows.options:FindChild("ThresholdSelection"):SetText(self.tItemQuality[self.settings.options.masterLootQualityThreshold].Name)
    -- self.state.windows.options:FindChild("ThresholdSelection"):SetNormalTextColor(ApolloColor.new(self.tItemQuality[self.settings.options.masterLootQualityThreshold].Color))

    self.state.windows.options:Show(true)
    self:RefreshUIOptions()
  end
  self.state.windows.options:ToFront()
end

---------------------------------------------------------------------------------------------------
-- OptionsContainer Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnOptionsCloseClick( wndHandler, wndControl, eMouseButton )
  self.state.windows.main:FindChild("ConfigButton"):SetCheck(false)
  self:OnOptionsToggle()
end

function FSLootTracker:OnOptionsToggle( wndHandler, wndControl, eMouseButton )
  local state = self.state.windows.main:FindChild("ConfigButton"):IsChecked()
  self.state.windows.lootOpts:FindChild("OptionsContainer"):Show(state)
  if state then
    self:RefreshUIOptions()
  else
    self.settings.options.defaultCost = self.state.windows.editConfigCosts:GetText()
  end
end

function FSLootTracker:OnQualityBtnChecked( wndHandler, wndControl, eMouseButton )
  local name = wndControl:GetName()
  local qualEnum = self.tItemQualityNames[name]
  self.settings.options.qualityFilters[qualEnum] = true
end

function FSLootTracker:OnQualityBtnUnchecked( wndHandler, wndControl, eMouseButton )
  local name = wndControl:GetName()
  local qualEnum = self.tItemQualityNames[name]
  self.settings.options.qualityFilters[self.tItemQualityNames[name]] = false
end

function FSLootTracker:OnTimeFormatCheck( wndHandler, wndControl, eMouseButton )
  self.settings.options.timeFormat = wndControl:GetText()
end


-----------------------------------------------------------------------------------------------
-- FSLootTracker Configuration UI Functions
-----------------------------------------------------------------------------------------------

function FSLootTracker:OnOptionsSave( wndHandler, wndControl, eMouseButton )
  --local label = self.state.windows.options:FindChild("RuleSetName"):FindChild("Text"):GetText()
  --local item = shallowcopy(self:GetBaseRuleSet())
  --item.label = label
  -- self.settings.options.autoSetMasterLootWhenLeading = self.state.windows.options:FindChild("AutoMLButton"):IsChecked()
  -- self.settings.options.autoEnableInDungeon = self.state.windows.options:FindChild("EnableInDungeon"):IsChecked()
  -- self.settings.options.autoEnableInRaid = self.state.windows.options:FindChild("EnableInRaid"):IsChecked()
  -- self.settings.options.autoDisableUponExitInstance = self.state.windows.options:FindChild("AutoDisableButton"):IsChecked()
  -- self.settings.options.masterLootRule  = self.state.windows.options:FindChild("PartyLootRuleSelection"):GetData()
  -- self.settings.options.masterLootQualityThreshold = self.state.windows.options:FindChild("ThresholdSelection"):GetData()
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
  self.state.windows.editConfigCosts = nil
  self.state.windows.editConfigTimeFormat = nil
  self.state.windows.editConfigTypes = nil
  self.state.windows.editConfigSources = nil
end

---------------------------------------------------------------------------------------------------
-- LootTrackerOptionsWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnConfigTabEnter( wndHandler, wndControl, x, y )
  wndHandler:SetBGColor(self.tabColors.hover)
  self.state.optionsHovered = true
end

function FSLootTracker:OnConfigTabExit( wndHandler, wndControl, x, y )
  self.state.optionsHovered = false
  self:RefreshUIOptions()
end

function FSLootTracker:OnConfigTabPress( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
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

function FSLootTracker:RefreshUIOptions()
  -- Set Tabs
  for i=1,3 do
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

  if self then
    self.state.windows.editConfigCosts:SetText(self.settings.options.defaultCost)
    -- initialize filter states
    for k,v in pairs(self.settings.options.qualityFilters) do
      self.state.windows.editConfigTypes:FindChild(self.tItemQuality[k].Name):SetCheck(v)
    end
    local button = self.state.windows.editConfigTimeFormat:FindChild(self.settings.options.timeFormat)
      button:SetCheck(true)
  end
end

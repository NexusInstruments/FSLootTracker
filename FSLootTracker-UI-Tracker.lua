require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Utils = Apollo.GetPackage("SimpleUtils").tPackage


function FSLootTracker:OnObjectiveTrackerLoaded(wndForm)
	if not wndForm or not wndForm:IsValid() then
		return
	end

  Apollo.RemoveEventHandler("ObjectiveTrackerLoaded", self)

	Apollo.RegisterEventHandler("ToggleShowTrackedLoot", "OnToggleShowTrackedLoot", self)

  self.state.windows.tracker = Apollo.LoadForm(self.xmlDoc, "LootObjectiveTracker", wndForm, self)
  self.state.windows.tracker:SetData("0") -- Necessary to ensure that it's ordered first in sorting
  self.state.windows.trackerObjectiveList = self.state.windows.tracker:FindChild("ObjectiveList")
	self:UpdateCountSum()

  -- Initialize Watch List
  local tTrackerData = {
    ["strAddon"] = "Watched Loot",
    ["bNoBtn"] = false,
    ["strDefaultSort"] = "0000FSLootTracker",
    ["strEventMouseLeft"] = "ToggleShowTrackedLoot",
    ["strText"] = tostring(self.state.watchCountSum),
    ["strIcon"] = "FSLootSprites:BigChest"
  }
  Event_FireGenericEvent("ObjectiveTracker_NewAddOn", tTrackerData)
  self:ResizeAllTracker()
end

function FSLootTracker:ResizeAllTracker()
  local nStartingHeight = self.state.windows.tracker:GetHeight()
	local bStartingShown = self.state.windows.tracker:IsShown()
	local bStartingCount = self.state.watchCountSum
  local listHeight = 0

	self:RebuildTrackedWatches()

	if self.settings.options.showTrackedLoot then
    local arChildren = self.state.windows.trackerObjectiveList:GetChildren()
    listHeight = 20 * #arChildren
  end
  listHeight = listHeight + 32

  self.state.windows.tracker:Show(self.settings.options.showTrackedLoot)

  local nLeft, nTop, nRight, nBottom = self.state.windows.tracker:GetAnchorOffsets()
  self.state.windows.tracker:SetAnchorOffsets(nLeft, nTop, nRight, nTop + listHeight)

  if nStartingHeight ~= self.state.windows.tracker:GetHeight() or self.settings.options.showTrackedLoot ~= bStartingShown or self.state.watchCountSum ~= bStartingCount then
  	local tData =
  	{
  		["strAddon"] = "Watched Loot",
  		["strText"] = tostring(self.state.watchCountSum),
  		["bChecked"] = self.settings.options.showTrackedLoot,
  	}

  	Event_FireGenericEvent("ObjectiveTracker_UpdateAddOn", tData)
  end
end

function FSLootTracker:OnToggleShowTrackedLoot()
	self.settings.options.showTrackedLoot = not self.settings.options.showTrackedLoot

	self:ResizeAllTracker()
end

function FSLootTracker:EmptyTrackedWatches()
	for idx,wnd in ipairs(self.state.windows.trackerObjectiveWindows) do
		wnd:Destroy()
	end
	self.state.windows.trackerObjectiveList:DestroyChildren()
	self.state.windows.trackerObjectiveWindows = {}
end


function FSLootTracker:RebuildTrackedWatches()
	self:UpdateCountSum()
	self:EmptyTrackedWatches()
	for id,name in pairs(self.settings.user.watched) do
		self:AddTrackedWatch(id)
	end
	self.state.windows.trackerObjectiveList:ArrangeChildrenVert()
	self:UpdateTrackedWatches()
end

function FSLootTracker:AddTrackedWatch(id)
  local wnd = Apollo.LoadForm(self.xmlDoc, "LootObjectiveListItem", self.state.windows.trackerObjectiveList, self)
	wnd:SetData(id)
	table.insert(self.state.windows.trackerObjectiveWindows, wnd)
end

function FSLootTracker:UpdateTrackedWatches()
	for idx,wnd in ipairs(self.state.windows.trackerObjectiveWindows) do
		id = wnd:GetData()
		name = self.settings.user.watched[id]
		count = self.state.listItems.watchedItemCounts[id]
		if not count then
			self.state.listItems.watchedItemCounts[id] = 0
			count = 0
		end
		local color = "ItemQuality_Inferior"
		if count > 0 then
			color = "ItemQuality_Good"
		end
		if name then
			wnd:FindChild("Title"):SetAML(name .. " : <T Font=\"CRB_InterfaceMedium\" TextColor=\"" .. color .. "\">" .. count .. "</T>")
		end
	end
end

function FSLootTracker:UpdateCountSum()
	local sum = 0
	for id,name in pairs(self.settings.user.watched) do
		local count = self.state.listItems.watchedItemCounts[id]
		if not count then
			count = 0
		end
		sum = sum + count
	end
	self.state.watchCountSum = sum
end

require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")

--	local tNewEntry =
--	{
--		recordType = karDataTypes.item,
--		itemID = itemInstance:GetItemId(),
--		count = itemCount,
--		cost = self.tConfig.defaultCost,
--		looter = self.tCache.LooterCache:GetAddValue(itemLooter),
--		quality = iQuality,
--		source =  self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
--		sourceType = karLootSources[itemSource],
--		rollType = itemNeed,
--		timeAdded = GameLib.GetGameTime(),
--		timeReported = GameLib.GetLocalTime(),
--		zone = self.tCache.ZoneCache:GetAddValue(GameLib.GetCurrentZoneMap().strName),
--		value = iValue
--	}

function FSLootTracker:ItemSorter(a, b)
	if self.sortSettings.UseItemData then 
		local itemA = self.tCache.ItemCache:GetValue(a.itemID)
		local itemB = self.tCache.ItemCache:GetValue(b.itemID)
		if self.sortSettings.Direction then
			return itemA[self.sortField] < itemB[self.sortField]
		else
			return itemA[self.sortField] > itemB[self.sortField]
		end	
	else
		if self.sortSettings.Direction then
			return a[self.sortSettings.Field] < b[self.sortSettings.Field]
		else
			return a[self.sortSettings.Field] > b[self.sortSettings.Field]
		end
	end
	return true
end

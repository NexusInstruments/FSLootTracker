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

local karCurrentSorting = 
{
	Column = 4,
	Order = 0
}

local karCurrentSortDisplay = 
{
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0
}

local karUnselectedLabels = {
	[1] = "Name",
	[2] = "Source",
	[3] = "Player",
	[4] = "Time"
}

local karSortSources = {
	Name = 1,
	Time = 2,
	Source = 3,
	Location = 4,
	Player = 5,
	Loot = 6,
	Time = 7,
	Value = 8
}

local karSortOrderLabels = {
	[1] = {
		[0] = {
			Label = "Name ▼",
			Source = karSortSources.Name,
			Direction = 0
		},
		[1] = {
			Label = "Name ▲",
			Source =  karSortSources.Name,
			Direction = 1
		},
		[2] = { 
			Label = "Type ▼", 
			Source =  karSortSources.Type,
			Direction = 0
		},
		[3] = { 
			Label = "Type ▲", 			
			Source =  karSortSources.Type,
			Direction = 1
		}
	},
	[2] = {
		[0] = {
			Label = "Source ▼",
			Source = karSortSources.Source,
			Direction = 0
		},
		[1] = {
			Label = "Source ▲",
			Source = karSortSources.Source,
			Direction = 1
		},
		[2] = { 
			Label = "Location ▼", 
			Source = karSortSources.Location,
			Direction = 0
		},
		[3] = { 
			Label = "Location ▲", 			
			Source = karSortSources.Location,
			Direction = 1
		}	
	},
	[3] = {
		[0] = {
			Label = "Player ▼",
			Source = karSortSources.Player,
			Direction = 0
		},
		[1] = {
			Label = "Player ▲",
			Source = karSortSources.Player,
			Direction = 1
		},
		[2] = { 
			Label = "Loot ▼", 
			Source = karSortSources.Loot,
			Direction = 0
		},
		[3] = { 
			Label = "Loot ▲", 			
			Source = karSortSources.Loot,
			Direction = 1
		}	
	},
	[4] = {
		[0] = {
			Label = "Time ▼",
			Source = karSortSources.Time,
			Direction = 0
		},
		[1] = {
			Label = "Time ▲",
			Source = karSortSources.Time,
			Direction = 1
		},
		[2] = { 
			Label = "Value ▼", 
			Source = karSortSources.Value,
			Direction = 0
		},
		[3] = { 
			Label = "Value ▲", 			
			Source = karSortSources.Value,
			Direction = 1
		}	
	}
}

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

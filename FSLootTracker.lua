------------------------------------------------------------------------------------------------
--	FSLootTracker ver. @project-version@
--	by Chronosis--Caretaker-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/chronosis/FSLootTracker
------------------------------------------------------------------------------------------------
-- TODO: Options Screen -- Add Persistent Session Option, Source Filter, Black List

require "Apollo" 
require "Window"
require "GameLib"

-----------------------------------------------------------------------------------------------
-- FSLootTracker Module Definition
-----------------------------------------------------------------------------------------------
local FSLootTracker = {} 
local FSLootTrackerInst

local Chronology = {}
local Cache = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")
local kfTimeBetweenItems = 2 -- Previously .3			-- delay between items; also determines clearing time (seconds)
local strPlayerName = ""								-- This shouldn't be changing

local karDataTypes = {
	clear = 0,
	item = 1,
	money = 2
}

local karLootSources = {
	["Normal"] = 0,
	["Rolled"] = 1,
	["Master"] = 2
}

local karLootSourcesNames = {
	[0] = "Normal",
	[1] = "Rolled",
	[2] = "Master"
}

local karItemQualityNames = {
	["Inferior"] = Item.CodeEnumItemQuality.Inferior,
	["Average"] = Item.CodeEnumItemQuality.Average,
	["Good"] = Item.CodeEnumItemQuality.Good,
	["Excellent"] = Item.CodeEnumItemQuality.Excellent, 
	["Superb"] = Item.CodeEnumItemQuality.Superb,
	["Legendary"] = Item.CodeEnumItemQuality.Legendary,
	["Artifact"] = Item.CodeEnumItemQuality.Artifact,  	
}

local karItemQuality = 
{
	[Item.CodeEnumItemQuality.Inferior] = 
  	{
		Name			= "Inferior",
		Color			= "ItemQuality_Inferior",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Silver",
		SquareSprite	= "BK3:UI_BK3_ItemQualityGrey",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGrey",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Silver",
	},
	[Item.CodeEnumItemQuality.Average] = 
	{
		Name			= "Average",
		Color		   	= "ItemQuality_Average",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_White",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_White",
		SquareSprite	= "BK3:UI_BK3_ItemQualityWhite",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetWhite",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_White",
 	},
	[Item.CodeEnumItemQuality.Good]	=
	{
		Name			= "Good",	
		Color		   	= "ItemQuality_Good",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Green",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Green",
		SquareSprite	= "BK3:UI_BK3_ItemQualityGreen",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGreen",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Green",
  	},
	[Item.CodeEnumItemQuality.Excellent] =   
	{
		Name			= "Excellent",	
		Color		   	= "ItemQuality_Excellent",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Blue",
		SquareSprite	= "BK3:UI_BK3_ItemQualityBlue",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetBlue",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Blue",
	},
	[Item.CodeEnumItemQuality.Superb] = 
  	{
		Name			= "Superb",
		Color		   	= "ItemQuality_Superb",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Purple",
		SquareSprite	= "BK3:UI_BK3_ItemQualityPurple",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPurple",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Purple",
 	},
	[Item.CodeEnumItemQuality.Legendary] = 
  	{
		Name			= "Legendary",	
		Color		   	= "ItemQuality_Legendary",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Orange",
		SquareSprite	= "BK3:UI_BK3_ItemQualityOrange",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetOrange",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Orange",
  	},
	[Item.CodeEnumItemQuality.Artifact] =   
  	{
		Name			= "Artifact",	
		Color		   	= "ItemQuality_Artifact",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Pink",
		SquareSprite	= "BK3:UI_BK3_ItemQualityMagenta",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPink",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Pink",
	},
}

local ktTimeStampFormats = {
	["12h"] = "{YYYY}-{MM}-{DD} {hh}:{mm}:{SS} {TT}",
	["24h"] = "{YYYY}-{MM}-{DD} {HH}:{mm}:{SS}",
}

local tDefaultOptions = {
	debug = false,
	persistSession = true,
	updateThreshold = 15,
	defaultCost = 0,
	timeFormat = "12h", 
	qualityFilters = {
		[Item.CodeEnumItemQuality.Inferior] = false,
		[Item.CodeEnumItemQuality.Average] = false,
		[Item.CodeEnumItemQuality.Good]	= false,
		[Item.CodeEnumItemQuality.Excellent] = false, 
		[Item.CodeEnumItemQuality.Superb] = false,
		[Item.CodeEnumItemQuality.Legendary] = false,
		[Item.CodeEnumItemQuality.Artifact] = false
	},
	sourceFilters = {
		[karLootSources.Normal] = false,
		[karLootSources.Rolled] = false,
		[karLootSources.Master] = false,	
	}
}

local strDefaultGuildInfoText = 
	"=== FSLootTracker ===\n\n" .. 
	"_.,-*~'`^`'~*-,._\n\n" ..
	"Developed By:\n" ..
	"Chronosis--Caretaker-US\n" ..
	"Copyright (c) 2014\n\n" ..
	"_.,-*~'`^`'~*-,._\n\n" ..
	"<FOR SCIENCE>\n" ..
	"Dominion / PvE\n" .. 
	"Caretaker-US\n\n" ..
	"http://forscienceguild.org"
	

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function FSLootTracker:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self 

	-- initialize variables here
	o.fFirstLoot = nil			-- first time Loot occurred this session
	o.fLastLoot = nil			-- last time Loot occurred this session
	o.fLastTimeAdded = 0		-- last time the stack queue was updates
	o.curMoneyCount = 0			-- current count of money items logged

	o.tConfig = shallowcopy(tDefaultOptions)  -- defaults

	o.tStats = {
		totalMoney = 0,
		perHourMoney = 0,
		avgMoney = 0,
		junkValue = 0,
		largestDrop = 0
	}

	o.tState = {
		isOpen = false,			-- current window state   
		lastSource = "Unknown",	-- last loot source
		updateCount = 0
	}

	o.tCache = {
		SourceCache = {},
		ZoneCache = {},
		LooterCache = {},
		ItemCache = {}
	}
	
	o.tQueuedEntryData = {}		-- keep track of all recently looted items to process

	o.tMoneys = {}				-- keep track of all the looted money
	o.tItems = {} 				-- keep track of all the looted items
	o.tItemsEncoded = {} 		-- keep track of all the looted items
	
	o.tItemWindows = {}			-- keep track of all the looted item windows
	o.tMoneyWindows = {}		-- keep track of all the looted money windows
		
	o.wndSelectedListItem = nil	-- keep track of which list item is currently selected
	o.wndEditWindow = nil
	o.wndInfoWindow = nil
	o.wndLastItemControl = nil

	return o
end

function FSLootTracker:Debug( message )
	if self.tConfig then
		if self.tConfig.debug then
			Print(message)
		end
	end
end

function FSLootTracker:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
	Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

---------------------------------------------------------------------------------------------------
-- Loot Utility Cache Function
---------------------------------------------------------------------------------------------------
function FSLootTracker:CacheItem(itemInstance)
	local v = 0
	if itemInstance:GetSellPrice() ~= nil then
		v = itemInstance:GetSellPrice():GetAmount()
	end
	local itemID = itemInstance:GetItemId()
	if not self.tCache.ItemCache:HasKey(itemID) then
		local item = {
			quality = itemInstance:GetItemQuality() or Item.CodeEnumItemQuality.Average,
			name = itemInstance:GetName(),
			iLvl = itemInstance:GetItemPower(),
			icon = itemInstance:GetIcon(),	
			type = itemInstance:GetItemTypeName(),
			value = v
		}
		self.tCache.ItemCache:AddKeyValue(itemID, item)
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedMoney
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedMoney(moneyInstance)
	local tNewEntry =
	{
		recordType = karDataTypes.money,
		moneyAmount = moneyInstance:GetAmount(),
		moneyType = moneyInstance:GetMoneyType(),
		source = self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
		timeAdded = GameLib.GetGameTime(),
		timeReported = GameLib.GetLocalTime(),
		zone = self.tCache.ZoneCache:GetAddValue(GameLib.GetCurrentZoneMap().strName)
	}
	table.insert(self.tQueuedEntryData, tNewEntry)
	self.fLastTimeAdded = GameLib.GetGameTime()		
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedItem(itemInstance, itemCount)
	--queue recently added items
	self:Debug("Item Looted: " .. itemInstance:GetName())

	self:CacheItem(itemInstance)
	local tNewEntry =
	{
		recordType = karDataTypes.item,
		itemID = itemInstance:GetItemId(),
		count = itemCount,
		cost = self.tConfig.defaultCost,
		looter = self.tCache.LooterCache:GetAddValue(strPlayerName),
		source =  self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
		sourceType = karLootSources["Normal"],
		timeAdded = GameLib.GetGameTime(),
		timeReported = GameLib.GetLocalTime(),
		zone = self.tCache.ZoneCache:GetAddValue(GameLib.GetCurrentZoneMap().strName)
	}
	table.insert(self.tQueuedEntryData, tNewEntry)
	self.fLastTimeAdded = GameLib.GetGameTime()	
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootRollWon -- (For Winning Loot Roll) -- Hooked from NeedVsGreed
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootRollWon(itemLooted, strWinner, bNeed)
	self:Debug("Item Won: " .. itemLooted:GetName() .. " by " .. strWinner)
	if strWinner ~= GameLib.GetPlayerUnit():GetName() then
		self:CacheItem(itemLooted)
		local tNewEntry =
		{
			recordType = karDataTypes.item,
			itemID = itemLooted:GetItemId(),
			count = 1,
			cost = self.tConfig.defaultCost,
			looter = self.tCache.LooterCache:GetAddValue(strWinner),
			source = self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
			sourceType = karLootSources["Rolled"],		
			timeAdded = GameLib.GetGameTime(),
			timeReported = GameLib.GetLocalTime(),
			zone = self.tCache.ZoneCache:GetAddValue(GameLib.GetCurrentZoneMap().strName)
		}
		table.insert(self.tQueuedEntryData, tNewEntry)
		self.fLastTimeAdded = GameLib.GetGameTime()	
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootAssigned (MasterLooting)
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootAssigned(itemInstance, strLooter)
	self:Debug("Item Assigned: " .. itemInstance:GetName() .. " to " .. strLooter)
	-- Only Track this event if the looter isn't the player running the addon 
	-- Since this will be caught by the onLootItem event automatically
	if strLooter ~= GameLib.GetPlayerUnit():GetName() then
		self:CacheItem(itemInstance)
		local tNewEntry =
		{
			recordType = karDataTypes.item,
			itemID = itemInstance:GetItemId(),
			count = 1,
			cost = self.tConfig.defaultCost,
			looter = self.tCache.LooterCache:GetAddValue(strLooter),
			source =  self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
			sourceType = karLootSources["Master"],		
			timeAdded = GameLib.GetGameTime(),
			timeReported = GameLib.GetLocalTime(),
			zone = self.tCache.ZoneCache:GetAddValue(GameLib.GetCurrentZoneMap().strName)
		}
		table.insert(self.tQueuedEntryData, tNewEntry)
		self.fLastTimeAdded = GameLib.GetGameTime()	
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootStackUpdate
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootStackUpdate(strVar, nValue)
	local fCurrTime = GameLib.GetGameTime()

	-- add a new item if its time
	if #self.tQueuedEntryData > 0 then
		if fCurrTime - self.fLastTimeAdded >= kfTimeBetweenItems then
			self:AddQueuedItem()
		end
		if self.wndProcessingIndicator then
			self.wndProcessingIndicator:Show(true)
		end
	else
		if self.wndProcessingIndicator then
			self.wndProcessingIndicator:Show(false)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker AddQueuedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:AddQueuedItem()
	-- gather our entryData we need
	local tQueuedData = self.tQueuedEntryData[1]
	table.remove(self.tQueuedEntryData, 1)
	self:Debug("Item Queued")
	--Utils:printProps(tQueuedData)
	
	if tQueuedData == nil then
		self:Debug("Item is null")
		return
	end

	--if tQueuedData.count == 0 then
	--	self:Debug("Item has no count")
	--	return
	--end
	
	local now = GameLib.GetGameTime()
	if self.fFirstLoot == nil then
		self.fFirstLoot = now
	end
	self.fLastLoot = now
	local fCurrTime = now

	-- push this item on the end of the table
	if tQueuedData.recordType == karDataTypes.item then
		self:Debug("Item was added")
		local iQuality = tQueuedData.quality
		-- Only add items of quality not being filtered
		if self.tConfig.qualityFilters[iQuality] ~= true then
			table.insert(self.tItems, tQueuedData)
		end
		-- Track Junk value
		if iQuality == Item.CodeEnumItemQuality.Inferior then		
			self.tStats.junkValue = self.tStats.junkValue + tQueuedData.value
			self:RefreshStats()
		end
	elseif tQueuedData.recordType == karDataTypes.money then
		self:Debug("Money was added")
		-- Add to total earn if actual money
		table.insert(self.tMoneys, tQueuedData)
		if tQueuedData.moneyType == Money.CodeEnumCurrencyType.Credits then
			self:UpdateStats(tQueuedData.moneyAmount)
		end		
	else
		self:Debug("Unknown type")	
	end
	self.tState.updateCount = self.tState.updateCount + 1
	-- Only Update the tracked loot once the queue is empty 
	-- or when we've reach the update threshold
	-- This code is here for performance reasons
	if #self.tQueuedEntryData == 0 or self.tState.updateCount > self.tConfig.updateThreshold then
		self:RebuildLists()		
	end
	
	self.fLastTimeAdded = fCurrTime
end


-----------------------------------------------------------------------------------------------
-- FSLootTracker AddQueuedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "FSLootTracker", {"Generic_ToggleLoot", "", "FSLootSprites:TransChestSmall"})
	--self:UpdateInterfaceMenuAlerts()
	self:RebuildLists()
	self:RefreshStats()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLoad
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLoad()
	-- Load custom sprite sheet
	Apollo.LoadSprites("FSLootSprites.xml")
	
	-- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("FSLootTracker.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	Chronology = Apollo.GetPackage("Chronology-1.0").tPackage
	Cache = Apollo.GetPackage("SimpleCache-1.0").tPackage

	for key, val in pairs(self.tCache) do
		self.tCache[key] = Cache:new()
	end
	
	strPlayerName = GameLib.GetPlayerUnit():GetName()
	-- Library Embeds
	Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
	--Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
	
	-- initialize loot event
	Apollo.RegisterEventHandler("Generic_ToggleLoot", "OnLootTrackerOn", self)
	Apollo.RegisterEventHandler("LootedItem", "OnLootedItem", self)
	Apollo.RegisterEventHandler("LootedMoney", "OnLootedMoney", self)
	Apollo.RegisterEventHandler("LootAssigned", "OnLootAssigned", self)
	Apollo.RegisterEventHandler("LootRollWon", "OnLootRollWon", self)
	Apollo.RegisterEventHandler("CombatLogLoot", "OnCombatLogLoot", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)

	Apollo.RegisterTimerHandler("LootStackUpdate", "OnLootStackUpdate", self)
	Apollo.RegisterTimerHandler("KillSourceTimerUpdate", "OnKillSourceTimer", self)
	Apollo.CreateTimer("LootStackUpdate", 0.1, true)
	Apollo.CreateTimer("KillSourceTimerUpdate", 600, false)

	--Apollo.RegisterEventHandler("BuybackItemsUpdated", "OnBuybackItemsUpdated", self) -- Player bought back an item
	Apollo.RegisterEventHandler("CloseVendorWindow", "OnCloseVendorWindow", self) -- Player closed the vendor window
	Apollo.RegisterEventHandler("InvokeVendorWindow", "OnInvokeVendorWindow", self) -- Player opened the ventor window
	Apollo.RegisterEventHandler("CombatLogDamage", "OnCombatLogDamage", self) -- Combat Log for kills
	Apollo.RegisterEventHandler("SalvageItemRequested", "OnSalvageItem", self)
	Apollo.RegisterEventHandler("QuestStateChanged", "OnQuestStateChange", self)

	-- Hooks
    --self.addonNeedVsGreed = Apollo.GetAddon("NeedVsGreed")
    --if self.addonNeedVsGreed ~= nil then
    --    self:RawHook(self.addonNeedVsGreed , "OnLootRollWon")
    --end
end

function FSLootTracker:OnInvokeVendorWindow()
	self.tState.lastSource = "Vendor"
end

function FSLootTracker:OnCloseVendorWindow()
	self.tState.lastSource = "Unknown"
end

function FSLootTracker:OnSalvageItem()
	self.tState.lastSource = "Salvage/ItemBox"
end

function FSLootTracker:OnQuestStateChange(queUpdated, eState)
	if queUpdated ~= nil then
		local reward, money = queUpdated:GetRewardData()
		if eState == Quest.QuestState_Completed then
			if reward ~= nil then
				self.tState.lastSource = "Quest"
			end
		end
	end
end

-- CombatDamageLog is a good way to monitor kills
function FSLootTracker:OnCombatLogDamage(tEventArgs)
	-- something has been killed
	if tEventArgs.bTargetKilled then
		local unit = tEventArgs.unitTarget
		if not unit:IsACharacter() then
			-- set loot target and time stamp
			self.tState.lastSource = unit:GetName()
			-- Start Loot Timer to reset
			Apollo.StartTimer("KillSourceTimerUpdate")
		end
	end
end

function FSLootTracker:OnKillSourceTimer()
	self.tState.lastSource = "Unknown"
	Apollo.StartTimer("KillSourceTimerUpdate")
end


-----------------------------------------------------------------------------------------------
-- FSLootTracker OnDocLoaded
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "LootTrackerForm", nil, self)
		--self.wndLootOpts = Apollo.LoadForm(self.xmlDoc, "OptionsContainer", wndParent, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
		-- item list
		self.wndLootOpts = self.wndMain:FindChild("OptionsContainer")
		self.wndItemList = self.wndMain:FindChild("ItemList")
		self.wndMoneyWindow = self.wndMain:FindChild("MoneyWindow")
		self.wndMoneyList = self.wndMoneyWindow:FindChild("MoneyList")
		self.wndTotalCash = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("CashDisplay")
		self.wndPerHourCash = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("CashDisplay")
		self.wndAvgCash = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("CashDisplay")
		self.wndJunkCash = self.wndMoneyWindow:FindChild("JunkValue"):FindChild("CashDisplay")	
		self.wndMostCash = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("CashDisplay")

		self.editConfigCosts = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureCosts"):FindChild("EditBox")
		self.editConfigTypes = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureTypes"):FindChild("QualityBtns")		
		self.editConfigTimeFormat = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureTimeFormat")
		
		self.wndProcessingIndicator = self.wndMain:FindChild("ProcessingIndicator")
		self.wndSessions = self.wndMain:FindChild("SessionsForm")
		
		self.wndMain:Show(false, true)
		self.wndSessions:Show(false)
		self.wndLootOpts:Show(false)
		self.wndProcessingIndicator:Show(false)

		self.wndItemList:Show(true)
		self.wndMoneyWindow:Show(true)
		self.wndMoneyWindow:Show(false)
		self.wndMain:FindChild("HeaderButtons"):FindChild("SplashItemsBtn"):SetCheck(true)
		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("loot", "OnLootTrackerOn", self)

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/loot"
function FSLootTracker:OnLootTrackerOn()
	if self.isOpen == true then
		self.tState.isOpen = false
		self.wndMain:Close() -- hide the window
	else
		self.tState.isOpen = true 
		self.wndMain:Invoke() -- show the window
	end
		
	-- populate the item list
	self:RefreshListDisplays()
end

-----------------------------------------------------------------------------------------------
-- LootTrackerForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function FSLootTracker:OnOK( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close() -- hide the window
	self.tState.isOpen = false
end

-- when the Cancel button is clicked
function FSLootTracker:OnCancel( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close() -- hide the window
	self.tState.isOpen = false
end

-- when the Clear button is clicked
function FSLootTracker:OnClear( wndHandler, wndControl, eMouseButton )
	if not FSLootTrackerInst.wndDeleteConfirm then
		--Show Confirm Window
		FSLootTrackerInst.wndDeleteConfirm = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ConfirmDeleteWindow", nil, FSLootTrackerInst)
		FSLootTrackerInst.wndDeleteConfirm:Show(true)
	end
end

-- when a list item is selected
function FSLootTracker:OnListItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	-- make sure the wndControl is valid
	if wndHandler ~= wndControl then
		return
	end

	if eMouseButton == 0 and bDoubleClick then -- Double Left Click
		FSLootTrackerInst:CreateEditWindow( wndHandler )
	end
	if eMouseButton == 1 then -- Right Clicked
		-- TODO: Open Context Dialog
	end	
end

-- when the window is closed
function FSLootTracker:OnWindowClosed( wndHandler, wndControl )
	self.tState.isOpen = false
end

function FSLootTracker:OnWindowMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	local l,t,r,b = self.wndMain:GetAnchorOffsets()
end

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


function FSLootTracker:OnOptionsToggle( wndHandler, wndControl, eMouseButton )
	local state = self.wndMain:FindChild("ConfigButton"):IsChecked()
	self.wndLootOpts:FindChild("OptionsContainer"):Show(state)
	if state then 
		self.RefreshUIOptions()
	else
		self.tConfig.defaultCost = self.editConfigCosts:GetText()
	end
end

function FSLootTracker:OnExportData( wndHandler, wndControl, eMouseButton )
	if not FSLootTrackerInst.wndExport then
		FSLootTrackerInst.wndExport = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ExportWindow", nil, FSLootTrackerInst)
		-- TODO: EXPORT DATA HERE AND INSERT IT INTO THE FORM
		local exportStr = self:JSONEncodePretty(FSLootTrackerInst.tItemsExport)
		FSLootTrackerInst.wndExport:FindChild("ExportString"):SetText(exportStr)
		FSLootTrackerInst.wndExport:Show(true)
	end
end

function FSLootTracker:OnQualityBtnChecked( wndHandler, wndControl, eMouseButton )
	local name = wndControl:GetName()
	local qualEnum = karItemQualityNames[name]
	FSLootTrackerInst.tConfig.qualityFilters[qualEnum] = true
end

function FSLootTracker:OnQualityBtnUnchecked( wndHandler, wndControl, eMouseButton )
	local name = wndControl:GetName()
	local qualEnum = karItemQualityNames[name]
	FSLootTrackerInst.tConfig.qualityFilters[karItemQualityNames[name]] = false
end

function FSLootTracker:OnSessionsFlyoutChecked( wndHandler, wndControl, eMouseButton )
	FSLootTrackerInst.wndSessions:Show(true)
end

function FSLootTracker:OnSessionsFlyoutUnchecked( wndHandler, wndControl, eMouseButton )
	FSLootTrackerInst.wndSessions:Show(false)
end

function FSLootTracker:OnInfoButton( wndHandler, wndControl, eMouseButton )
	if not FSLootTrackerInst.wndInfoWindow then
		FSLootTrackerInst.wndInfoWindow = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "AboutWindow", nil, FSLootTrackerInst)		
		local wndLeft = FSLootTrackerInst.wndInfoWindow:FindChild("Left"):FindChild("Sprite")
		local wndRight = FSLootTrackerInst.wndInfoWindow:FindChild("Right"):FindChild("Sprite")
		wndLeft:SetSprite("FSLootSprites:FSPoster")
		wndRight:SetText(strDefaultGuildInfoText)
		FSLootTrackerInst.wndInfoWindow:Show(true)
	end
end

function FSLootTracker:OnInfoClose( wndHandler, wndControl, eMouseButton )
	if FSLootTrackerInst.wndInfoWindow then
		FSLootTrackerInst.wndInfoWindow:Show(false)
		FSLootTrackerInst.wndInfoWindow:Destroy()
		FSLootTrackerInst.wndInfoWindow = nil
	end
end

function FSLootTracker:OnInfoWindowClosed( wndHandler, wndControl )
	if FSLootTrackerInst.wndInfoWindow then
		FSLootTrackerInst.wndInfoWindow:Show(false)
		FSLootTrackerInst.wndInfoWindow:Destroy()
		FSLootTrackerInst.wndInfoWindow = nil
	end
end

function FSLootTracker:OnTimeFormatCheck( wndHandler, wndControl, eMouseButton )
	FSLootTrackerInst.tConfig.timeFormat = wndControl:GetText()
end

function FSLootTracker:OnAddItemButton( wndHandler, wndControl, eMouseButton )
	if not FSLootTrackerInst.wndAddItem then
		FSLootTrackerInst.wndAddItem = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ItemAddWindow", nil, FSLootTrackerInst)		
		FSLootTrackerInst.wndAddItem:Show(true)
	end
end

function FSLootTracker:OnRecordingStopButton( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnRecordingStartButton( wndHandler, wndControl, eMouseButton )
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker ClearLists
-----------------------------------------------------------------------------------------------
function FSLootTracker:EmptyLists()
	if self.wndLastItemControl then
		self.wndLastItemControl:Show(false)
		self.wndLastItemControl = nil	
	end
	for idx,wnd in ipairs(self.tItemWindows) do
		wnd:Destroy()
	end
	for idx,wnd in ipairs(self.tMoneyWindows) do
		wnd:Destroy()
	end

	self.wndItemList:DestroyChildren()
	self.wndMoneyList:DestroyChildren()
	self.tItemWindows = {}
	self.tMoneyWindows = {}
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker RebuildLists
-----------------------------------------------------------------------------------------------
function FSLootTracker:RebuildLists()
	self:EmptyLists()
	for idx,item in ipairs(self.tItems) do
		self:AddItem(idx, item)
	end
	for idx,money in ipairs(self.tMoneys) do
		self:AddMoney(idx, money)
	end 
	self.tState.updateCount = 0
	self:RebuildExportList()
	self:RefreshListDisplays()
	self:RefreshStats()
end 

-- clear the item list
function FSLootTracker:DestroyItemList()
	self.tItems = {}
	for idx,wnd in ipairs(self.tMoneyWindows) do
		wnd:Destroy()
		table.remove(self.tMoneyWindows, 1)
	end

	self.wndSelectedListItem = nil
end

-- rebuild list used to export the data
function FSLootTracker:RebuildExportList()
	self.tItemsExport = {}
	for idx, itemInstance in ipairs(self.tItems) do
		local item = Item.GetDataFromId(tonumber(itemInstance.itemID))
		
		local tNewEntry =
		{
			itemID = itemInstance.itemID,
			itemName = itemInstance.name,
			itemQuality = itemInstance.quality,
			itemILvl = itemInstance.iLvl,
			itemType = itemInstance.type,
			count = itemInstance.count,
			looter = self.tCache.LooterCache:GetKeyFromValue(itemInstance.looter),
			cost = itemInstance.cost,
			gameTimeAdded = itemInstance.timeAdded,
			timeReported = itemInstance.timeReported
		}
		table.insert(self.tItemsExport, tNewEntry)			
	end
end

-----------------------------------------------------------------------------------------------
-- MoneyList Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:UpdateStats(addMoney)
	self:Debug("Adding Money: " .. addMoney) 
	-- Calculate Total Money
	self.tStats.totalMoney = self.tStats.totalMoney + addMoney
	
	-- Calculate Money Per Hour
	if self.fFirstLoot ~= nil then
		local timediff = os.difftime(self.fLastLoot, self.fFirstLoot)
		if timediff > 0 then
			self.tStats.perHourMoney = (self.tStats.totalMoney * 3600) / timediff 
		else
			self.tStats.perHourMoney = addMoney
		end
	end
	
	-- Calculate Average Money
	local nMoneyLoots = table.getn(self.tMoneys)
	if nMoneyLoots > 0 then
		self.tStats.avgMoney = self.tStats.totalMoney / nMoneyLoots
	else
		self.tStats.avgMoney = addMoney
	end
	
	-- Calculate Largest Loot
	if addMoney > self.tStats.largestDrop then
		self.tStats.largestDrop = addMoney
	end

	self:RefreshStats()
end

function FSLootTracker:RefreshStats()
	self.wndTotalCash:SetAmount(self.tStats.totalMoney)
	self.wndPerHourCash:SetAmount(self.tStats.perHourMoney)
	self.wndAvgCash:SetAmount(self.tStats.avgMoney)
	self.wndJunkCash:SetAmount(self.tStats.junkValue)
	self.wndMostCash:SetAmount(self.tStats.largestDrop)
end

-- clear the item list
function FSLootTracker:DestroyMoneyList()
	-- clear the list money array
	self.tMoneys = {}
	for idx,wnd in ipairs(self.tItemWindows) do
		wnd:Destroy()
		table.remove(self.tItemWindows, 1)
	end
	self.wndSelectedListItem = nil
end

-- clear the cache
function FSLootTracker:ClearCache()
	for key, val in pairs(self.tCache) do
		self.tCache[key]:Clear()
	end
end

-----------------------------------------------------------------------------------------------
-- ItemList Functions
-----------------------------------------------------------------------------------------------
-- clear the item list
function FSLootTracker:ClearLists()
	self:DestroyItemList()
	self:DestroyMoneyList()
	self:ClearCache()
	for key,val in pairs(self.tStats) do
		self.tStats[key] = 0
	end
	self:RebuildLists()
	self:RefreshStats()
end


function FSLootTracker:RefreshListDisplays()
	self.wndItemList:ArrangeChildrenVert()
	self.wndMoneyList:ArrangeChildrenVert()
end

-----------------------------------------------------------------------------------------------
-- AddItem Functions
-----------------------------------------------------------------------------------------------
-- add an item into the item list
function FSLootTracker:AddItem(idx, item) --, count, looter, time, reportedTime)
	self:Debug("Item Add Called for (" .. item.itemID .. ") x" .. item.count)
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndItemList, self)
	wndFlyoutBtn = wnd:FindChild("ContextButton")
	wndFlyoutBtn:SetCheck(false)
	wndFlyoutBtn:FindChild("ContextFlyout"):Show(false)

	local itemData = self.tCache.ItemCache:GetValue(item.itemID)
	--table.insert(self.tItems, wnd)
	local iQuality = itemData.quality
	-- give it a piece of data to refer to 
	local wndItemText = wnd:FindChild("ItemText")
	if wndItemText then -- make sure the text wnd exist
		wndItemText:SetText(itemData.name)
		wndItemText:SetTextColor(karItemQuality[iQuality].Color)
	end
	-- give it a piece of data to refer to 
	local wndItemType = wnd:FindChild("ItemType")
	if wndItemType then -- make sure the text wnd exist
		wndItemType:SetText(itemData.type)
		--wndItemType:SetTextColor(kcrNormalText)
	end
	-- give it a piece of data to refer to 
	local wndItemPlayer = wnd:FindChild("ItemPlayer")
	if wndItemPlayer then -- make sure the text wnd exist
		wndItemPlayer:SetText(self.tCache.LooterCache:GetKeyFromValue(item.looter))
		--wndItemPlayer:SetTextColor(kcrNormalText)
	end	

	-- give it a piece of data to refer to 
	local wndItemTimestamp = wnd:FindChild("ItemTimestamp")
	if wndItemTimestamp then -- make sure the text wnd exist
		local strFormat = ktTimeStampFormats[self.tConfig.timeFormat]
		wndItemTimestamp:SetText(Chronology:GetFormattedDateTime(item.timeReported, strFormat))
		--wndItemTimestamp:SetText(time)
		--wndItemTimestamp:SetTextColor(kcrNormalText)
	end

	-- give it a piece of data to refer to 
	local wndItemSource = wnd:FindChild("ItemSource")
	if wndItemSource then -- make sure the text wnd exist
		wndItemSource:SetText(self.tCache.SourceCache:GetKeyFromValue(item.source))
		--wndItemSource:SetTextColor(kcrNormalText)
	end

	-- give it a piece of data to refer to 
	local wndItemZone = wnd:FindChild("ItemZone")
	if wndItemZone then -- make sure the text wnd exist
		wndItemZone:SetText(self.tCache.ZoneCache:GetKeyFromValue(item.zone))
	end
	
	-- give it a piece of data to refer to 
	local wndItemSourceType = wnd:FindChild("ItemSourceType")
	if wndItemSourceType then -- make sure the text wnd exist
		wndItemSourceType:SetText(karLootSourcesNames[item.sourceType])
	end

	-- give it a piece of data to refer to 
	local wndItemBorder = wnd:FindChild("ItemBorder")
	if wndItemBorder then -- make sure the text wnd exist
		local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
		if wndItemIcon then 
			wndItemIcon:SetSprite(itemData.icon)
			wndItemIcon:SetData(idx)
		end
		wndItemBorder:SetSprite(karItemQuality[iQuality].SquareSprite)
		wndItemBorder:SetText("x" .. item.count .. " ")
	end

	wnd:SetData(idx)
	-- keep track of the window item created
	table.insert(self.tItemWindows, wnd)
	--self.tItemWindows[self.curItemCount] = wnd
	--self:Debug("List Item created for item " .. wnd:GetData() .. " : " .. self.curItemCount)
end

-----------------------------------------------------------------------------------------------
-- AddMoney Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:AddMoney(idx, money)
	self:Debug("Money Add Called for " .. money.moneyAmount)
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListMoney", self.wndMoneyList, self)

	local wndMoneyText = wnd:FindChild("MoneyText")
	if wndMoneyText then -- make sure the text wnd exist
		local wndCashDisplay = wndMoneyText:FindChild("CashDisplay")
		if wndCashDisplay then 
			wndCashDisplay:SetAmount(money.moneyAmount)
			wndCashDisplay:SetMoneySystem(money.moneyType)
		end
	end

	local wndMoneyTimestamp = wnd:FindChild("MoneyTimestamp")
	if wndMoneyTimestamp then 
		local strFormat = ktTimeStampFormats[self.tConfig.timeFormat]
		wndMoneyTimestamp:SetText(Chronology:GetFormattedDateTime(money.timeReported, strFormat))
		wndMoneyTimestamp:SetTextColor(kcrNormalText)
	end

	wnd:SetData(idx)
	--self:Debug("List Money created for item " .. wnd:GetData() .. " : " .. self.curMoneyCount)
		
	-- keep track of the window item created
	table.insert(self.tMoneyWindows, wnd)
	--self.tMoneyWindows[self.curMoneyCount] = wnd
end
---------------------------------------------------------------------------------------------------
-- ListItem Functions
---------------------------------------------------------------------------------------------------

function FSLootTracker:CreateEditWindow( wndHandler )
-- Get Parent List item and associated item data. 
	local idx = wndHandler:GetData()
	local data = FSLootTrackerInst.tItems[idx]
	-- Load the item edit panel
	if FSLootTrackerInst.wndEditWindow then
		FSLootTrackerInst.wndEditWindow:Destroy()
	end
	FSLootTrackerInst.wndEditWindow = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ItemEditWindow", nil, FSLootTrackerInst)
	FSLootTrackerInst.wndEditWindow:Show(true)
	
	local itemData = self.tCache.ItemCache:GetValue(data.itemID)
	local iQuality = itemData.quality
	-- give it a piece of data to refer to 
	local wndItemILvl = FSLootTrackerInst.wndEditWindow:FindChild("ItemILvl")
	if wndItemILvl then -- make sure the text wnd exist
		wndItemILvl:SetText("iLvl: " .. itemData.iLvl)
	end
	
	-- give it a piece of data to refer to 
	local wndItemPower = FSLootTrackerInst.wndEditWindow:FindChild("ItemNumber")
	if wndItemPower then -- make sure the text wnd exist
		wndItemPower:SetText("Item #: " .. data.itemID)
	end
	
	-- give it a piece of data to refer to 
	local wndItemText = FSLootTrackerInst.wndEditWindow:FindChild("ItemText")
	if wndItemText then -- make sure the text wnd exist
		wndItemText:SetText(itemData.name)
		wndItemText:SetTextColor(karItemQuality[iQuality].Color)
	end
	
	-- give it a piece of data to refer to 
	local wndItemType = FSLootTrackerInst.wndEditWindow:FindChild("ItemType")
	if wndItemType then -- make sure the text wnd exist
		wndItemType:SetText(itemData.type)
	end
	
	-- give it a piece of data to refer to 
	local wndItemCount = FSLootTrackerInst.wndEditWindow:FindChild("ItemCount")
	if wndItemCount then -- make sure the text wnd exist
		wndItemCount:SetText(data.count)
	end
	
	-- give it a piece of data to refer to 
	local wndItemCost = FSLootTrackerInst.wndEditWindow:FindChild("ItemCost")
	if wndItemCost then -- make sure the text wnd exist
		wndItemCost:SetText(data.cost)
	end
	
	-- give it a piece of data to refer to 
	local wndItemPlayer = FSLootTrackerInst.wndEditWindow:FindChild("ItemLooter")
	if wndItemPlayer then -- make sure the text wnd exist
		local strLooter = self.tCache.LooterCache:GetKeyFromValue(data.looter)
		if strLooter then 
			wndItemPlayer:SetText(strLooter)
		end
	end	
	
	-- give it a piece of data to refer to 
	local wndItemTimestamp = FSLootTrackerInst.wndEditWindow:FindChild("ItemTimestamp")
	if wndItemTimestamp then -- make sure the text wnd exist
		local strFormat = ktTimeStampFormats[self.tConfig.timeFormat]
		wndItemTimestamp:SetText("Looted at " .. Chronology:GetFormattedDateTime(data.timeReported, strFormat))
		wndItemTimestamp:SetTextColor(kcrNormalText)
	end
	
	-- give it a piece of data to refer to 
	local wndItemBorder = FSLootTrackerInst.wndEditWindow:FindChild("ItemBorder")
	if wndItemBorder then -- make sure the text wnd exist
		wndItemBorder:SetSprite(karItemQuality[iQuality].SquareSprite)
		local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
		if wndItemIcon then 
			wndItemIcon:SetSprite(itemData.icon)
			wndItemIcon:SetData(idx)
		end
	end

	FSLootTrackerInst.wndEditWindow:SetData(idx)
end

function FSLootTracker:OnGenerateTooltip( wndHandler, wndControl, eToolTipType, x, y )
	--if wndControl ~= wndHandler then return end
	wndControl:SetTooltipDoc(nil)
	local itemID = FSLootTrackerInst.tItems[wndHandler:GetData()].itemID
	local item = Item.GetDataFromId(tonumber(itemID))
	local itemEquipped = item:GetEquippedItemForItemType()
	Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
	-- Tooltip.GetItemTooltipForm(self, wndControl, itemEquipped, {bPrimary = false, bSelling = false, itemCompare = item})
end

function FSLootTracker:OnToggleItemFlyout( wndHandler, wndControl, eMouseButton )
	-- Close the last context window if you've opened a different one.
	local wndLastItemControl = FSLootTrackerInst.wndLastItemControl
	
	if wndLastItemControl and wndLastItemControl ~= nil then
		if wndControl ~= wndLastItemControl  then
			wndLastItemControl:SetCheck(false)
			wndLastItemControl:FindChild("ContextFlyout"):Show(false)
		end
	end
	wndControl:FindChild("ContextFlyout"):Show(wndControl:IsChecked())
    FSLootTrackerInst.wndLastItemControl = wndControl
end

function FSLootTracker:OnEditBtnClicked( wndHandler, wndControl, eMouseButton )
	local wndLastItemControl = FSLootTrackerInst.wndLastItemControl
	
	if wndLastItemControl and wndLastItemControl ~= nil then
		wndLastItemControl:SetCheck(false)
		wndLastItemControl:FindChild("ContextFlyout"):Show(false)
	end
	
	-- Get Parent List item and associated item data. 
	FSLootTrackerInst:CreateEditWindow( wndHandler:GetParent():GetParent():GetParent():GetParent() )
end

function FSLootTracker:OnDeleteBtnClicked( wndHandler, wndControl, eMouseButton )
	-- Get Parent List item and associated item data. 
	local index = wndHandler:GetParent():GetParent():GetParent():GetParent():GetData()
	wndHandler:Show(false)
	table.remove(FSLootTrackerInst.tItems, index)
	FSLootTrackerInst.wndLastItemControl = nil
	FSLootTrackerInst:RebuildLists()
end

function FSLootTracker:OnLinkItem( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	-- Get Parent List item and associated item data. 
	local itemID = FSLootTrackerInst.tItems[wndHandler:GetData()].itemID
	local oItem = Item.GetDataFromId(tonumber(itemID))
	-- Shift Right click
	if Apollo.IsShiftKeyDown() and eMouseButton == 1 then
		Event_FireGenericEvent("ItemLink", oItem)
	end
end

---------------------------------------------------------------------------------------------------
-- OptionsContainer Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnOptionsCloseClick( wndHandler, wndControl, eMouseButton )
	self.wndMain:FindChild("ConfigButton"):SetCheck(false)
	self:OnOptionsToggle()
end

---------------------------------------------------------------------------------------------------
-- ItemEditWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnEditCloseButton( wndHandler, wndControl, eMouseButton )
	FSLootTrackerInst.wndEditWindow:Show(false)
	FSLootTrackerInst.wndEditWindow:Destroy()
end

function FSLootTracker:OnEditSaveButton( wndHandler, wndControl, eMouseButton )
	-- Get the index, set the values for this tItem index
	idx = wndHandler:GetParent():GetData()
	
	-- give it a piece of data to refer to 
	local wndItemCount = FSLootTrackerInst.wndEditWindow:FindChild("ItemCount")
	if wndItemCount then -- make sure the text wnd exist
		FSLootTrackerInst.tItems[idx].count = wndItemCount:GetText()
	end
	
	-- give it a piece of data to refer to 
	local wndItemCost = FSLootTrackerInst.wndEditWindow:FindChild("ItemCost")
	if wndItemCost then -- make sure the text wnd exist
		FSLootTrackerInst.tItems[idx].cost = wndItemCost:GetText()
	end
	
	-- give it a piece of data to refer to 
	local wndItemPlayer = FSLootTrackerInst.wndEditWindow:FindChild("ItemLooter")
	if wndItemPlayer then -- make sure the text wnd exist
		local strLooter = "" .. wndItemPlayer:GetText() .. ""
		local looterID = FSLootTrackerInst.tCache.LooterCache:GetAddValue(strLooter)
		FSLootTrackerInst.tItems[idx].looter = looterID 
	end		

	FSLootTrackerInst:RebuildLists()
	FSLootTrackerInst.wndEditWindow:Show(false)
	FSLootTrackerInst.wndEditWindow:Destroy()
end

---------------------------------------------------------------------------------------------------
-- ConfirmDeleteWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnConfirmDelete( wndHandler, wndControl, eMouseButton )
	FSLootTrackerInst:ClearLists()
	if FSLootTrackerInst.wndDeleteConfirm then
		FSLootTrackerInst.wndDeleteConfirm:Show(false)
		FSLootTrackerInst.wndDeleteConfirm:Destroy()
	end
	FSLootTrackerInst.wndDeleteConfirm = nil
end

function FSLootTracker:OnCancelDelete( wndHandler, wndControl, eMouseButton )
	if FSLootTrackerInst.wndDeleteConfirm then
		FSLootTrackerInst.wndDeleteConfirm:Show(false)
		FSLootTrackerInst.wndDeleteConfirm:Destroy()
	end
	FSLootTrackerInst.wndDeleteConfirm = nil
end

---------------------------------------------------------------------------------------------------
-- ExportWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnCloseExport( wndHandler, wndControl, eMouseButton )
	wndHandler:GetParent():Show(false)
	wndHandler:GetParent():Destroy()
	FSLootTrackerInst.wndExport = nil
end

function FSLootTracker:OnExportClosed( wndHandler, wndControl )
	wndHandler:GetParent():Show(false)
	wndHandler:GetParent():Destroy()
	FSLootTrackerInst.wndExport = nil
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker SAVE/RESTORE Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then 
		return 
  	end
  
	local tSavedData = {
		tConfig = self.tConfig,
		tItems = self.tItems,
		tMoneys = self.tMoneys,
		tCache = {
			LooterCache = self.tCache.LooterCache.cache,
			SourceCache = self.tCache.SourceCache.cache,
			ZoneCache = self.tCache.ZoneCache.cache,
			ItemCache = self.tCache.ItemCache.cache
		}
	}
	return tSavedData
end

function FSLootTracker:OnRestore(eLevel, tSavedData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end

	-- Restore Configuration
	if tSavedData.tConfig then
		self.tConfig = shallowcopy(tSavedData.tConfig)
		-- Fill in any missing values from the default options
		-- This Protects us from configuration additions in the future
		for key, value in pairs(tDefaultOptions) do
			if self.tConfig[key] == nil then
				self.tConfig[key] = tDefaultOptions[key]
			end
		end
	else
		self.tConfig = shallowcopy(tDefaultOptions)
	end
	
	if self.tConfig.persistSession == true then
		-- Rebuild the Cache
		if tSavedData.tCache then
			for k, v in pairs(tSavedData.tCache) do
				for key, value in pairs(tSavedData.tCache[k]) do
					self.tCache[k]:AddKeyValue(key,value)
				end
			end
		end

		-- Load the Item Data	
		if tSavedData.tItems then
			self.tItems = shallowcopy(tSavedData.tItems)
		else	
			self.tItems = {}
		end
		
		-- Load the Money Data	
		if tSavedData.tMoney then
			self.tMoneys = shallowcopy(tSavedData.tMoneys)
		else
			self.tMoneys = {}	
		end
	end
end

function FSLootTracker:RefreshUIOptions()
	FSLootTrackerInst.editConfigCosts:SetText(FSLootTrackerInst.tConfig.defaultCost)
	-- initialize filter states
	for k,v in pairs(FSLootTrackerInst.tConfig.qualityFilters) do
		FSLootTrackerInst.editConfigTypes:FindChild(karItemQuality[k].Name):SetCheck(v)
	end
	local button = FSLootTrackerInst.editConfigTimeFormat:FindChild(FSLootTrackerInst.tConfig.timeFormat)
	button:SetCheck(true)
end


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

---------------------------------------------------------------------------------------------------
-- ItemAddWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnAddSaveButton( wndHandler, wndControl, eMouseButton )
	if FSLootTrackerInst.wndAddItem then
		local itemID = FSLootTrackerInst.wndAddItem:FindChild("ItemID"):GetText()
		local itemLooter = FSLootTrackerInst.wndAddItem:FindChild("ItemLooter"):GetText()
		local itemCount = FSLootTrackerInst.wndAddItem:FindChild("ItemCount"):GetText()
		local itemCost = FSLootTrackerInst.wndAddItem:FindChild("ItemCost"):GetText()
		local item
		
		-- Must validate the input before we get here -- so people don't enter junk data
		if itemID ~= "" then
			item = Item.GetDataFromId(tonumber(itemID))
			if item then
				Print(item:GetName())
			else 
				Print("Item does not exist")
			end
		end
			
		FSLootTrackerInst.wndAddItem:Show(false)
		FSLootTrackerInst.wndAddItem:Destroy()
		FSLootTrackerInst.wndAddItem = nil
	end
end

function FSLootTracker:OnAddCloseButton( wndHandler, wndControl, eMouseButton )
	if FSLootTrackerInst.wndAddItem then
		FSLootTrackerInst.wndAddItem:Show(false)
		FSLootTrackerInst.wndAddItem:Destroy()
		FSLootTrackerInst.wndAddItem = nil
	end
end

function FSLootTracker:OnItemAddClosed( wndHandler, wndControl )
	if FSLootTrackerInst.wndAddItem then
		FSLootTrackerInst.wndAddItem:Show(false)
		FSLootTrackerInst.wndAddItem:Destroy()
		FSLootTrackerInst.wndAddItem = nil
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker Instance
-----------------------------------------------------------------------------------------------
FSLootTrackerInst = FSLootTracker:new()
FSLootTrackerInst:Init()

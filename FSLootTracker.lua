-----------------------------------------------------------------------------------------------
-- Client Lua Script for FSLootTracker
-- Copyright (c) Chronosis. All rights reserved
-----------------------------------------------------------------------------------------------

require "Apollo" 
require "Window"
require "GameLib"

-----------------------------------------------------------------------------------------------
-- FSLootTracker Module Definition
-----------------------------------------------------------------------------------------------
local FSLootTracker = {} 
local FSLootTrackerInst

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")

local kfTimeBetweenItems = 2 -- Previously .3			-- delay between items; also determines clearing time (seconds)

local karDataTypes = {
	clear = 0,
	item = 1,
	money = 2
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
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Silver",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGrey",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Silver",
	},
	[Item.CodeEnumItemQuality.Average] = 
	{
		Name			= "Average",
		Color		   	= "ItemQuality_Average",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_White",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_White",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_White",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetWhite",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_White",
 	},
	[Item.CodeEnumItemQuality.Good]	=
	{
		Name			= "Good",	
		Color		   	= "ItemQuality_Good",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Green",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Green",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Green",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGreen",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Green",
  	},
	[Item.CodeEnumItemQuality.Excellent] =   
	{
		Name			= "Excellent",	
		Color		   	= "ItemQuality_Excellent",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Blue",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Blue",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetBlue",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Blue",
	},
	[Item.CodeEnumItemQuality.Superb] = 
  	{
		Name			= "Superb",
		Color		   	= "ItemQuality_Superb",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Purple",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Purple",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPurple",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Purple",
 	},
	[Item.CodeEnumItemQuality.Legendary] = 
  	{
		Name			= "Legendary",	
		Color		   	= "ItemQuality_Legendary",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Orange",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Orange",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetOrange",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Orange",
  	},
	[Item.CodeEnumItemQuality.Artifact] =   
  	{
		Name			= "Artifact",	
		Color		   	= "ItemQuality_Artifact",
		BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
		HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Pink",
		SquareSprite	= "CRB_Tooltips:sprTooltip_SquareFrame_Pink",
		CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPink",
		NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Pink",
	},
}

local tDefaultOptions = {
	updateThreshold = 15,
	defaultCost = 0,
	timeFormat = "12h", 
	dateFormat = "MM/DD/YYYY",
	qualityFilters = {
		[Item.CodeEnumItemQuality.Inferior] = false,
		[Item.CodeEnumItemQuality.Average] = false,
		[Item.CodeEnumItemQuality.Good]	= false,
		[Item.CodeEnumItemQuality.Excellent] = false, 
		[Item.CodeEnumItemQuality.Superb] = false,
		[Item.CodeEnumItemQuality.Legendary] = false,
		[Item.CodeEnumItemQuality.Artifact] = false
	}
}

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
	--o.fLastTimeAdded = GameLib.GetGameTime()	-- last time the stack queue was updates
	o.tConfig = shallowcopy(tDefaultOptions)  -- defaults
	o.fFirstLoot = nil			-- first time Loot occurred this session
	o.fLastLoot = nil			-- last time Loot occurred this session
	o.fLastTimeAdded = 0		-- last time the stack queue was updates
	o.tQueuedEntryData = {}		-- keep track of all recently looted items to process
	o.tItems = {} 				-- keep track of all the looted items
	o.tItemsEncoded = {} 		-- keep track of all the looted items
	o.tItemWindows = {}			-- keep track of all the looted item windows
	o.tMoneys = {}				-- keep track of all the looted money
	o.tMoneyWindows = {}		-- keep track of all the looted money windows
	o.wndSelectedListItem = nil	-- keep track of which list item is currently selected
	o.wndEditWindow = nil
	o.curItemCount = 0			-- current count of items in the item track
	o.curMoneyCount = 0			-- current count of money items logged
	o.updateCount = 0
	o.stats = {
		totalMoney = 0,
		perHourMoney = 0,
		avgMoney = 0,
		junkValue = 0,
		largestDrop = 0
	}
	o.isOpen = false			-- current window state   
	o.debug = false
	
	o.wndLastItemControl = nil

	return o
end

function FSLootTracker:Debug( message )
	if (self.debug) then
		if (self.debug == true) then
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
-- ListMoney Functions
---------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedItem(itemInstance, count)
	--queue recently added items
	self:Debug("Item Looted: " .. itemInstance:GetName())
	local tNewEntry =
	{
		recordType = karDataTypes.item,
		itemID = itemInstance:GetItemId(),
		item = itemInstance,
		nCount = count,
		looter = GameLib.GetPlayerUnit():GetName(),
		cost = self.tConfig.defaultCost,		
		timeAdded = GameLib.GetGameTime(),
		timeReported = GameLib.GetLocalTime()['strFormattedTime']		
	}
	table.insert(self.tQueuedEntryData, tNewEntry)
	self.fLastTimeAdded = GameLib.GetGameTime()	
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedMoney
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedMoney(monLooted)
	local eCurrencyType = monLooted:GetMoneyType()
	--Print(self:JSONEncode(GameLib.GetLocalTime()))
	--self:Debug("Money Looted: " .. eCurrencyType:GetName())
	local tNewEntry =
	{
		recordType = karDataTypes.money,
		item = monLooted,
		nCount = nil,
		looter = nil,
		timeAdded = GameLib.GetGameTime(),
		timeReported = GameLib.GetLocalTime()['strFormattedTime']		
	}
	table.insert(self.tQueuedEntryData, tNewEntry)
	self.fLastTimeAdded = GameLib.GetGameTime()		
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootAssigned (MasterLooting)
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootAssigned(itemInstance, strLooter)
	self:Debug("Item Assigned: " .. itemInstance:GetName() .. " to " .. strLooter)
	-- Only Track this event if the looter isn't the player running the addon 
	-- Since this will be caught by the onLootItem event automatically
	if strLooter ~= GameLib.GetPlayerUnit():GetName() then
		local tNewEntry =
		{
			recordType = karDataTypes.item,
			itemID = itemInstance:GetItemId(),
			item = itemInstance,
			nCount = 1,
			looter = strLooter,
			cost = self.tConfig.defaultCost,
			timeAdded = GameLib.GetGameTime(),
			timeReported = GameLib.GetLocalTime()['strFormattedTime']		
		}
		table.insert(self.tQueuedEntryData, tNewEntry)
		self.fLastTimeAdded = GameLib.GetGameTime()	
	end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootRollWon -- (For Winning Loot Roll) -- Hooked from NeedVsGreed
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootRollWon(itemLooted, strWinner, bNeed)
	self:Debug("Item Won: " .. itemLooted:GetName() .. " by " .. strWinner)
	local tNewEntry =
	{
		recordType = karDataTypes.item,
		itemID = itemLooted:GetItemId(),
		item = itemLooted,
		nCount = 1,
		looter = strWinner,
		cost = self.tConfig.defaultCost,
		timeAdded = GameLib.GetGameTime(),
		timeReported = GameLib.GetLocalTime()['strFormattedTime']		
	}
	table.insert(self.tQueuedEntryData, tNewEntry)
	self.fLastTimeAdded = GameLib.GetGameTime()	
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

	if tQueuedData.nCount == 0 then
		self:Debug("Item has no count")
		return
	end
	
	local now = GameLib.GetGameTime()
	if self.fFirstLoot == nil then
		self.fFirstLoot = now
	end
	self.fLastLoot = now

	-- push this item on the end of the table
	local fCurrTime = now
	if tQueuedData.recordType == karDataTypes.item then
		self:Debug("Item was added")
		local item = tQueuedData.item
		local iQuality = item:GetItemQuality() or 1
		-- Only add items of quality not being filtered
		if self.tConfig.qualityFilters[iQuality] ~= true then
			table.insert(self.tItems, tQueuedData)
		end
		-- Track Junk value
		if iQuality == Item.CodeEnumItemQuality.Inferior then
			local itemValue = item:GetSellPrice():GetAmount() or 0 
			self.stats.junkValue = self.stats.junkValue + itemValue
			self:RefreshStats()
		end
	elseif tQueuedData.recordType == karDataTypes.money then
		self:Debug("Money was added")
		local money = tQueuedData.item
		tQueuedData["itemType"] = money:GetMoneyType()
		tQueuedData["itemAmount"] = money:GetAmount()
		-- Add to total earn if actual money
		local eCurrencyType = money:GetMoneyType()
		table.insert(self.tMoneys, tQueuedData)
		if eCurrencyType == Money.CodeEnumCurrencyType.Credits then
			self:UpdateStats(money:GetAmount())
		end		
	else
		self:Debug("Unknown type")	
	end
	self.updateCount = self.updateCount + 1
	-- Only Update the tracked loot once the queue is empty 
	-- or when we've reach the update threshold
	-- This code is here for performance reasons
	if #self.tQueuedEntryData == 0 or self.updateCount > self.tConfig.updateThreshold then
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

	-- Library Embeds
	Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
	--Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
	
	-- initialize loot event
	Apollo.RegisterEventHandler("Generic_ToggleLoot", "OnLootTrackerOn", self)
	Apollo.RegisterEventHandler("LootedItem", "OnLootedItem", self)
	Apollo.RegisterEventHandler("LootedMoney", "OnLootedMoney", self)
	Apollo.RegisterEventHandler("LootAssigned", "OnLootAssigned", self)
	Apollo.RegisterEventHandler("LootRollWon", "OnLootRollWon", self)
	Apollo.RegisterTimerHandler("LootStackUpdate", "OnLootStackUpdate", self)
	Apollo.RegisterEventHandler("CombatLogLoot", "OnCombatLogLoot", self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	Apollo.CreateTimer("LootStackUpdate", 0.1, true)

	-- Hooks
    --self.addonNeedVsGreed = Apollo.GetAddon("NeedVsGreed")
    --if self.addonNeedVsGreed ~= nil then
    --    self:RawHook(self.addonNeedVsGreed , "OnLootRollWon")
    --end
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
		self.wndSessions = Apollo.LoadForm(self.xmlDoc, "SessionsForm", nil, self)
		
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
		
		self.wndMain:Show(false, true)
		self.wndSessions:Show(false)
		self.wndLootOpts:Show(false)
		self:RefreshStats()
		self:InitConfigUI()

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
		self.isOpen = false
		self.wndMain:Close() -- hide the window
	else
		self.isOpen = true 
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
	self.isOpen = false
end

-- when the Cancel button is clicked
function FSLootTracker:OnCancel( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close() -- hide the window
	self.isOpen = false
end

-- when the Clear button is clicked
function FSLootTracker:OnClear( wndHandler, wndControl, eMouseButton )
	self:Debug( "Clear Pressed. " .. self.wndMain:GetName())
	FSLootTrackerInst:ClearLists()
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
		-- Open Context Dialog
	end	
end

-- when the window is closed
function FSLootTracker:OnWindowClosed( wndHandler, wndControl )
	self.isOpen = false
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
		self.editConfigCosts:SetText(self.tConfig.defaultCost)
	else
		self.tConfig.defaultCost = self.editConfigCosts:GetText()
	end
end

function FSLootTracker:OnExportData( wndHandler, wndControl, eMouseButton )
	if not FSLootTrackerInst.wndExport then
		FSLootTrackerInst.wndExport = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ExportWindow", nil, FSLootTrackerInst)
		-- TODO: EXPORT DATA HERE AND INSERT IT INTO THE FORM
		local exportStr = self:JSONEncode(FSLootTrackerInst.tItemsExport)
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

	self.curItemCount = 0
	self.curMoneyCount = 0
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
		self:AddItem(idx, item.item, item.nCount, item.looter, item.timeAdded, item.timeReported)
		self.curItemCount = self.curItemCount + 1
	end
	for idx,money in ipairs(self.tMoneys) do
		self:AddMoney(idx, money.item, money.timeAdded, money.timeReported)
		self.curMoneyCount = self.curMoneyCount + 1
	end 
	self.updateCount = 0
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
		local tNewEntry =
		{
			itemName = itemInstance.item:GetName(),
			itemQuality = itemInstance.item:GetItemQuality() or 1,
			itemILvl = itemInstance.item:GetItemPower(),
			itemType = itemInstance.item:GetItemTypeName(),
			itemArt = itemInstance.item:GetIcon(),
			count = itemInstance.nCount,
			looter = itemInstance.looter,
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
	self.stats.totalMoney = self.stats.totalMoney + addMoney
	
	-- Calculate Money Per Hour
	if self.fFirstLoot ~= nil then
		local timediff = os.difftime(self.fLastLoot, self.fFirstLoot)
		if timediff > 0 then
			self.stats.perHourMoney = (self.stats.totalMoney * 3600) / timediff 
		else
			self.stats.perHourMoney = addMoney
		end
	end
	
	-- Calculate Average Money
	local nMoneyLoots = table.getn(self.tMoneys)
	if nMoneyLoots > 0 then
		self.stats.avgMoney = self.stats.totalMoney / nMoneyLoots
	else
		self.stats.avgMoney = addMoney
	end
	
	-- Calculate Largest Loot
	if addMoney > self.stats.largestDrop then
		self.stats.largestDrop = addMoney
	end

	self:RefreshStats()
end

function FSLootTracker:RefreshStats()
	self.wndTotalCash:SetAmount(self.stats.totalMoney)
	self.wndPerHourCash:SetAmount(self.stats.perHourMoney)
	self.wndAvgCash:SetAmount(self.stats.avgMoney)
	self.wndJunkCash:SetAmount(self.stats.junkValue)
	self.wndMostCash:SetAmount(self.stats.largestDrop)
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

-----------------------------------------------------------------------------------------------
-- ItemList Functions
-----------------------------------------------------------------------------------------------
-- clear the item list
function FSLootTracker:ClearLists()
	self.curItemCount = 0
	self.curMoneyCount = 0
	self:DestroyItemList()
	self:DestroyMoneyList()
	for key,val in pairs(self.stats) do
		self.stats[key] = 0
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
function FSLootTracker:AddItem(idx, item, count, looter, time, reportedTime)
	self:Debug("Item Add Called for " .. item:GetName() .. ": (" .. item:GetItemId() .. ") x" .. count)
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndItemList, self)
	wndFlyoutBtn = wnd:FindChild("ContextButton")
	wndFlyoutBtn:SetCheck(false)
	wndFlyoutBtn:FindChild("ContextFlyout"):Show(false)

	--table.insert(self.tItems, wnd)
	local iQuality = item:GetItemQuality() or 1
	-- give it a piece of data to refer to 
	local wndItemText = wnd:FindChild("ItemText")
	if wndItemText then -- make sure the text wnd exist
		wndItemText:SetText(item:GetName())
		wndItemText:SetTextColor(karItemQuality[iQuality].Color)
	end
	-- give it a piece of data to refer to 
	local wndItemType = wnd:FindChild("ItemType")
	if wndItemType then -- make sure the text wnd exist
		wndItemType:SetText(item:GetItemTypeName())
		wndItemType:SetTextColor(kcrNormalText)
	end
	-- give it a piece of data to refer to 
	local wndItemCount = wnd:FindChild("ItemCount")
	if wndItemCount then -- make sure the text wnd exist
		wndItemCount:SetText("x" .. count)
		wndItemCount:SetTextColor(kcrNormalText)
	end
	-- give it a piece of data to refer to 
	local wndItemPlayer = wnd:FindChild("ItemPlayer")
	if wndItemPlayer then -- make sure the text wnd exist
		wndItemPlayer:SetText(looter)
		wndItemPlayer:SetTextColor(kcrNormalText)
	end	
	-- give it a piece of data to refer to 
	local wndItemTimestamp = wnd:FindChild("ItemTimestamp")
	if wndItemTimestamp then -- make sure the text wnd exist
		-- Okay need to fix this lol. 
		wndItemTimestamp:SetText(reportedTime)
		--wndItemTimestamp:SetText(time)
		wndItemTimestamp:SetTextColor(kcrNormalText)
	end
	-- give it a piece of data to refer to 
	local wndItemBorder = wnd:FindChild("ItemBorder")
	if wndItemBorder then -- make sure the text wnd exist
		wndItemBorder:SetSprite(karItemQuality[iQuality].SquareSprite)
		local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
		if wndItemIcon then 
			wndItemIcon:SetSprite(item:GetIcon())
			wndItemIcon:SetData(idx)
		end
	end

	wnd:SetData(idx)
	-- keep track of the window item created
	self.tItemWindows[self.curItemCount] = wnd
	self:Debug("List Item created for item " .. wnd:GetData() .. " : " .. self.curItemCount)
end

-----------------------------------------------------------------------------------------------
-- AddMoney Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:AddMoney(idx, money, time, reportedTime)
	self:Debug("Money Add Called for " .. money:GetAmount())
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListMoney", self.wndMoneyList, self)

		local wndMoneyText = wnd:FindChild("MoneyText")
	if wndMoneyText then -- make sure the text wnd exist
		local wndCashDisplay = wndMoneyText:FindChild("CashDisplay")
		if wndCashDisplay then 
			wndCashDisplay:SetAmount(money:GetAmount())	
		end
	end

	local wndMoneyTimestamp = wnd:FindChild("MoneyTimestamp")
	if wndMoneyTimestamp then 
		wndMoneyTimestamp:SetText(reportedTime)
		wndMoneyTimestamp:SetTextColor(kcrNormalText)
	end

	wnd:SetData(idx)
	self:Debug("List Money created for item " .. wnd:GetData() .. " : " .. self.curMoneyCount)
		
	-- keep track of the window item created
	self.tMoneyWindows[self.curMoneyCount] = wnd
end
---------------------------------------------------------------------------------------------------
-- ListItem Functions
---------------------------------------------------------------------------------------------------

function FSLootTracker:CreateEditWindow( wndHandler )
-- Get Parent List item and associated item data. 
	local idx = wndHandler:GetData()
	local data = FSLootTrackerInst.tItems[idx]
	local item = data.item
	-- Load the item edit panel
	if FSLootTrackerInst.wndEditWindow then
		FSLootTrackerInst.wndEditWindow:Destroy()
	end
	FSLootTrackerInst.wndEditWindow = Apollo.LoadForm(FSLootTrackerInst.xmlDoc, "ItemEditWindow", nil, FSLootTrackerInst)
	FSLootTrackerInst.wndEditWindow:Show(true)
	
	local iQuality = item:GetItemQuality() or 1
	-- give it a piece of data to refer to 
	local wndItemILvl = FSLootTrackerInst.wndEditWindow:FindChild("ItemILvl")
	if wndItemILvl then -- make sure the text wnd exist
		wndItemILvl:SetText("iLvl: " .. item:GetItemPower())
	end
	
	-- give it a piece of data to refer to 
	local wndItemPower = FSLootTrackerInst.wndEditWindow:FindChild("ItemNumber")
	if wndItemPower then -- make sure the text wnd exist
		wndItemPower:SetText("Item #: " .. item:GetItemId())
	end
	
	-- give it a piece of data to refer to 
	local wndItemText = FSLootTrackerInst.wndEditWindow:FindChild("ItemText")
	if wndItemText then -- make sure the text wnd exist
		wndItemText:SetText(item:GetName())
		wndItemText:SetTextColor(karItemQuality[iQuality].Color)
	end
	
	-- give it a piece of data to refer to 
	local wndItemType = FSLootTrackerInst.wndEditWindow:FindChild("ItemType")
	if wndItemType then -- make sure the text wnd exist
		wndItemType:SetText(item:GetItemTypeName())
	end
	
	-- give it a piece of data to refer to 
	local wndItemCount = FSLootTrackerInst.wndEditWindow:FindChild("ItemCount")
	if wndItemCount then -- make sure the text wnd exist
		wndItemCount:SetText(data.nCount)
	end
	
	-- give it a piece of data to refer to 
	local wndItemCost = FSLootTrackerInst.wndEditWindow:FindChild("ItemCost")
	if wndItemCost then -- make sure the text wnd exist
		wndItemCost:SetText(data.cost)
	end
	
	-- give it a piece of data to refer to 
	local wndItemPlayer = FSLootTrackerInst.wndEditWindow:FindChild("ItemLooter")
	if wndItemPlayer then -- make sure the text wnd exist
		wndItemPlayer:SetText(data.looter)
	end	
	
	-- give it a piece of data to refer to 
	local wndItemTimestamp = FSLootTrackerInst.wndEditWindow:FindChild("ItemTimestamp")
	if wndItemTimestamp then -- make sure the text wnd exist
		-- Okay need to fix this lol. 
		wndItemTimestamp:SetText("Looted at " .. data.timeReported)
		wndItemTimestamp:SetTextColor(kcrNormalText)
	end
	
	-- give it a piece of data to refer to 
	local wndItemBorder = FSLootTrackerInst.wndEditWindow:FindChild("ItemBorder")
	if wndItemBorder then -- make sure the text wnd exist
		wndItemBorder:SetSprite(karItemQuality[iQuality].SquareSprite)
		local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
		if wndItemIcon then 
			wndItemIcon:SetSprite(item:GetIcon())
			wndItemIcon:SetData(idx)
		end
	end

	FSLootTrackerInst.wndEditWindow:SetData(idx)
end

function FSLootTracker:OnGenerateTooltip( wndHandler, wndControl, eToolTipType, x, y )
	--if wndControl ~= wndHandler then return end
	wndControl:SetTooltipDoc(nil)
	local item = FSLootTrackerInst.tItems[wndHandler:GetData()].item
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
	local oItem = FSLootTrackerInst.tItems[wndHandler:GetData()].item
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
		FSLootTrackerInst.tItems[idx].nCount = wndItemCount:GetText()
	end
	
	-- give it a piece of data to refer to 
	local wndItemCost = FSLootTrackerInst.wndEditWindow:FindChild("ItemCost")
	if wndItemCost then -- make sure the text wnd exist
		FSLootTrackerInst.tItems[idx].cost = wndItemCost:GetText()
	end
	
	-- give it a piece of data to refer to 
	local wndItemPlayer = FSLootTrackerInst.wndEditWindow:FindChild("ItemLooter")
	if wndItemPlayer then -- make sure the text wnd exist
		FSLootTrackerInst.tItems[idx].looter = wndItemPlayer:GetText()
	end		

	FSLootTrackerInst:RebuildLists()
	FSLootTrackerInst.wndEditWindow:Show(false)
	FSLootTrackerInst.wndEditWindow:Destroy()
end

---------------------------------------------------------------------------------------------------
-- ConfirmDeleteWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnConfirmDelete( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnCancelDelete( wndHandler, wndControl, eMouseButton )

end


---------------------------------------------------------------------------------------------------
-- ExportWindow Functions
---------------------------------------------------------------------------------------------------
function FSLootTracker:OnCloseExport( wndHandler, wndControl, eMouseButton )
	wndHandler:GetParent():Show(false)
	wndHandler:GetParent():Destroy()
	FSLootTrackerInst.wndExport = nil
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker SAVE/RESTORE Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.General then 
		return 
  	end
  
	local tSavedData = {
		tConfig = self.tConfig,
		tItems = self.tItems,
		tMoneys = self.tMoneys
	}
	return tSavedData
end

function FSLootTracker:OnRestore(eLevel, tSavedData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.General then
		return
	end
	
	--if tSavedData.tItems ~= nil then
	--	Print("Item List Loaded")
	--	self.tItems = shallowcopy(tSavedData.tItems)
	--	-- Saving the Carbine doesn't store the userdata item object
	--	-- when it saves data. We need to reload the items them based 
	--	-- on the stored item ID.
	--	for idx, v in ipairs(self.tItems) do
	--		self.tItems[idx].item = Item.GetDataFromId(v.ItemID)
	--	end
	--else	
	--	self.tItems = {}
	--end
	
	-- TODO: Money Loot is being stored the same way as items, we need to find a way to 
	-- create a Money Packet and what information needs to be saved to restore that userdata
	-- Disabled for now 
	-----------------------------------------------------------------------------------------
	--if tSavedData.tMoneys ~= nil then
	--	Print("Money List Loaded")
	--	self.tMoneys = shallowcopy(tSavedData.tMoneys)
	--else
	--	self.tMoneys = {}	
	--end

	if tSavedData.config ~= nil then
		self.tConfig = shallowcopy(tSavedData.tConfig)
	else
		self.tConfig = shallowcopy(tDefaultOptions)
	end
end

function FSLootTracker:InitConfigUI()
	self.editConfigCosts:SetText(self.tConfig.defaultCost)
	-- initialize filter states
	for k,v in pairs(self.tConfig.qualityFilters) do
		self.editConfigTypes:FindChild(karItemQuality[k].Name):SetCheck(v)
	end
end


-----------------------------------------------------------------------------------------------
-- FSLootTracker Instance
-----------------------------------------------------------------------------------------------
FSLootTrackerInst = FSLootTracker:new()
FSLootTrackerInst:Init()

---------------------------------------------------------------------------------------------------
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
end

function FSLootTracker:OnAddCloseButton( wndHandler, wndControl, eMouseButton )
end


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
local Major, Minor, Patch, Suffix = 2, 2, 0, 0
local FSLOOTTRACKER_CURRENT_VERSION = string.format("%d.%d.%d", Major, Minor, Patch)
local FSDataVersion = "2.0"

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

local karDataTypes =
{
  clear = 0,
  item = 1,
  money = 2
}

local karLootSources =
{
  ["Dropped"] = 0,
  ["Rolled"] = 1,
  ["Master"] = 2,
  ["Entered"] = -1
}

local karLootSourcesNames =
{
  [0] = "Dropped",
  [1] = "Rolled",
  [2] = "Master",
  [-1] = "Entered"
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
    [karLootSources.Dropped] = false,
    [karLootSources.Rolled] = false,
    [karLootSources.Master] = false,
  }
}

local strDefaultGuildInfoText =
  "=== FSLootTracker ===\n\n" ..
  "_.,-*~'`^`'~*-,._\n\n" ..
  "Developed By:\n" ..
  "Chrono Syz--Entity-US\n" ..
  "Copyright (c) 2014,2015\n\n" ..
  "_.,-*~'`^`'~*-,._\n\n" ..
  "<FOR SCIENCE>\n" ..
  "Dominion / PvE\n" ..
  "Entity-US\n\n" ..
  "http://forscienceguild.org\n\n" ..
  "_.,-*~'`^`'~*-,._\n"

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

  o.tConfig = deepcopy(tDefaultOptions)  -- defaults

  o.tStats = {
    junkValue = 0,
    [Money.CodeEnumCurrencyType.Credits] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    },
    [Money.CodeEnumCurrencyType.ElderGems] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    },
    [Money.CodeEnumCurrencyType.Glory] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    },
    [Money.CodeEnumCurrencyType.Prestige] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    },
    [Money.CodeEnumCurrencyType.Renown] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    },
    [Money.CodeEnumCurrencyType.CraftingVouchers] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0
    }
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
    ItemCache = {},
    KillCache = {},
    EquipmentCache = {}
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

  o.sortSettings = {
    Source = "Time",
    Direction = 0,
    UseItemData = false
  }

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
      type = itemInstance:GetItemTypeName() .. " (" .. itemInstance:GetItemType() .. ")",
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
-- FSLootTracker GetLootItemEventData
-----------------------------------------------------------------------------------------------
function FSLootTracker:GetLootItemEventData(itemInstance, itemCount, itemSource, itemLooter, itemNeed)
  local iQuality = itemInstance:GetItemQuality() or Item.CodeEnumItemQuality.Average

  local iValue = 0
  if itemInstance:GetSellPrice() ~= nil then
    iValue = itemInstance:GetSellPrice():GetAmount()
  end

  local curZone = GameLib.GetCurrentZoneMap()
  local zoneName = ""
  if curZone then
    zoneName = curZone.strName
  else
    zoneName = "Unknown"
  end

  local tNewEntry =
  {
    recordType = karDataTypes.item,
    itemID = itemInstance:GetItemId(),
    count = itemCount,
    cost = self.tConfig.defaultCost,
    looter = self.tCache.LooterCache:GetAddValue(itemLooter),
    quality = iQuality,
    source =  self.tCache.SourceCache:GetAddValue(self.tState.lastSource),
    sourceType = karLootSources[itemSource],
    rollType = itemNeed,
    timeAdded = GameLib.GetGameTime(),
    timeReported = GameLib.GetLocalTime(),
    zone = self.tCache.ZoneCache:GetAddValue(zoneName),
    value = iValue
  }
  return tNewEntry
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedItem(itemInstance, itemCount)
  --queue recently added items
  self:Debug("Item Looted: " .. itemInstance:GetName())
  self:CacheItem(itemInstance)
  table.insert(self.tQueuedEntryData, self:GetLootItemEventData(itemInstance, itemCount, "Dropped", strPlayerName, nil))
  self.fLastTimeAdded = GameLib.GetGameTime()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootRollWon -- (For Winning Loot Roll) -- Hooked from NeedVsGreed
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootRollWon(itemLooted, strWinner, bNeed)
  self:Debug("Item Won: " .. itemLooted:GetName() .. " by " .. strWinner)
  if strWinner ~= GameLib.GetPlayerUnit():GetName() then
    self:CacheItem(itemLooted)
    table.insert(self.tQueuedEntryData, self:GetLootItemEventData(itemLooted, 1, "Rolled", strWinner, bNeed))
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
    table.insert(self.tQueuedEntryData, self:GetLootItemEventData(itemInstance, 1, "Master", strLooter, nil))
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
    self:UpdateStats(tQueuedData)
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
  Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "FSLootTracker", {"Generic_ToggleLoot", "", "FSLootSprites:BigChest"})
  --self:UpdateInterfaceMenuAlerts()
  strPlayerName = GameLib.GetPlayerUnit():GetName()
  self:RebuildLists()
  self:RefreshStats()

  -- Report Self
  Event_FireGenericEvent("OneVersion_ReportAddonInfo", "FSLootTracker", Major, Minor, Patch, Suffix, false)
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLoad
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLoad()
  Apollo.LoadSprites("FSLootSprites.xml")

  -- load our form file
  self.xmlDoc = XmlDoc.CreateFromFile("FSLootTracker.xml")
  self.xmlDoc:RegisterCallback("OnDocLoaded", self)

  Chronology = Apollo.GetPackage("Chronology-1.0").tPackage
  Cache = Apollo.GetPackage("SimpleCache-1.0").tPackage

  for key, val in pairs(self.tCache) do
    self.tCache[key] = Cache:new()
  end

  -- Library Embeds
  Apollo.GetPackage("Json:Utils-1.0").tPackage:Embed(self)
  --Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)

  -- initialize loot event
  Apollo.RegisterEventHandler("Generic_ToggleLoot", "OnLootTrackerOn", self)
  --Apollo.RegisterEventHandler("LootedItem", "OnLootedItem", self)
  --Apollo.RegisterEventHandler("LootedMoney", "OnLootedMoney", self)
  Apollo.RegisterEventHandler("ChannelUpdate_Loot",	"OnChannelUpdate_Loot", self)
  --Apollo.RegisterEventHandler("ItemAdded", "OnLootedItem", self)
  --Apollo.RegisterEventHandler("LootStackItemSentToTradeskillBag", 		"OnLootstackItemSentToTradeskillBag", self)

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
    if unit then
      if not unit:IsACharacter() then
        -- set loot target and time stamp
        local strUnitName = unit:GetName()
        self.tCache.KillCache:GetAddValue(strUnitName)
        self.tState.lastSource = strUnitName
        -- Start Loot Timer to reset
        Apollo.StartTimer("KillSourceTimerUpdate")
      end
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
    self.wndJunkCash = self.wndMoneyWindow:FindChild("JunkValue"):FindChild("CashDisplay")

    self.wndTotalCash = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("CashDisplay")
    self.wndTotalCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.wndPerHourCash = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("CashDisplay")
    self.wndPerHourCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.wndAvgCash = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("CashDisplay")
    self.wndAvgCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.wndMostCash = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("CashDisplay")
    self.wndMostCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)

    self.wndTotalEG = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("EGDisplay")
    self.wndTotalEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.wndPerHourEG = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("EGDisplay")
    self.wndPerHourEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.wndAvgEG = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("EGDisplay")
    self.wndAvgEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.wndMostEG = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("EGDisplay")
    self.wndMostEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)

    self.wndTotalReknown = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("ReknownDisplay")
    self.wndTotalReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.wndPerHourReknown = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("ReknownDisplay")
    self.wndPerHourReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.wndAvgReknown = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("ReknownDisplay")
    self.wndAvgReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.wndMostReknown = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("ReknownDisplay")
    self.wndMostReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)

    self.wndTotalGlory = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("GloryDisplay")
    self.wndTotalGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.wndPerHourGlory = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("GloryDisplay")
    self.wndPerHourGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.wndAvgGlory = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("GloryDisplay")
    self.wndAvgGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.wndMostGlory = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("GloryDisplay")
    self.wndMostGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)

    self.wndTotalPrestige = self.wndMoneyWindow:FindChild("TotalMoney"):FindChild("PSDisplay")
    self.wndTotalPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.wndPerHourPrestige = self.wndMoneyWindow:FindChild("MoneyPerHour"):FindChild("PSDisplay")
    self.wndPerHourPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.wndAvgPrestige = self.wndMoneyWindow:FindChild("AvgMoney"):FindChild("PSDisplay")
    self.wndAvgPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.wndMostPrestige = self.wndMoneyWindow:FindChild("LargestLoot"):FindChild("PSDisplay")
    self.wndMostPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)

    self.editConfigCosts = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureCosts"):FindChild("EditBox")
    self.editConfigTypes = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureTypes"):FindChild("QualityBtns")
    self.editConfigTimeFormat = self.wndLootOpts:FindChild("OptionsContainerFrame"):FindChild("OptionsConfigureTimeFormat")

    self.wndProcessingIndicator = self.wndMain:FindChild("ProcessingIndicator")
    self.wndSessions = self.wndMain:FindChild("SessionsForm")
    self.wndContextFlyout = self.wndMain:FindChild("ContextFlyout")

    self.wndMain:Show(false, true)
    self.wndSessions:Show(false)
    self.wndLootOpts:Show(false)
    self.wndProcessingIndicator:Show(false)

    self.wndItemList:Show(true)
    self.wndMoneyWindow:Show(true)
    self.wndMoneyWindow:Show(false)
    self.wndMain:FindChild("HeaderButtons"):FindChild("SplashItemsBtn"):SetCheck(true)

    local l, t, r, b = FSLootTrackerInst.wndContextFlyout:GetAnchorOffsets()
    local w, h = (r-l), (b-t)
    self.tContextFlyoutSize = {
      width = w,
      height = h
    }
    self.wndContextFlyout:Show(false)

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
  if self.tState.isOpen == true then
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

  FSLootTrackerInst.wndContextFlyout:Show(false)

  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    FSLootTrackerInst:CreateEditWindow( wndHandler )
  end

  if eMouseButton == 1 then -- Right Clicked
    -- Shift Right click
    if Apollo.IsShiftKeyDown() then
      local itemID = FSLootTrackerInst.tItems[wndHandler:GetData()].itemID
      local oItem = Item.GetDataFromId(tonumber(itemID))
      Event_FireGenericEvent("ItemLink", oItem)
    else
      -- Close the last context window if you've opened a different one.
      local mousePos = Apollo.GetMouse()
      --Print(self:JSONEncode(mousePos))
      -- Position it
      FSLootTrackerInst.wndContextFlyout:SetAnchorOffsets(mousePos.x - FSLootTrackerInst.tContextFlyoutSize.width, mousePos.y, mousePos.x , mousePos.y + FSLootTrackerInst.tContextFlyoutSize.height)
      FSLootTrackerInst.wndContextFlyout:Show(true)
      FSLootTrackerInst.wndLastItemSelected = wndHandler
    end
  end
end

-- when the window is closed
function FSLootTracker:OnWindowClosed( wndHandler, wndControl )
  self.tState.isOpen = false
  self.wndContextFlyout:Show(false)
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
    --FSLootTrackerInst.
  end
end

function FSLootTracker:OnRecordingStopButton( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnRecordingStartButton( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  --FSLootTrackerInst.wndContextFlyout:Show(false)
end

function FSLootTracker:OnContextClosed( wndHandler, wndControl )
  FSLootTrackerInst.wndContextFlyout:Show(false)
end

function FSLootTracker:SortItemList( wndHandler, wndControl, eMouseButton )
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker ClearLists
-----------------------------------------------------------------------------------------------
function FSLootTracker:EmptyLists()
  self.wndContextFlyout:Show(false)
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
  -- Save Scroll Position
  local itemVScrollPos = self.wndItemList:GetVScrollPos()
  local moneyVScrollPos = self.wndMoneyList:GetVScrollPos()

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

  -- Restore Scroll Position
  self.wndItemList:SetVScrollPos(itemVScrollPos)
  self.wndMoneyList:SetVScrollPos(moneyVScrollPos)
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
  local timediff = 0
  if self.fFirstLoot ~= nil then
    timediff = os.difftime(self.fLastLoot, self.fFirstLoot)
  end

  --self:Debug("Adding Money: " .. addMoney.moneyAmount)
  local m = self.tStats[addMoney.moneyType]

  if m == nil then
    m = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0,
      count = 0
    }
  end

  if not m.count then
    m.count = 0
  end

  -- Calculate Total Money
  m.total = m.total + addMoney.moneyAmount
  m.count = m.count + 1

  -- Calculate Money Per Hour
  if self.fFirstLoot ~= nil then
    if timediff > 0 then
      m.perHour = (m.total * 3600) / timediff
    else
      m.perHour = addMoney.moneyAmount
    end
  end

  -- Calculate Average Money
  if m.count > 0 then
    m.average = m.total / m.count
  else
    m.average = addMoney.moneyAmount
  end

  -- Calculate Largest Loot
  if addMoney.moneyAmount > m.largest then
    m.largest = addMoney.moneyAmount
  end
  --self.tStats[addMoney.moneyType] = m

  self:RefreshStats()
end

function FSLootTracker:RefreshStats()
  self.wndTotalCash:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Credits].total)
  self.wndPerHourCash:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Credits].perHour)
  self.wndAvgCash:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Credits].average)
  self.wndMostCash:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Credits].largest)

  self.wndTotalEG:SetAmount(self.tStats[Money.CodeEnumCurrencyType.ElderGems].total)
  self.wndPerHourEG:SetAmount(self.tStats[Money.CodeEnumCurrencyType.ElderGems].perHour)
  self.wndAvgEG:SetAmount(self.tStats[Money.CodeEnumCurrencyType.ElderGems].average)
  self.wndMostEG:SetAmount(self.tStats[Money.CodeEnumCurrencyType.ElderGems].largest)

  self.wndTotalGlory:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Glory].total)
  self.wndPerHourGlory:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Glory].perHour)
  self.wndAvgGlory:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Glory].average)
  self.wndMostGlory:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Glory].largest)

  self.wndTotalReknown:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Renown].total)
  self.wndPerHourReknown:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Renown].perHour)
  self.wndAvgReknown:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Renown].average)
  self.wndMostReknown:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Renown].largest)

  self.wndTotalPrestige:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Prestige].total)
  self.wndPerHourPrestige:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Prestige].perHour)
  self.wndAvgPrestige:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Prestige].average)
  self.wndMostPrestige:SetAmount(self.tStats[Money.CodeEnumCurrencyType.Prestige].largest)

  self.wndJunkCash:SetAmount(self.tStats.junkValue)
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
    if key == "junkValue" then
      self.tStats[key] = 0
    else
      self.tStats[key] = {
        total = 0,
        perHour = 0,
        average = 0,
        largest = 0
      }
    end
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
  --wndFlyoutBtn = wnd:FindChild("ContextButton")
  --wndFlyoutBtn:SetCheck(false)
  --wndFlyoutBtn:FindChild("ContextFlyout"):Show(false)

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
  local wndItemValue = wnd:FindChild("ItemValue")
  if wndItemValue then -- make sure the text wnd exist
    wndItemValue:SetAmount(itemData.value)
    wndItemValue:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
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
    local strNeed = ""
    if item.rollType ~= nil then
      if item.rollType == true then
        strNeed = " (Need)"
      else
        strNeed = " (Greed)"
      end
    end
    wndItemSourceType:SetText(karLootSourcesNames[item.sourceType] .. strNeed)
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
    wndItemBorder:SetText("x" .. item.count ) --.. "�")
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

function FSLootTracker:OnEditBtnClicked( wndHandler, wndControl, eMouseButton )
  FSLootTrackerInst.wndContextFlyout:Show(false)

  -- Get Parent List item and associated item data.
  FSLootTrackerInst:CreateEditWindow( FSLootTrackerInst.wndLastItemSelected )
end

function FSLootTracker:OnDeleteBtnClicked( wndHandler, wndControl, eMouseButton )
  -- Get Parent List item and associated item data.
  local index = FSLootTrackerInst.wndLastItemSelected:GetData()
  wndHandler:Show(false)
  table.remove(FSLootTrackerInst.tItems, index)
  FSLootTrackerInst.wndContextFlyout:Show(false)
  FSLootTrackerInst:RebuildLists()
end

function FSLootTracker:OnBlacklistBtnClicked( wndHandler, wndControl, eMouseButton )
  FSLootTrackerInst.wndContextFlyout:Show(false)
  -- Get Parent List item and associated item data.
end

function FSLootTracker:OnItemExportBtnClicked( wndHandler, wndControl, eMouseButton )
  FSLootTrackerInst.wndContextFlyout:Show(false)
  -- Get Parent List item and associated item data.
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
    dataVersion = FSDataVersion,
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
  if tSavedData == FSDataVersion then
    if tSavedData.tConfig then
      self.tConfig = deepcopy(tSavedData.tConfig)
      -- Fill in any missing values from the default options
      -- This Protects us from configuration additions in the future
      for key, value in pairs(tDefaultOptions) do
        if self.tConfig[key] == nil then
          self.tConfig[key] = tDefaultOptions[key]
        end
      end
    else
      self.tConfig = deepcopy(tDefaultOptions)
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
        self.tItems = deepcopy(tSavedData.tItems)
      else
        self.tItems = {}
      end

      -- Load the Money Data
      if tSavedData.tMoney then
        self.tMoneys = deepcopy(tSavedData.tMoneys)
      else
        self.tMoneys = {}
      end
    end
  else
    self.tConfig = deepcopy(tDefaultOptions)
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

function FSLootTracker:OnAddLookupItem( wndHandler, wndControl, eMouseButton )
end

function FSLootTracker:OnChannelUpdate_Loot(eType, tEventArgs)
  if eType == GameLib.ChannelUpdateLootType.Currency and tEventArgs.monNew then
    self:OnLootedMoney(tEventArgs.monNew)
  elseif eType == GameLib.ChannelUpdateLootType.Item and tEventArgs.itemNew then
    self:OnLootedItem(tEventArgs.itemNew, tEventArgs.nCount)
  end
end
-----------------------------------------------------------------------------------------------
-- FSLootTracker Instance
-----------------------------------------------------------------------------------------------
FSLootTrackerInst = FSLootTracker:new()
FSLootTrackerInst:Init()

------------------------------------------------------------------------------------------------
--	FSLootTracker ver. @project-version@
--	by Chronosis--Caretaker-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/chronosis/FSLootTracker
------------------------------------------------------------------------------------------------
-- TODO: Options Screen -- Add Persistent Session Option, Source Filter, Black List, Alert List, Export Format
-- TODO: Finish Blacklist and Alert functionality
-- TODO: Add Export formats (HTML, BBCODE, JSON, XML-CTLootTracker-EQDKP)
-- TODO: Pixie Plot of statistics over time
-- TODO: Add Purpose column and Mark As > Costume/Salvage/Bank/Loot option (default Loot)
-- TODO: Move current view into a "Money Log" View
-- TODO: Capture and Display Socket Types on the item Drop
-- TODO: Track Boss Kills and attendance in raid at the moment of the kill.
-- TODO: Save, View, Restore Sessions (Can't Delete Active Session)
-- TODO: Add options to assign a source (kill)
-- TODO: Tag Master Loot elligible items with the boss that thing that was just killed.
-- TODO: Update Master Loot BOP items to be able to be reassigned to an elligible looter based on the information from the boss kill
-- TODO: Column Sort functionality
-- TODO: Localization
require "Apollo"
require "Window"
require "GameLib"

-----------------------------------------------------------------------------------------------
-- FSLootTracker Module Definition
-----------------------------------------------------------------------------------------------
local FSLootTracker = {}
local Utils = Apollo.GetPackage("SimpleUtils").tPackage
local Chronology = Apollo.GetPackage("Chronology").tPackage
local Cache = Apollo.GetPackage("SimpleCache").tPackage

local Major, Minor, Patch, Suffix = 2, 2, 2, 0  -- TODO: Change to 3.0.0.0
local FSLOOTTRACKER_CURRENT_VERSION = string.format("%d.%d.%d", Major, Minor, Patch)
local FSDataVersion = "3.0"

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")
local kfTimeBetweenItems = 2            -- Previously .3			-- delay between items; also determines clearing time (seconds)
local strPlayerName = ""								-- This shouldn't be changing

FSLootTracker.tLootSources =
{
  ["Dropped"] = 0,
  ["Rolled"] = 1,
  ["Master"] = 2,
  ["Entered"] = -1
}

FSLootTracker.tExportFormats =
{
  json = "json",
  bbcode = "bbcode",
  html = "html"
}

-----------------------------------------------------------------------------------------------
-- Defaults
-----------------------------------------------------------------------------------------------
local tDefaultSettings = {
  dataVersion = FSDataVersion,
  version = FSLOOTTRACKER_CURRENT_VERSION,
  user = {
    debug = false,
    blacklist = {},         -- keep track of items that should be filtered
    whitelist = {}          -- keep track of items that should be alerted
  },
  positions = {
    main = nil
  },
  options = {
    persistSession = true,
    updateThreshold = 15,
    defaultCost = 0,
    timeFormat = "12h",
    exportFormat = FSLootTracker.tExportFormats.bbcode,
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
      [FSLootTracker.tLootSources.Dropped] = false,
      [FSLootTracker.tLootSources.Rolled] = false,
      [FSLootTracker.tLootSources.Master] = false,
    },
    sort = {
      Source = "Time",
      Direction = 0,
      UseItemData = false
    }
  }
}

local tDefaultState = {
  isOpen = false,           -- current window state
  lastSource = "Unknown",   -- last loot source
  updateCount = 0,
  firstLoot = nil,
  lastLoot = nil,           -- last time Loot occurred this session
  lastTimeAdded = 0,        -- last time the stack queue was updates
  curMoneyCount = 0,        -- current count of money items logged
  curOptionTab = 1,         -- The currently loaded tab
  optionsHovered = false,
  windows = {               -- These store windows for lists
    main = nil,
    edit = nil,
    info = nil,
    options = nil,
    selectedItem = nil,
    itemWindows = {},       -- keep track of all the looted item windows
    moneyWindows = {}     	-- keep track of all the looted money windows
  },
  listItems = {
    lootQueue = {},         -- Queued Loot
    alertQueue = {},        -- Queued Alerts
    money = {},             -- keep track of all the looted money
    items = {},             -- keep track of all the looted items
    itemsExport = {},       -- keep track of all the looted items
    itemsEncoded = {}       -- keep track of all the looted items
  },
  stats = {
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
    },
    [Money.CodeEnumCurrencyType.ShadeSilver] = {
      total = 0,
      perHour = 0,
      average = 0,
      largest = 0
    }
  },
  cache = {
    SourceCache = {},
    ZoneCache = {},
    LooterCache = {},
    ItemCache = {},
    KillCache = {},
    EquipmentCache = {}
  }
}

function FSLootTracker:Debug( message )
  if self.settings then
    if self.settings.user.debug then
      Utils:debug(message)
    end
  end
end

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function FSLootTracker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Saved and Restored values are stored here.
  o.settings = deepcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermanent and not saved between sessions
  o.state = deepcopy(tDefaultState)

  return o
end

function FSLootTracker:Init()
  local bHasConfigureFunction = true
  local strConfigureButtonText = "FSLootTracker"
  local tDependencies = {
    -- "UnitOrPackageName",
  }

  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)

  self.settings = deepcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  self.state = deepcopy(tDefaultState)
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
  if not self.state.cache.ItemCache:HasKey(itemID) then
    local item = {
      quality = itemInstance:GetItemQuality() or Item.CodeEnumItemQuality.Average,
      name = itemInstance:GetName(),
      iLvl = itemInstance:GetItemPower(),
      icon = itemInstance:GetIcon(),
      type = itemInstance:GetItemTypeName() .. " (" .. itemInstance:GetItemType() .. ")",
      value = v
    }
    self.state.cache.ItemCache:AddKeyValue(itemID, item)
  end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootedMoney
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootedMoney(moneyInstance)
  local curZone = GameLib.GetCurrentZoneMap()
  local zoneName = ""
  if curZone then
    zoneName = curZone.strName
  else
    zoneName = "Unknown"
  end

  local tNewEntry =
  {
    recordType = self.tDataTypes.money,
    moneyAmount = moneyInstance:GetAmount(),
    moneyType = moneyInstance:GetMoneyType(),
    source = self.state.cache.SourceCache:GetAddValue(self.state.lastSource),
    timeAdded = GameLib.GetGameTime(),
    timeReported = GameLib.GetLocalTime(),
    zone = self.state.cache.ZoneCache:GetAddValue(zoneName)
  }
  table.insert(self.state.listItems.lootQueue, tNewEntry)
  self.state.lastTimeAdded = GameLib.GetGameTime()
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
    recordType = self.tDataTypes.item,
    itemID = itemInstance:GetItemId(),
    count = itemCount,
    cost = self.settings.options.defaultCost,
    looter = self.state.cache.LooterCache:GetAddValue(itemLooter),
    quality = iQuality,
    source =  self.state.cache.SourceCache:GetAddValue(self.state.lastSource),
    sourceType = self.tLootSources[itemSource],
    rollType = itemNeed,
    timeAdded = GameLib.GetGameTime(),
    timeReported = GameLib.GetLocalTime(),
    zone = self.state.cache.ZoneCache:GetAddValue(zoneName),
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
  table.insert(self.state.listItems.lootQueue, self:GetLootItemEventData(itemInstance, itemCount, "Dropped", strPlayerName, nil))
  self.state.lastTimeAdded = GameLib.GetGameTime()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootRollWon -- (For Winning Loot Roll) -- Hooked from NeedVsGreed
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootRollWon(itemLooted, strWinner, bNeed)
  self:Debug("Item Won: " .. itemLooted:GetName() .. " by " .. strWinner)
  if strWinner ~= GameLib.GetPlayerUnit():GetName() then
    self:CacheItem(itemLooted)
    table.insert(self.state.listItems.lootQueue, self:GetLootItemEventData(itemLooted, 1, "Rolled", strWinner, bNeed))
    self.state.lastTimeAdded = GameLib.GetGameTime()
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
    table.insert(self.state.listItems.lootQueue, self:GetLootItemEventData(itemInstance, 1, "Master", strLooter, nil))
    self.state.lastTimeAdded = GameLib.GetGameTime()
  end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker OnLootStackUpdate
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnLootStackUpdate(strVar, nValue)
  local fCurrTime = GameLib.GetGameTime()

  -- add a new item if its time
  if #self.state.listItems.lootQueue > 0 then
    if fCurrTime - self.state.lastTimeAdded >= kfTimeBetweenItems then
      self:AddQueuedItem()
    end
    if self.state.windows.ProcessingIndicator then
      self.state.windows.ProcessingIndicator:Show(true)
    end
  else
    if self.state.windows.ProcessingIndicator then
      self.state.windows.ProcessingIndicator:Show(false)
    end
  end
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker AddQueuedItem
-----------------------------------------------------------------------------------------------
function FSLootTracker:AddQueuedItem()
  -- gather our entryData we need
  local tQueuedData = self.state.listItems.lootQueue[1]
  table.remove(self.state.listItems.lootQueue, 1)
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
  if self.state.firstLoot == nil then
    self.state.firstLoot = now
  end
  self.state.lastLoot = now
  local fCurrTime = now

  -- push this item on the end of the table
  if tQueuedData.recordType == self.tDataTypes.item then
    self:Debug("Item was added")
    local iQuality = tQueuedData.quality
    -- Only add items of quality not being filtered
    if self.settings.options.qualityFilters[iQuality] ~= true then
      table.insert(self.state.listItems.items, tQueuedData)
    end
    -- Track Junk value
    if iQuality == Item.CodeEnumItemQuality.Inferior then
      self.state.stats.junkValue = self.state.stats.junkValue + tQueuedData.value
      self:RefreshStats()
    end
  elseif tQueuedData.recordType == self.tDataTypes.money then
    self:Debug("Money was added")
    -- Add to total earn if actual money
    table.insert(self.state.listItems.money, tQueuedData)
    self:UpdateStats(tQueuedData)
  else
    self:Debug("Unknown type")
  end
  self.state.updateCount = self.state.updateCount + 1
  -- Only Update the tracked loot once the queue is empty
  -- or when we've reach the update threshold
  -- This code is here for performance reasons
  if #self.state.listItems.lootQueue == 0 or self.state.updateCount > self.settings.options.updateThreshold then
    self:RebuildLists()
  end

  self.state.lastTimeAdded = fCurrTime
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

  Chronology = Apollo.GetPackage("Chronology").tPackage
  Cache = Apollo.GetPackage("SimpleCache").tPackage

  for key, val in pairs(self.state.cache) do
    self.state.cache[key] = Cache:new()
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
  self.state.lastSource = "Vendor"
end

function FSLootTracker:OnCloseVendorWindow()
  self.state.lastSource = "Unknown"
end

function FSLootTracker:OnSalvageItem()
  self.state.lastSource = "Salvage/ItemBox"
end

function FSLootTracker:OnQuestStateChange(queUpdated, eState)
  if queUpdated ~= nil then
    local reward, money = queUpdated:GetRewardData()
    if eState == Quest.QuestState_Completed then
      if reward ~= nil then
        self.state.lastSource = "Quest"
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
        self.state.cache.KillCache:GetAddValue(strUnitName)
        self.state.lastSource = strUnitName
        -- Start Loot Timer to reset
        Apollo.StartTimer("KillSourceTimerUpdate")
      end
    end
  end
end

function FSLootTracker:OnKillSourceTimer()
  self.state.lastSource = "Unknown"
  Apollo.StartTimer("KillSourceTimerUpdate")
end


-----------------------------------------------------------------------------------------------
-- FSLootTracker OnDocLoaded
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnDocLoaded()
  if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
    self.state.windows.main = Apollo.LoadForm(self.xmlDoc, "LootTrackerForm", nil, self)
    --self.state.windows.lootOpts = Apollo.LoadForm(self.xmlDoc, "OptionsContainer", wndParent, self)
    if self.state.windows.main == nil then
      Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
      return
    end

    -- item list
    self.state.windows.ItemList = self.state.windows.main:FindChild("ItemList")
    self.state.windows.MoneyWindow = self.state.windows.main:FindChild("MoneyWindow")
    self.state.windows.MoneyList = self.state.windows.MoneyWindow:FindChild("MoneyList")
    self.state.windows.JunkCash = self.state.windows.MoneyWindow:FindChild("JunkValue"):FindChild("CashDisplay")

    self.state.windows.TotalCash = self.state.windows.MoneyWindow:FindChild("TotalMoney"):FindChild("CashDisplay")
    self.state.windows.TotalCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.state.windows.PerHourCash = self.state.windows.MoneyWindow:FindChild("MoneyPerHour"):FindChild("CashDisplay")
    self.state.windows.PerHourCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.state.windows.AvgCash = self.state.windows.MoneyWindow:FindChild("AvgMoney"):FindChild("CashDisplay")
    self.state.windows.AvgCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)
    self.state.windows.MostCash = self.state.windows.MoneyWindow:FindChild("LargestLoot"):FindChild("CashDisplay")
    self.state.windows.MostCash:SetMoneySystem(Money.CodeEnumCurrencyType.Credits)

    self.state.windows.TotalEG = self.state.windows.MoneyWindow:FindChild("TotalMoney"):FindChild("EGDisplay")
    self.state.windows.TotalEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.state.windows.PerHourEG = self.state.windows.MoneyWindow:FindChild("MoneyPerHour"):FindChild("EGDisplay")
    self.state.windows.PerHourEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.state.windows.AvgEG = self.state.windows.MoneyWindow:FindChild("AvgMoney"):FindChild("EGDisplay")
    self.state.windows.AvgEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)
    self.state.windows.MostEG = self.state.windows.MoneyWindow:FindChild("LargestLoot"):FindChild("EGDisplay")
    self.state.windows.MostEG:SetMoneySystem(Money.CodeEnumCurrencyType.ElderGems)

    self.state.windows.TotalReknown = self.state.windows.MoneyWindow:FindChild("TotalMoney"):FindChild("ReknownDisplay")
    self.state.windows.TotalReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.state.windows.PerHourReknown = self.state.windows.MoneyWindow:FindChild("MoneyPerHour"):FindChild("ReknownDisplay")
    self.state.windows.PerHourReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.state.windows.AvgReknown = self.state.windows.MoneyWindow:FindChild("AvgMoney"):FindChild("ReknownDisplay")
    self.state.windows.AvgReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)
    self.state.windows.MostReknown = self.state.windows.MoneyWindow:FindChild("LargestLoot"):FindChild("ReknownDisplay")
    self.state.windows.MostReknown:SetMoneySystem(Money.CodeEnumCurrencyType.Renown)

    self.state.windows.TotalGlory = self.state.windows.MoneyWindow:FindChild("TotalMoney"):FindChild("GloryDisplay")
    self.state.windows.TotalGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.state.windows.PerHourGlory = self.state.windows.MoneyWindow:FindChild("MoneyPerHour"):FindChild("GloryDisplay")
    self.state.windows.PerHourGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.state.windows.AvgGlory = self.state.windows.MoneyWindow:FindChild("AvgMoney"):FindChild("GloryDisplay")
    self.state.windows.AvgGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)
    self.state.windows.MostGlory = self.state.windows.MoneyWindow:FindChild("LargestLoot"):FindChild("GloryDisplay")
    self.state.windows.MostGlory:SetMoneySystem(Money.CodeEnumCurrencyType.Glory)

    self.state.windows.TotalPrestige = self.state.windows.MoneyWindow:FindChild("TotalMoney"):FindChild("PSDisplay")
    self.state.windows.TotalPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.state.windows.PerHourPrestige = self.state.windows.MoneyWindow:FindChild("MoneyPerHour"):FindChild("PSDisplay")
    self.state.windows.PerHourPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.state.windows.AvgPrestige = self.state.windows.MoneyWindow:FindChild("AvgMoney"):FindChild("PSDisplay")
    self.state.windows.AvgPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)
    self.state.windows.MostPrestige = self.state.windows.MoneyWindow:FindChild("LargestLoot"):FindChild("PSDisplay")
    self.state.windows.MostPrestige:SetMoneySystem(Money.CodeEnumCurrencyType.Prestige)

    self.state.windows.ProcessingIndicator = self.state.windows.main:FindChild("ProcessingIndicator")
    self.state.windows.Sessions = self.state.windows.main:FindChild("SessionsForm")
    self.state.windows.contextFlyout = self.state.windows.main:FindChild("ContextFlyout")

    self.state.windows.main:Show(false, true)
    self.state.windows.Sessions:Show(false)
    self.state.windows.ProcessingIndicator:Show(false)

    self.state.windows.ItemList:Show(true)
    self.state.windows.MoneyWindow:Show(true)
    self.state.windows.MoneyWindow:Show(false)
    self.state.windows.main:FindChild("HeaderButtons"):FindChild("SplashItemsBtn"):SetCheck(true)

    local l, t, r, b = self.state.windows.contextFlyout:GetAnchorOffsets()
    local w, h = (r-l), (b-t)
    self.tContextFlyoutSize = {
      width = w,
      height = h
    }
    self.state.windows.contextFlyout:Show(false)

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
  if self.state.isOpen == true then
    self.state.isOpen = false
    self:SaveLocation()
    self.state.windows.main:Close() -- hide the window
  else
    self.state.isOpen = true
    self.state.windows.main:Invoke() -- show the window
  end

  -- populate the item list
  self:RefreshListDisplays()
end

-- when the window is closed
function FSLootTracker:OnWindowClosed( wndHandler, wndControl )
  self.state.isOpen = false
  self.state.windows.contextFlyout:Show(false)
end

function FSLootTracker:OnWindowMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
  self:SaveLocation()
end

function FSLootTracker:OnStringCopiedToClipboard()
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker ClearLists
-----------------------------------------------------------------------------------------------
function FSLootTracker:EmptyLists()
  self.state.windows.contextFlyout:Show(false)
  for idx,wnd in ipairs(self.state.windows.itemWindows) do
    wnd:Destroy()
  end
  for idx,wnd in ipairs(self.state.windows.moneyWindows) do
    wnd:Destroy()
  end

  self.state.windows.ItemList:DestroyChildren()
  self.state.windows.MoneyList:DestroyChildren()
  self.state.windows.itemWindows = {}
  self.state.windows.moneyWindows = {}
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker RebuildLists
-----------------------------------------------------------------------------------------------
function FSLootTracker:RebuildLists()
  -- Save Scroll Position
  local itemVScrollPos = self.state.windows.ItemList:GetVScrollPos()
  local moneyVScrollPos = self.state.windows.MoneyList:GetVScrollPos()

  self:EmptyLists()
  for idx,item in ipairs(self.state.listItems.items) do
    self:AddItem(idx, item)
  end
  for idx,money in ipairs(self.state.listItems.money) do
    self:AddMoney(idx, money)
  end
  self.state.updateCount = 0
  self:RebuildExportList()
  self:RefreshListDisplays()
  self:RefreshStats()

  -- Restore Scroll Position
  self.state.windows.ItemList:SetVScrollPos(itemVScrollPos)
  self.state.windows.MoneyList:SetVScrollPos(moneyVScrollPos)
end

-- clear the item list
function FSLootTracker:DestroyItemList()
  self.state.listItems.items = {}
  for idx,wnd in ipairs(self.state.windows.moneyWindows) do
    wnd:Destroy()
    table.remove(self.state.windows.moneyWindows, 1)
  end

  self.state.windows.selectedItem = nil
end

function FSLootTracker:StripCharacters(str)
  local s = string.gsub(str,"-","")
  s = string.gsub(s," ","-")
  s = string.gsub(s, "'","")
  s = string.gsub(s, "\"","")
  return s
end

-- rebuild list used to export the data
function FSLootTracker:RebuildExportList()
  self.state.listItems.itemsExport = {}
  for idx, itemInstance in ipairs(self.state.listItems.items) do
    local item = self.state.cache.ItemCache:GetValue(itemInstance.itemID)
    local itemName = item.name

    local jabbitLink = "http://www.jabbithole.com/items/" .. self:StripCharacters(itemName) .. "-" .. tostring(itemInstance.itemID)

    local tNewEntry =
    {
      itemID = itemInstance.itemID,
      itemName = itemName,
      itemQuality = itemInstance.quality,
      itemILvl = itemInstance.iLvl,
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

-----------------------------------------------------------------------------------------------
-- MoneyList Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:UpdateStats(addMoney)
  local timediff = 0
  if self.state.firstLoot ~= nil then
    timediff = os.difftime(self.state.lastLoot, self.state.firstLoot)
  end

  --self:Debug("Adding Money: " .. addMoney.moneyAmount)
  local m = self.state.stats[addMoney.moneyType]

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
  if self.state.firstLoot ~= nil then
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
  --self.state.stats[addMoney.moneyType] = m

  self:RefreshStats()
end

function FSLootTracker:RefreshStats()
  self.state.windows.TotalCash:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Credits].total)
  self.state.windows.PerHourCash:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Credits].perHour)
  self.state.windows.AvgCash:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Credits].average)
  self.state.windows.MostCash:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Credits].largest)

  self.state.windows.TotalEG:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.ElderGems].total)
  self.state.windows.PerHourEG:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.ElderGems].perHour)
  self.state.windows.AvgEG:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.ElderGems].average)
  self.state.windows.MostEG:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.ElderGems].largest)

  self.state.windows.TotalGlory:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Glory].total)
  self.state.windows.PerHourGlory:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Glory].perHour)
  self.state.windows.AvgGlory:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Glory].average)
  self.state.windows.MostGlory:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Glory].largest)

  self.state.windows.TotalReknown:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Renown].total)
  self.state.windows.PerHourReknown:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Renown].perHour)
  self.state.windows.AvgReknown:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Renown].average)
  self.state.windows.MostReknown:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Renown].largest)

  self.state.windows.TotalPrestige:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Prestige].total)
  self.state.windows.PerHourPrestige:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Prestige].perHour)
  self.state.windows.AvgPrestige:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Prestige].average)
  self.state.windows.MostPrestige:SetAmount(self.state.stats[Money.CodeEnumCurrencyType.Prestige].largest)

  self.state.windows.JunkCash:SetAmount(self.state.stats.junkValue)
end

-- clear the item list
function FSLootTracker:DestroyMoneyList()
  -- clear the list money array
  self.state.listItems.money = {}
  for idx,wnd in ipairs(self.state.windows.itemWindows) do
    wnd:Destroy()
    table.remove(self.state.windows.itemWindows, 1)
  end
  self.state.windows.selectedItem = nil
end

-- clear the cache
function FSLootTracker:ClearCache()
  for key, val in pairs(self.state.cache) do
    self.state.cache[key]:Clear()
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
  for key,val in pairs(self.state.stats) do
    if key == "junkValue" then
      self.state.stats[key] = 0
    else
      self.state.stats[key] = {
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
  self.state.windows.ItemList:ArrangeChildrenVert()
  self.state.windows.MoneyList:ArrangeChildrenVert()
end

-----------------------------------------------------------------------------------------------
-- AddItem Functions
-----------------------------------------------------------------------------------------------
-- add an item into the item list
function FSLootTracker:AddItem(idx, item) --, count, looter, time, reportedTime)
  self:Debug("Item Add Called for (" .. item.itemID .. ") x" .. item.count)
  -- load the window item for the list item
  local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.state.windows.ItemList, self)
  --wndFlyoutBtn = wnd:FindChild("ContextButton")
  --wndFlyoutBtn:SetCheck(false)
  --wndFlyoutBtn:FindChild("contextFlyout"):Show(false)

  local itemData = self.state.cache.ItemCache:GetValue(item.itemID)
  --table.insert(self.state.listItems.items, wnd)
  if itemData then
    local iQuality = itemData.quality
    -- give it a piece of data to refer to
    local wndItemText = wnd:FindChild("ItemText")
    if wndItemText then -- make sure the text wnd exist
      wndItemText:SetText(itemData.name)
      wndItemText:SetTextColor(self.tItemQuality[iQuality].Color)
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
      wndItemPlayer:SetText(self.state.cache.LooterCache:GetKeyFromValue(item.looter))
      --wndItemPlayer:SetTextColor(kcrNormalText)
    end

    -- give it a piece of data to refer to
    local wndItemTimestamp = wnd:FindChild("ItemTimestamp")
    if wndItemTimestamp then -- make sure the text wnd exist
      local strFormat = self.tTimeStampFormats[self.settings.options.timeFormat]
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
      wndItemSource:SetText(self.state.cache.SourceCache:GetKeyFromValue(item.source))
      --wndItemSource:SetTextColor(kcrNormalText)
    end

    -- give it a piece of data to refer to
    local wndItemZone = wnd:FindChild("ItemZone")
    if wndItemZone then -- make sure the text wnd exist
      wndItemZone:SetText(self.state.cache.ZoneCache:GetKeyFromValue(item.zone))
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
      wndItemSourceType:SetText(self.tLootSourcesNames[item.sourceType] .. strNeed)
    end

    -- give it a piece of data to refer to
    local wndItemBorder = wnd:FindChild("ItemBorder")
    if wndItemBorder then -- make sure the text wnd exist
      local wndItemIcon = wndItemBorder:FindChild("ItemIcon")
      if wndItemIcon then
        wndItemIcon:SetSprite(itemData.icon)
        wndItemIcon:SetData(idx)
      end
      wndItemBorder:SetSprite(self.tItemQuality[iQuality].SquareSprite)
      wndItemBorder:SetText("x" .. item.count ) --.. "�")
    end

    wnd:SetData(idx)
    -- keep track of the window item created
    table.insert(self.state.windows.itemWindows, wnd)
    --self.state.windows.itemWindows[self.curItemCount] = wnd
    --self:Debug("List Item created for item " .. wnd:GetData() .. " : " .. self.curItemCount)
  end
end

-----------------------------------------------------------------------------------------------
-- AddMoney Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:AddMoney(idx, money)
  self:Debug("Money Add Called for " .. money.moneyAmount)
  -- load the window item for the list item
  local wnd = Apollo.LoadForm(self.xmlDoc, "ListMoney", self.state.windows.MoneyList, self)

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
    local strFormat = self.tTimeStampFormats[self.settings.options.timeFormat]
    wndMoneyTimestamp:SetText(Chronology:GetFormattedDateTime(money.timeReported, strFormat))
    wndMoneyTimestamp:SetTextColor(kcrNormalText)
  end

  wnd:SetData(idx)
  --self:Debug("List Money created for item " .. wnd:GetData() .. " : " .. self.state.curMoneyCount)

  -- keep track of the window item created
  table.insert(self.state.windows.moneyWindows, wnd)
  --self.state.windows.moneyWindows[self.state.curMoneyCount] = wnd
end

-----------------------------------------------------------------------------------------------
-- FSLootTracker SAVE/RESTORE Functions
-----------------------------------------------------------------------------------------------
function FSLootTracker:OnSave(eType)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  -- If session data is being persisted between sessions; do this.
  if self.settings.options.persistSession == true then
    self.settings.storage = {
      items = self.state.listItems.items,
      money = self.state.listItems.money,
      cache = {
        LooterCache = self.state.cache.LooterCache.cache,
        SourceCache = self.state.cache.SourceCache.cache,
        ZoneCache = self.state.cache.ZoneCache.cache,
        ItemCache = self.state.cache.ItemCache.cache
      }
    }
  end
  return deepcopy(self.settings)
end

function FSLootTracker:OnRestore(eType, tSavedData)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  if tSavedData and tSavedData.user then
    -- Copy the settings wholesale
    self.settings = deepcopy(tSavedData)

    -- Fill in any missing values from the default options
    -- This Protects us from configuration additions in the future versions
    for key, value in pairs(tDefaultSettings) do
      if self.settings[key] == nil then
        self.settings[key] = deepcopy(tDefaultSettings[key])
      end
    end

    -- This section is for converting between versions that saved data differently
    if self.settings.version ~= FSLOOTTRACKER_CURRENT_VERSION then
      -- reset main window position
      self.settings.positions.main = nil
    end

    -- Now that we've turned the save data into the most recent version, set it
    self.settings.version = FSLOOTTRACKER_CURRENT_VERSION

    -- If session data is being persisted between sessions; do this.
    if self.settings.options.persistSession == true and self.settings.storage then
      -- Rebuild the Cache
      if self.settings.storage.cache then
        for k, v in pairs(self.settings.storage.cache) do
          for key, value in pairs(self.settings.storage.cache[k]) do
            self.state.cache[k]:AddKeyValue(key,value)
          end
        end
      end

      -- Load the Item Data
      if self.settings.storage.items then
        self.state.listItems.items = deepcopy(self.settings.storage.items)
      else
        self.state.listItems.items = {}
      end

      -- Load the Money Data
      if self.settings.storage.money then
        self.state.listItems.money = deepcopy(self.settings.storage.money)
      else
        self.state.listItems.money = {}
      end
    end

    -- Clear these lists
    if self.settings.storage then
      self.settings.storage.items = nil
      self.settings.storage.money = nil
      if self.settings.storage.cache then
        self.settings.storage.cache.LooterCache = nil
        self.settings.storage.cache.SourceCache = nil
        self.settings.storage.cache.ZoneCache = nil
        self.settings.storage.cache.ItemCache = nil
      end
      self.settings.storage.cache = nil
      self.settings.storage = nil
    end
  else
    self.settings = deepcopy(tDefaultSettings)
  end
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
local FSLootTrackerInst = FSLootTracker:new()
FSLootTrackerInst:Init()

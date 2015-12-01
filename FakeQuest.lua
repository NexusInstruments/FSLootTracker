------------------------------------------------------------------------------------------------
--	FakeQuest ver. @project-version@
--	by Chrono Syz--Entity-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/NexusInstruments/FakeQuest
------------------------------------------------------------------------------------------------
--  FakeQuest.lua
--	A emulated Quest object so that "Fake Quests" can be tracked in the Objective Tracker
------------------------------------------------------------------------------------------------
local PackageName, Major, Minor, Patch = "FakeQuest", 1, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local FakeQuest = Pkg and Pkg.tPackage or {}
local FakeQuestCategory = {}
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

local baseRegion = {
  x = 0,
  y = 0
}

local baseIndicator = {
  x = 0,
  y = 0,
  z = 0
}

local baseLocation = {
  nWorldId = 0, -- continentId
  nWorldZoneId = 0, -- zonId
  tIndicator = {},
  tRegions = {}
}

function FakeQuestCategory:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function FakeQuestCategory:Init(id, title)
  if id > 0 then
    id = -id
  end
  self.id = id
  self.title = title
  self.type = 0
  self.episode = {}
  table.insert(self.episode, QuestLib.GetEpisode(1))
end

function FakeQuestCategory:GetCategoryType()
  return self.type
end

function FakeQuestCategory:GetEpisodes()
  return self.episode
end

function FakeQuestCategory:GetId()
  return self.id
end

function FakeQuestCategory:GetTitle()
  return self.title
end

function FakeQuest:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function FakeQuest:Init(id, title, categoryTitle)
  if id > 0 then
    id = -id
  end

  self.id = id
  self.title = title
  self.currIndex = 0
  self.objectives = {}
  self.objStore = {}
  self.state = QuestLib.QuestState_Accepted
  self.valid = true
  self.episode = QuestLib.GetEpisode(1)
  self.category = FakeQuestCategory:new()
  self.category:Init(id, categoryTitle)
  self.position = {}
end

function FakeQuest:CanAbandon()
  return false
end

function FakeQuest:CanCompleteObjective()
  return true
end

function FakeQuest:CanShare()
  return false
end

function FakeQuest:DisplayObjectiveProgressBar()
  return false
end

function FakeQuest:GetCategory()
  return self.category
end

function FakeQuest:GetChatLinkString()
  return "<Q>"
end

function FakeQuest:GetColoredDifficulty()
  return 6		-- Don't know what difficulty 5 is, but assumign it's normal
end

function FakeQuest:GetConLevel()
  return GameLib.GetPlayerLevel() or 50
end

function FakeQuest:GetDistance()
  return 0
end

function FakeQuest:GetEpisode()
  return QuestLib.GetEpisode(1)
end

function FakeQuest:GetId()
  return self.id or -1
end

function FakeQuest:GetMapRegions()
  local t = shallowcopy(baseLocation)
  t.tIndicator = shallowcopy(baseIndicator)
  table.insert(t.tRegions, shallowcopy(baseRegion))

  local zoneMap = GameLib.GetCurrentZoneMap()
  local playerUnit = GameLib.GetPlayerUnit()

  if playerUnit then
    t.tIndicator = playerUnit:GetPosition()
    t.tRegions[1].x = t.tIndicator.x
    t.tRegions[1].y = t.tIndicator.z
  end

  if zoneMap then
    t.nWorldId = zoneMap.nWorldId
    t.nWorldZoneId = zoneMap.id
  end
  return t
end

function FakeQuest:GetMinLevel()
  return 1
end

function FakeQuest:GetObjectiveCount()
  return #self.objStore
end

function FakeQuest:GetObjectiveDescription(idx)
  if self.objectives[idx] then
    return self.objectives[idx].strDescription
  end
  return nil
end

function FakeQuest:GetSpell()
  return nil
end

function FakeQuest:GetState()
  return self.state or Quest.QuestState_Accepted
end

function FakeQuest:GetTitle()
  return self.title or "Fake Quest"
end

function FakeQuest:GetVisibleObjectiveData()
  return self.objectives or {}
end

function FakeQuest:IsBreadcrumb()
  return false
end

function FakeQuest:IsImbuementQuest()
  return false
end

function FakeQuest:IsInactive()
  return false
end

function FakeQuest:IsInLog()
  return true
end

function FakeQuest:IsKnown()
  return true
end

function FakeQuest:IsMentioned()
  return false
end

function FakeQuest:IsPathQuest()
  return false
end

function FakeQuest:IsQuestTimed()
  return false
end

function FakeQuest:IsTracked()
  return true
end

function FakeQuest:IsValid()
  if self.valid then
    return self.valid
  end
  return true
end

function FakeQuest:SetActiveQuest(b)
end

function FakeQuest:SetTracked(b)
end

function FakeQuest:ShowHintArrow()
end

function FakeQuest:ToggleActiveQuest()
end

function FakeQuest:ToggleIgnored()
end

function FakeQuest:ToggleTracked()
end

-- ===========================================================================

function FakeQuest:SetAccepted()
  self.state = Quest.QuestState_Accepted
end

function FakeQuest:SetCompleted()
  self.state = Quest.QuestState_Completed
end

function FakeQuest:ClearAllObjectives()
  self.objStore = {}
end
-- Adds or Sets the objective with ID
function FakeQuest:SetObjective(id, desc)
  self.objStore[id] = desc
  self:RebuildObjectives()
end

-- Removes the objective with corresponding ID
function FakeQuest:RemoveObjective(id)
  if self.objStore[id] then
    self.objStore[id] = nil
    self:RebuildObjectives()
  end
end

function FakeQuest:RebuildObjectives()
  -- Loop through objectives and reindex them
  self.objectives = {}
  local index = 0
  for k,v in pairs(self.objStore) do
    local t = {
      bIsRequired = true,
      bIsReward = false,
      nCompleted = 0,
      nIndex = index,
      nNeeded = 0,
      strDescription = v
    }
    table.insert(self.objectives, t)
    index = index + 1
  end
end

Apollo.RegisterPackage(FakeQuest, PkgMajor, PkgMinor, {})

-- To Add or Update quest just do this
--Event_FireGenericEvent("QuestTrackedChanged", quest, true)

-- To Remove Quest just do this
--Event_FireGenericEvent("QuestTrackedChanged", quest, false)

require "Apollo"
require "GameLib"

local FakeQuest = {}
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

function FakeQuest:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function FakeQuest:Init(id, title)
  self.id = id
  self.title = title
  self.currIndex = 0
  self.objectives = {}
  self.objStore = {}
  self.state = QuestLib.QuestState_Accepted
  self.valid = true
end

function FakeQuest:GetId()
  return self.id or -1
end

function FakeQuest:GetEpisode()
  return QuestLib.GetEpisode(1)
end

function FakeQuest:IsImbuementQuest()
  return false
end

function FakeQuest:IsBreadcrumb()
  return false
end

function FakeQuest:GetTitle()
  return self.title or "Fake Quest"
end

function FakeQuest:GetState()
  return self.state or Quest.QuestState_Accepted
end

function FakeQuest:IsQuestTimed()
  return false
end

function FakeQuest:IsTracked()
  return true
end

function FakeQuest:GetColoredDifficulty()
  return 5		-- Don't know what difficulty 5 is, but assumign it's normal
end

function FakeQuest:GetConLevel()
  return GameLib.GetPlayerLevel() or 50
end

function FakeQuest:GetDistance()
  return 0
end

function FakeQuest:GetMapRegions()
  local position = {}
  local t = {
    [1] = {
      nWorldId = 0, -- continentId
      nWorldZonId = 0, -- zonId
      tIndicator = {
        x = 0,
        y = 0,
        z = 0
      }, -- x,y,z
      tRegions = {
        [1] = {
          x = 0,
          y = 0
        } -- x,y
      }
    }
  }

  local playerUnit = GameLib.GetPlayerUnit()
  if playerUnit then
    t.tIndicator = playerUnit.GetPosition()
    t.tRegions[1].x = t.tIndicator.x
    t.tRegions[1].y = t.tIndicator.z
  end
  return t
end

function FakeQuest:GetVisibleObjectiveData()
  return self.objectives or {}
end

function FakeQuest:IsValid()
  if self.valid then
    return self.valid
  end
  return true
end

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

-- To Add or Update quest just do this
--Event_FireGenericEvent("QuestTrackedChanged", quest, true)

-- To Remove Quest just do this
--Event_FireGenericEvent("QuestTrackedChanged", quest, false)

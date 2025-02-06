-- Base Quest Class
QuestBase = {}
QuestBase.__index = QuestBase

counter = 0

function QuestBase:new(type, weight, finishInOneRound)
    local obj = setmetatable({}, self)
    obj.type = type
    obj.weight = tonumber(weight)
    obj.completed = false
    obj.rewardsClaimed = false
    obj.finishInOneRound = finishInOneRound
    counter = counter + 1
    obj.uniqueId = util.SHA256(tostring(os.time()) .. obj.type .. tostring(math.random()) .. tostring(counter))
    return obj
end

function QuestBase:Start(player, ...)
    self.player = player
    self:OnStart(...)
end

function QuestBase:OnStart(...)
    -- To be overridden by subclasses
end

function QuestBase:Update(...)
    -- To be overridden by subclasses
end

function QuestBase:Complete(quest)
    if not quest.completed then
        quest.completed = true
        PrintPink("Quest completed: " .. quest.type)
        self:OnComplete(quest)
    end
end

function QuestBase:OnComplete()
    -- To be overridden by subclasses
end
-- Base Quest Class
QuestBase = {}
QuestBase.__index = QuestBase

function QuestBase:new(type)
    local obj = setmetatable({}, self)
    obj.type = type
    obj.completed = false
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

function QuestBase:Complete()
    if not self.completed then
        self.completed = true
        PrintPink("Quest completed: " .. self.type)
        self:OnComplete()
    end
end

function QuestBase:OnComplete()
    -- To be overridden by subclasses
end
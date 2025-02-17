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

function QuestBase:newQuest(quest)
    if 
    not quest.args.type or 
    not quest.args.weight or 
    not quest.args.finishInOneRound then
        hook.Run("QuestNotEnoughArgs", "Please provide the quest type, weight, and wether its finished in one round or not!")
    end

    local obj = setmetatable({}, self)
    obj.type = type
    obj.weight = tonumber(quest.args.weight)
    obj.completed = false
    obj.rewardsClaimed = false
    obj.finishInOneRound = quests.args.finishInOneRound
    table.instert(obj.rewards, quest.args.pointRewards)
    table.instert(obj.rewards, quest.args.premPointRewards)
    table.instert(obj.rewards, quest.args.xpRewards)
    counter = counter + 1
    obj.uniqueId = util.SHA256(tostring(os.time()) .. obj.type .. tostring(math.random()) .. tostring(counter))
    return obj
end

function QuestBase:OnStart(...)
    -- To be overridden by subclasses
end

function QuestBase:Update(...)
    file.Write(activeQuestsDir, util.TableToJSON(QuestManager.activeQuests, true)) -- TODO: This now overwrites everything. See if it can be made more efficient finding and overriding only whats needed
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

function QuestBase:GiveRewards(quest)
    table.remove(QuestManager.activeQuests[quest.player:SteamID64()].quests, tableIndexByUniqueId(QuestManager.activeQuests[quest.player:SteamID64()].quests, quest.uniqueId))
    if #QuestManager.activeQuests[quest.player:SteamID64()].quests == 0 then QuestManager.activeQuests[quest.player:SteamID64()].finishedAll = true end
    file.Write(activeQuestsDir, util.TableToJSON(QuestManager.activeQuests, true))
    net.Start("SendQuestFinished")
    net.WriteTable(quest)
    net.Send(quest.player)
end
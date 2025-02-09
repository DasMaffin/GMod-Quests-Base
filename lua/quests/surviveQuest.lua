SurviveQuest = setmetatable({}, {__index = QuestBase})
SurviveQuest.__index = SurviveQuest

QuestManager.questTypes.SurviveQuest = SurviveQuest

function SurviveQuest:new(args)
    if not args[3] then
        PrintPink("Usage: AddQuest SurviveQuest [weight] [finishConsecutively] [rounds] {rewards}")
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("SurviveQuest", args[1], args[2])
    setmetatable(obj, self)

    for i = 1, 2 do
        table.remove(args, 1)
    end
    
    obj.requiredRounds = tonumber(args[1]) or 1
    obj.currentRounds = 0

    for i = 1, 1 do
        table.remove(args, 1)
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function SurviveQuest:Update(quest)
    quest.currentRounds = quest.currentRounds + 1    
    PrintPink("SurviveQuest progress: " .. quest.currentRounds .. "/" .. quest.requiredRounds)
    if quest.currentRounds >= quest.requiredRounds then
        SurviveQuest:Complete(quest)
    end
end

function SurviveQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the SurviveQuest!")
end

function SurviveQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink("Giving rewards for SurviveQuest to Player: " .. ply:Nick())
        ply:PS2_AddStandardPoints(tonumber(quest.rewards[1]))
        ply:PS2_AddPremiumPoints(tonumber(quest.rewards[2]))
        if LEVELSYSTEM then
            ply:AddXP(tonumber(quest.rewards[3]))
        end
        quest.rewardsClaimed = true
        QuestBase:GiveRewards(quest)
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[ply:SteamID64()])
        net.Send(ply)
    end
end

function SurviveQuest:RoundSurvived(quest)
    if not quest.completed and quest.type == "SurviveQuest" then
        SurviveQuest:Update(quest)
    end
end

function SurviveQuest:Reset(quest)
    if not quest.completed and quest.type == "SurviveQuest" then
        quest.currentRounds = 0
    end
end

hook.Add("TTTEndRound", "SurviveQuest_TTTEndRound", function(result)
    for key, activeQuests in pairs(QuestManager.activeQuests) do
        for _, quest in ipairs(activeQuests) do
            local ply = FindPlayerBySteamID64(key)
            if ply and not ply:IsSpec() and not quest.completed then
                SurviveQuest:RoundSurvived(quest)
            elseif ply and ply:IsSpec() and not quest.completed and quest.finishInOneRound ~= "0" then
                SurviveQuest:Reset(quest)
            end
        end
    end
end)

KarmaQuest = setmetatable({}, {__index = QuestBase})
KarmaQuest.__index = KarmaQuest

QuestManager.questTypes.KarmaQuest = KarmaQuest

function KarmaQuest:new(args)
    if not args[3] || not args[4] then
        PrintPink("Usage: AddQuest KarmaQuest [weight] [finishConsecutively] [minKarma] [rounds] {rewards}")
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("KarmaQuest", args[1], args[2])
    setmetatable(obj, self)

    for i = 1, 2 do
        table.remove(args, 1)
    end
    
    obj.minKarma = tonumber(args[1]) or 1
    obj.requiredRounds = tonumber(args[2]) or 1
    obj.currentRounds = 0

    for i = 1, 2 do
        table.remove(args, 1)
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function KarmaQuest:Update(quest)
    quest.currentRounds = quest.currentRounds + 1    
    PrintPink("KarmaQuest progress: " .. quest.currentRounds .. "/" .. quest.requiredRounds)
    if quest.currentRounds >= quest.requiredRounds then
        KarmaQuest:Complete(quest)
    end
    QuestBase:Update(quest)
end

function KarmaQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the KarmaQuest!")
end

function KarmaQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink("Giving rewards for KarmaQuest to Player: " .. ply:Nick())
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

function KarmaQuest:RoundComplete(quest)
    if not quest.completed and quest.type == "KarmaQuest" and IsValid(quest.player) and quest.player:GetBaseKarma() >= quest.minKarma then
        KarmaQuest:Update(quest)
    elseif not quest.completed and quest.type == "KarmaQuest" and quest.finishInOneRound and quest.finishInOneRound ~= "0" then
        KarmaQuest:Reset(quest)
    end
end

function KarmaQuest:Reset(quest)
    if not quest.completed and quest.type == "KarmaQuest" then
        quest.currentRounds = 0
    end
end

hook.Add("TTTEndRound", "KarmaQuest_TTTEndRound", function(result)
    for key, activeQuests in pairs(QuestManager.activeQuests) do
        for _, quest in ipairs(activeQuests) do
            KarmaQuest:RoundComplete(quest)
        end
    end
end)

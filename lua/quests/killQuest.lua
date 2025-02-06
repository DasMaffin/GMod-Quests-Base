-- KillQuest Class
KillQuest = setmetatable({}, {__index = QuestBase})
KillQuest.__index = KillQuest

function KillQuest:new(args)
    if not args[3] || args[3] == 0 || not args[4] || not args[5] then
        PrintPink("Usage: AddQuest KillQuest [weight] [finishInOneRound] [requiredKills] [roleToBeKilled] [roleForKiller] {rewards}")
        PrintPink("Innocent: " .. ROLE_INNOCENT)
        PrintPink("Traitor: " .. ROLE_TRAITOR)
        PrintPink("Detective: " .. ROLE_DETECTIVE)
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("KillQuest", args[1], args[2])
    setmetatable(obj, self)

    for i = 1, 2 do
        table.remove(args, 1)
    end
    
    obj.requiredKills = tonumber(args[1]) or 1
    obj.killedRole = args[2]
    obj.killerRole = args[3]
    obj.currentKills = 0

    for i = 1, 3 do
        table.remove(args, 1)
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function KillQuest:Update(quest)
    quest.currentKills = quest.currentKills + 1    
    PrintPink("KillQuest progress: " .. quest.currentKills .. "/" .. quest.requiredKills)
    if quest.currentKills >= quest.requiredKills then
        KillQuest:Complete(quest)
    end
end

function KillQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the KillQuest!")
end

function KillQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink(quest.rewardsClaimed)
        PrintPink("Giving rewards for KillQuest to Player: " .. ply:Nick())
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

function KillQuest:PlayerKilled(quest)
    if not quest.completed and quest.type == "KillQuest" then
        KillQuest:Update(quest)
    end
end

-- Hook to Track Player Kills
hook.Add("PlayerDeath", "KillQuest_PlayerDeath", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker:SteamID64() ~= "90071996842377216"  then
        for _, quest in ipairs(QuestManager.activeQuests[attacker:SteamID64()]) do
            if quest.killerRole == tostring(attacker:GetRole()) and quest.killedRole == tostring(victim:GetRole()) then
                KillQuest:PlayerKilled(quest)
            end
        end
    end
end)

hook.Add("TTTEndRound", "KillQuest_TTTEndRound", function(result)
    for key, activeQuests in pairs(QuestManager.activeQuests) do
        for _, quest in ipairs(activeQuests) do
            if quest.finishInOneRound ~= "0" and not quest.completed then
                quest.currentKills = 0
            end
        end
    end
end)

WalkerQuest = setmetatable({}, {__index = QuestBase})
WalkerQuest.__index = WalkerQuest

QuestManager.questTypes.WalkerQuest = WalkerQuest

function WalkerQuest:new(args)
    if not args[2] || args[2] == 0 then
        PrintPink("Usage: AddQuest WalkerQuest [weight] [finishInOneRound] [requiredSteps] {rewards}")
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("WalkerQuest", args[1], args[2])
    setmetatable(obj, self)

    for i = 1, 2 do
        table.remove(args, 1)
    end

    obj.requiredSteps = tonumber(args[1]) or 1
    obj.currentSteps = 0

    for i = 1, 1 do
        table.remove(args, 1)
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function WalkerQuest:newQuest(quest)
    if not quest.args or not quest.args.requiredSteps then
        hook.Run("QuestNotEnoughArgs", "Please Provide the quests steps!")
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:newQuest(quest)
    setmetatable(obj, self)

    obj.requiredSteps = quest.args.requiredSteps
    obj.currentSteps = 0
end

function WalkerQuest:Update(quest, steps)
    if not quest.completed then
        quest.currentSteps = quest.currentSteps + steps
        PrintPink("WalkQuest progress: " .. quest.currentSteps .. "/" .. quest.requiredSteps)
        if quest.currentSteps >= quest.requiredSteps then
            WalkerQuest:Complete(quest)
        end
    end
    QuestBase:Update(quest)
end

function WalkerQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the WalkerQuest!")
end

function WalkerQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink("Giving rewards for WalkerQuest to Player: " .. ply:Nick())
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

if SERVER then
    -- Table to store players' previous positions
    local playerPreviousPositions = {}
    local unitsPerStep = 76
    -- Hook to calculate distance walked
    hook.Add("Move", "WalkerQuestMoveUpdate", function(ply, mv)
        if not ply:IsSpec() and GetRoundState() == ROUND_ACTIVE and ply:SteamID64() ~= "90071996842377216" then
            local currentPos = ply:GetPos()
            if playerPreviousPositions[ply] == nil then
                playerPreviousPositions[ply] = {}
                playerPreviousPositions[ply].distance = 0
            end
            local previousPos = playerPreviousPositions[ply].prevPos

            if previousPos and previousPos ~= currentPos and QuestManager.activeQuests[ply:SteamID64()] then
                local distance = currentPos:Distance(previousPos)
                playerPreviousPositions[ply].distance = playerPreviousPositions[ply].distance + distance
                if playerPreviousPositions[ply].distance >= unitsPerStep * GetConVar("max_steps_per_frame"):GetInt() then
                    playerPreviousPositions[ply].distance = 0
                end
                while playerPreviousPositions[ply].distance >= unitsPerStep do
                    for _, quest in ipairs(QuestManager.activeQuests[ply:SteamID64()].quests) do
                        if quest.type == "WalkerQuest" then
                            WalkerQuest:Update(quest, 1)
                        end
                    end
            
                    playerPreviousPositions[ply].distance = playerPreviousPositions[ply].distance - unitsPerStep
                end
            end

            playerPreviousPositions[ply].prevPos = currentPos
        end
    end)

    hook.Add("TTTEndRound", "WalkerQuest_TTTEndRound", function(result)
        for key, activeQuests in pairs(QuestManager.activeQuests) do
            for _, quest in ipairs(activeQuests.quests) do
                if quest.finishInOneRound ~= "0" and not quest.completed then
                    quest.currentSteps = 0
                end
            end
        end
        for playerkey, position in pairs(playerPreviousPositions) do
            position.prevPos = nil
            position.distance = 0
        end
    end)
end
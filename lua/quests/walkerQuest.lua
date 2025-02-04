WalkerQuest = setmetatable({}, {__index = QuestBase})
WalkerQuest.__index = WalkerQuest

function WalkerQuest:new(args)
    if not args[2] || args[2] == 0 then
        PrintPink("Usage: AddQuest WalkerQuest [weight] [requiredSteps] {rewards}")
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("WalkerQuest", args[1])
    setmetatable(obj, self)
    obj.requiredSteps = tonumber(args[2]) or 1
    obj.currentSteps = 0
    for i = 1, 2 do
        table.remove(args, 1)
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function WalkerQuest:OnStart(quest)
    self.requiredSteps = tonumber(quest.requiredSteps) or 1
    self.currentSteps = 0
    PrintPink("WalkerQuest started:")
    PrintPink("Walk " .. self.requiredSteps ..".")
end

function WalkerQuest:Update(quest, steps)
    if not quest.completed then
        quest.currentSteps = quest.currentSteps + steps
        PrintPink("WalkQuest progress: " .. quest.currentSteps .. "/" .. quest.requiredSteps)
        if quest.currentSteps >= quest.requiredSteps then
            WalkerQuest:Complete(quest)
        end
    end
end

function WalkerQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the WalkerQuest!")
end

function WalkerQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink(quest.rewardsClaimed)
        PrintPink("Giving rewards for KillQuest to Player: " .. ply:Nick())
        ply:PS2_AddStandardPoints(tonumber(quest.rewards[1]))
        ply:PS2_AddPremiumPoints(tonumber(quest.rewards[2]))
        if LEVELSYSTEM then
            ply:AddXP(tonumber(quest.rewards[3]))
        end
        quest.rewardsClaimed = true
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

            if previousPos and previousPos ~= currentPos then
                local distance = currentPos:Distance(previousPos)
                playerPreviousPositions[ply].distance = playerPreviousPositions[ply].distance + distance
                while playerPreviousPositions[ply].distance >= unitsPerStep do
                    for _, quest in ipairs(QuestManager.activeQuests[ply:SteamID64()]) do
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
end
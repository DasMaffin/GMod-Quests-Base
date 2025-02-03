WalkerQuest = setmetatable({}, {__index = QuestBase})
WalkerQuest.__index = WalkerQuest

function WalkerQuest:new(args)
    if not args[2] || args[2] == 0 || not args[3] || not args[4] then
        PrintPink("Usage: AddQuest WalkerQuest [requiredSteps]")
        PrintPink("Innocent: " .. ROLE_INNOCENT)
        PrintPink("Traitor: " .. ROLE_TRAITOR)
        PrintPink("Detective: " .. ROLE_DETECTIVE)
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("WalkerQuest", args[1])
    setmetatable(obj, self)
    obj.requiredKills = tonumber(args[2]) or 1
    obj.killedRole = args[3]
    obj.killerRole = args[4]
    obj.currentKills = 0
    for i = 1, 3 do
        table.remove(args, 1) -- Always remove the first element
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end
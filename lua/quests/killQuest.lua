-- KillQuest Class
KillQuest = setmetatable({}, {__index = QuestBase})
KillQuest.__index = KillQuest

function KillQuest:new(requiredKills, killedRole, killerRole)
    if not requiredKills || requiredKills == 0 || not killedRole || not killerRole then
        PrintPink("Usage: AddQuest <QuestType> [requiredKills] [roleToBeKilled] [roleForKiller]")
        PrintPink("Innocent: " .. ROLE_INNOCENT)
        PrintPink("Traitor: " .. ROLE_TRAITOR)
        PrintPink("Detective: " .. ROLE_DETECTIVE)
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("KillQuest")
    setmetatable(obj, self)
    obj.requiredKills = tonumber(requiredKills) or 1
    obj.killedRole = killedRole
    obj.killerRole = killerRole
    obj.currentKills = 0
    
    return obj
end

function KillQuest:OnStart(requiredKills, killedRole, killerRole)
    self.requiredKills = tonumber(requiredKills) or 1
    self.killedRole = killedRole
    self.killerRole = killerRole
    self.currentKills = 0
    PrintPink("KillQuest started:")
    PrintPink("Kill " .. self.requiredKills .. " " .. self.killedRole .. ".")
    PrintPink("As role: " .. self.killerRole)
end

function KillQuest:Update()
    self.currentKills = self.currentKills + 1
    PrintPink("KillQuest progress: " .. self.currentKills .. "/" .. self.requiredKills)
    if self.currentKills >= self.requiredKills then
        self:Complete()
    end
end

function KillQuest:OnComplete()
    PrintPink("Congratulations! You completed the KillQuest by killing " .. self.requiredKills .. " players.")
end

function KillQuest:PlayerKilled(player, victim)
    for _, quest in ipairs(self.activeQuests) do
        if not quest.completed and quest.type == "KillQuest" and quest.player == player then
            quest:Update()
        end
    end
end

-- Hook to Track Player Kills
hook.Add("PlayerDeath", "KillQuest_PlayerDeath", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        KillQuest:PlayerKilled(attacker, victim)
    end
end)

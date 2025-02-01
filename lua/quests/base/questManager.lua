QuestManager = {
    availableQuests = {},
    activeQuests = {},
    questTypes = {
        KillQuest = KillQuest
    }
}

if SERVER then
    util.AddNetworkString("AddQuest")
    util.AddNetworkString("NotifyServerOfClientReady")
    util.AddNetworkString("SynchronizeActiveQuests")
    util.AddNetworkString("ClaimRewards")

    function QuestManager:AddQuest(player, questType, ...)
        local quest
        local questClass = QuestManager.questTypes[questType]

        if questClass then
            quest = questClass:new(...)
        else
            PrintPink("Unknown quest type: " .. questType)
            return
        end

        table.insert(QuestManager.availableQuests, quest)
        file.Write(questsDir, util.TableToJSON(QuestManager.availableQuests, true)) 

        PrintPink("Quest added: " .. quest.type)
    end

    net.Receive("AddQuest", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local questType = net.ReadString()
        local args = net.ReadTable()

        QuestManager:AddQuest(ply, questType, unpack(args))
    end)

    net.Receive("NotifyServerOfClientReady", function(len, ply)
        local steamID = ply:SteamID64()
        if QuestManager.activeQuests[steamID] and #QuestManager.activeQuests[steamID] > 0 then
            -- send quests to player
        else
            if #QuestManager.availableQuests > 0 then
                QuestManager.activeQuests[steamID] = {}
                table.insert(QuestManager.activeQuests[steamID], QuestManager.availableQuests[math.random(1, #QuestManager.availableQuests)])
                table.insert(QuestManager.activeQuests[steamID], QuestManager.availableQuests[math.random(1, #QuestManager.availableQuests)])
            end
        end
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[steamID])
        net.Send(ply)
    end)

    net.Receive("ClaimRewards", function(len, ply)
        local quest = net.ReadTable()
        KillQuest:GiveRewards(quest, ply)
    end)
end

if CLIENT then
    -- Console Command to Add Quest
    concommand.Add("AddQuest", function(ply, cmd, args)
        if not args[1] then
            PrintPink("Usage: AddQuest <QuestType> [parameters]")
            return
        end

        local questType = args[1]
        table.remove(args, 1)
        net.Start("AddQuest")
        net.WriteString(questType)
        net.WriteTable(args)
        net.SendToServer()
    end)

    net.Receive("SynchronizeActiveQuests", function(len)
        local quests = net.ReadTable()
        hook.Run("QuestsUpdated", quests)
    end)

    hook.Add("InitPostEntity", "NotifyServerOfClientReady", function()
        net.Start("NotifyServerOfClientReady")
        net.SendToServer()
    end)
end
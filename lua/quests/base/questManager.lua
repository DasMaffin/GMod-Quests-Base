QuestManager = {
    availableQuests = {},
    activeQuests = {},
    questTypes = {
        KillQuest = KillQuest
    }
}

if SERVER then
    util.AddNetworkString("AddQuest")

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
        -- file.Write("quests/quests.json", util.TableToJSON(quest))
        file.Write(questsDir, util.TableToJSON(QuestManager.availableQuests, true)) 

        -- quest:Start(player, ...)
        -- if quest.DidntFinishInit == true then
        --     return
        -- end
        -- table.insert(self.activeQuests, quest)
        PrintPink("Quest added: " .. quest.type)
    end

    net.Receive("AddQuest", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local questType = net.ReadString()
        local args = net.ReadTable()

        QuestManager:AddQuest(ply, questType, unpack(args))
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
end
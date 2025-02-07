QuestManager = {
    availableQuests = {},
    activeQuests = {},
    questTypes = {
        KillQuest = KillQuest,
        WalkerQuest = WalkerQuest
    }
}

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig))) -- Preserve metatable if it exists

        -- Check if the table has a uniqueId field and update it
        if copy.uniqueId then
            copy.uniqueId = util.SHA256(tostring(os.time()) .. tostring(math.random()) .. tostring(counter))
        end
    else
        copy = orig
    end
    counter = counter + 1
    return copy
end

function totalQuestsWeight(quests)
    local totalWeight = 0
    for _, quest in ipairs(quests) do
        totalWeight = totalWeight + quest.weight
    end
    return totalWeight
end

if SERVER then
    util.AddNetworkString("AddQuest")
    util.AddNetworkString("NotifyServerOfClientReady")
    util.AddNetworkString("SynchronizeActiveQuests")
    util.AddNetworkString("ClaimRewards")
    util.AddNetworkString("QuestMenuOpened")
    util.AddNetworkString("SendQuestFinished")

    function QuestManager:AddQuest(player, questType, args)
        local quest
        local questClass = QuestManager.questTypes[questType]
        if questClass then
            quest = questClass:new(args)
        else
            PrintPink("Unknown quest type: " .. questType)
            return
        end
        if not quest or quest.DidntFinishInit and quest.DidntFinishInit == true then return end

        table.insert(QuestManager.availableQuests, quest)
        file.Write(questsDir, util.TableToJSON(QuestManager.availableQuests, true)) 

        PrintPink("Quest added: " .. quest.type)
    end

    net.Receive("AddQuest", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local questType = net.ReadString()
        local args = net.ReadTable()

        QuestManager:AddQuest(ply, questType, args)
    end)

    net.Receive("NotifyServerOfClientReady", function(len, ply)
        local steamID = ply:SteamID64()
        if not QuestManager.activeQuests[steamID] or not #QuestManager.activeQuests[steamID] > 0 then
            if #QuestManager.availableQuests > 0 then
                QuestManager.activeQuests[steamID] = {}
                local questsToChoseFrom = DeepCopy(QuestManager.availableQuests)
                for i = 1, 3 do -- The amount of quests given.
                    local questChosen
                    local totalQuestsWeight = totalQuestsWeight(questsToChoseFrom)
                    for _, quest in ipairs(questsToChoseFrom) do
                        if math.random(1, totalQuestsWeight) <= quest.weight then
                            questChosen = quest
                            break
                        else
                            totalQuestsWeight = totalQuestsWeight - quest.weight
                        end
                    end
                    questChosen.player = ply
                    PrintTable(questChosen)
                    table.insert(QuestManager.activeQuests[steamID], DeepCopy(questChosen))
                    table.RemoveByValue(questsToChoseFrom, questChosen)
                end
            end
        end
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[steamID])
        net.Send(ply)
    end)

    net.Receive("ClaimRewards", function(len, ply)
        local quest = net.ReadTable()
        QuestManager.activeQuests[ply:SteamID64()][tableIndexByUniqueId(QuestManager.activeQuests[ply:SteamID64()], quest.uniqueId)] = quest
        QuestManager.questTypes[quest.type]:GiveRewards(quest, ply)
    end)

    net.Receive("QuestMenuOpened", function(len, ply)
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[ply:SteamID64()])
        net.Send(ply)
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
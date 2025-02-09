QuestManager = {
    availableQuests = {},
    activeQuests = {},
    questTypes = {
    }
}

function DeepCopy(orig, seen)
    -- Initialize the "seen" table if it doesn't exist
    seen = seen or {}

    -- Check if the table has already been copied
    if seen[orig] then
        return seen[orig]
    end

    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        -- Create a new table and mark it as seen
        copy = {}
        seen[orig] = copy

        -- Copy all keys and values recursively
        for orig_key, orig_value in pairs(orig) do
            copy[DeepCopy(orig_key, seen)] = DeepCopy(orig_value, seen)
        end

        -- Copy the metatable (if it exists)
        local mt = getmetatable(orig)
        if mt then
            setmetatable(copy, DeepCopy(mt, seen))
        end

        -- Update uniqueId if it exists
        if copy.uniqueId then
            copy.uniqueId = util.SHA256(tostring(os.time()) .. tostring(math.random()) .. tostring(counter))
        end
    else
        -- Non-table values are copied directly
        copy = orig
    end

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
    util.AddNetworkString("RerollQuests")

    local function RerollQuests(ply)
        local steamID = ply:SteamID64()
        if #QuestManager.availableQuests > 0 then
            QuestManager.activeQuests[steamID] = {}
            local questsToChoseFrom = DeepCopy(QuestManager.availableQuests)
            for i = 1, math.min(6, #QuestManager.availableQuests) do -- The amount of quests given.
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
                table.insert(QuestManager.activeQuests[steamID], DeepCopy(questChosen))
                table.RemoveByValue(questsToChoseFrom, questChosen)
            end
            net.Start("SynchronizeActiveQuests")
            net.WriteTable(QuestManager.activeQuests[steamID])
            net.Send(ply)
        end
    end 

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
        if not QuestManager.activeQuests[steamID] or not #QuestManager.activeQuests[steamID] > 0 then
            RerollQuests(ply)        
        end
    end)

    net.Receive("ClaimRewards", function(len, ply)
        local quest = net.ReadTable()
        local pQuests = QuestManager.activeQuests[ply:SteamID64()]
        local questIndex = tableIndexByUniqueId(pQuests, quest.uniqueId)
        if pQuests[questIndex] then
            pQuests[questIndex] = quest
            QuestManager.questTypes[quest.type]:GiveRewards(quest, ply)
        end
    end)

    net.Receive("QuestMenuOpened", function(len, ply)
        if QuestManager.activeQuests[ply:SteamID64()] and #QuestManager.activeQuests[ply:SteamID64()] > 0 then
            net.Start("SynchronizeActiveQuests")
            net.WriteTable(QuestManager.activeQuests[ply:SteamID64()])
            net.Send(ply)
        end
    end)

    net.Receive("RerollQuests", function(len, ply)
        RerollQuests(ply)
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

    concommand.Add("RerollQuests", function(ply, cmd, args)
        net.Start("RerollQuests")
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
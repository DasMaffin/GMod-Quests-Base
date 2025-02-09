QuestManager.finishedQuests = {}

if file.Exists(questsDir, "DATA") then
    QuestManager.finishedQuests = util.JSONToTable(file.Read(questsDir, "DATA"), true, true)
    hook.Add( "InitPostEntity", "some_unique_name", function()	
        hook.Run("UpdateFinishedQuests", QuestManager.finishedQuests)
    end )
end

net.Receive("SendQuestFinished", function(len)
    local quests = net.ReadTable()
    quests.completionTime = os.time()
    table.insert(QuestManager.finishedQuests, quests)
    file.Write(questsDir, util.TableToJSON(QuestManager.finishedQuests, true)) 
    hook.Run("UpdateFinishedQuests", QuestManager.finishedQuests)
end)

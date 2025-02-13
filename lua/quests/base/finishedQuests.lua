QuestManager.finishedQuests = {}

if file.Exists(questsDir, "DATA") then
    QuestManager.finishedQuests = util.JSONToTable(file.Read(questsDir, "DATA"), true, true)
end

net.Receive("SendQuestFinished", function(len)
    local quests = net.ReadTable()
    quests.completionTime = os.time()
    table.insert(QuestManager.finishedQuests, quests)
    file.Write(questsDir, util.TableToJSON(QuestManager.finishedQuests, true)) 
    hook.Run("UpdateFinishedQuests", QuestManager.finishedQuests)
    hook.Run("sendClaimedRewards", quests.rewards)
end)

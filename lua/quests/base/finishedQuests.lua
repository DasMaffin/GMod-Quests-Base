QuestManager.finishedQuests = {}

net.Receive("SendQuestFinished", function(len)
    local quests = net.ReadTable()
    quests.completionTime = os.time()
    table.insert(QuestManager.finishedQuests, quests)
    hook.Run("UpdateFinishedQuests", QuestManager.finishedQuests)
end)
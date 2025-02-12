local path = "quests/"

if not file.Exists(path, "LUA") then
    PrintPinkLL("Path not found: " .. path, 1)
    return nil
end

local files, _ = file.Find(path .. "*", "LUA")

local filePaths = {}

for _, fileName in ipairs(files) do
    if string.match(fileName, ".lua") then
        table.insert(filePaths, path .. fileName)
    end
end

for _, filePath in ipairs(filePaths) do
    
    AddCSLuaFile(filePath)

    include(filePath)
    PrintPinkLL("Loaded quests for \"" .. filePath .. "\"", 1)
end

if file.Exists(questsDir, "DATA") then
    QuestManager.availableQuests = util.JSONToTable(file.Read(questsDir, "DATA"), true, true)
else
    QuestManager.availableQuests = {}
end

if file.Exists(activeQuestsDir, "DATA") then
    QuestManager.activeQuests = util.JSONToTable(file.Read(activeQuestsDir, "DATA"), true, true)
else
    QuestManager.activeQuests = {}
end
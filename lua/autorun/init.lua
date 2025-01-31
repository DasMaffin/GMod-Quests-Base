function PrintPink(...)
    MsgC(Color(255, 105, 180), "[Quests] ", Color(255, 182, 193), ..., "\n") -- HotPink and LightPink
end

PrintPink("----------==============================----------")
PrintPink("Starting Quest System")


questsDir = "quests/quests.json"

AddCSLuaFile("quests/base/questBase.lua")
AddCSLuaFile("quests/base/loadQuests.lua")
AddCSLuaFile("UI/base/baseHUD.lua")
AddCSLuaFile("UI/killQuestHUD.lua")

include("quests/base/questBase.lua")
include("quests/base/loadQuests.lua")


if(SERVER) then
    file.CreateDir("quests")
else
    include("UI/base/baseHUD.lua")
    include("UI/killQuestHUD.lua") 

    hook.Add("OnGamemodeLoaded", "OnQuestsGamemodeLoaded", function()
        PrintPink("Gamemode loaded")        
        CreateBaseHUD()
    end)
end

PrintPink("Quest System Loaded")
PrintPink("----------==============================----------")
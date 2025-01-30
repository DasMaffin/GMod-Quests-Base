function PrintPink(...)
    MsgC(Color(255, 105, 180), "[Quests] ", Color(255, 182, 193), ..., "\n") -- HotPink and LightPink
end

PrintPink("----------==============================----------")
PrintPink("Starting Quest System")

AddCSLuaFile("quests/base/questBase.lua")
AddCSLuaFile("quests/base/questManager.lua")
AddCSLuaFile("quests/base/loadQuests.lua")

include("quests/base/questBase.lua")
include("quests/base/loadQuests.lua")

include("quests/base/questManager.lua")

if(SERVER) then
    file.CreateDir("quests")
end

PrintPink("Quest System Loaded")
PrintPink("----------==============================----------")
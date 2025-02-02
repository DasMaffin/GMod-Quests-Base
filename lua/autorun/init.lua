function PrintPink(...)
    MsgC(Color(255, 105, 180), "[Quests] ", Color(255, 182, 193), ..., "\n") -- HotPink and LightPink
end

function tableIndexByUniqueId(tbl, id)
    for i, v in ipairs(tbl) do        
        if v.uniqueId == id then
            return i
        end
    end
    return nil -- Entry not found
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

    hook.Add("InitPostEntity", "OnQuestsGamemodeLoaded", function()
        surface.CreateFont("CustomFont", {
            font = "Arial", -- Font face (e.g., Arial, Roboto, etc.)
            size = 30,      -- Font size in pixels
            weight = 700,   -- Font weight (e.g., 500 for normal, 700 for bold)
            antialias = true, -- Enable smooth edges
        })
        CreateBaseHUD()
    end)
end

PrintPink("Quest System Loaded")
PrintPink("----------==============================----------")
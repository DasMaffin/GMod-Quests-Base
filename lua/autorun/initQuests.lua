function PrintPinkLL(msg, logLevel)
    if logLevel > 0 then
        MsgC(Color(255, 105, 180), "[Quests] ", Color(255, 182, 193), msg, "\n") -- HotPink and LightPink
    end
end

function PrintPink(msg)
    PrintPinkLL(msg, 0)
end

function tableIndexByUniqueId(tbl, id)
    for i, v in ipairs(tbl) do        
        if v.uniqueId == id then
            return i
        end
    end
    return nil -- Entry not found
end

function FindPlayerBySteamID64(steamid64)
    -- Loop through all players on the server
    for _, ply in ipairs(player.GetAll()) do
        -- Check if the player's SteamID64 matches the one we're looking for
        if ply:SteamID64() == steamid64 then
            return ply -- Return the player if found
        end
    end
    return nil -- Return nil if no player is found
end

PrintPinkLL("----------==============================----------", 1)
PrintPinkLL("Starting Quest System", 1)

if SERVER then 
    resource.AddWorkshop("3424588083")
end

questsDir = "quests/quests.json"
activeQuestsDir = "quests/activeQuests.json"
file.CreateDir("quests")

CreateConVar("quests_startingQuests", "1", FCVAR_NOTIFY)
CreateConVar("daily_reroll_time", "00:00", FCVAR_NOTIFY, "Time of day to execute the function (HH:MM)")

AddCSLuaFile("quests/base/questBase.lua")
AddCSLuaFile("quests/base/questManager.lua")
AddCSLuaFile("quests/base/loadQuests.lua")
AddCSLuaFile("quests/base/finishedQuests.lua")

AddCSLuaFile("UI/base/claimButton.lua") 
AddCSLuaFile("UI/base/baseHUD.lua")
AddCSLuaFile("UI/base/baseQuestCardHUDNoButton.lua")
AddCSLuaFile("UI/base/baseQuestCardHUD.lua")
AddCSLuaFile("UI/KillQuestHUD.lua")
AddCSLuaFile("UI/WalkerQuestHUD.lua") 
AddCSLuaFile("UI/SurviveQuestHUD.lua") 
AddCSLuaFile("UI/KarmaQuestHUD.lua") 

include("quests/base/questBase.lua")
include("quests/base/questManager.lua")
include("quests/base/loadQuests.lua")


if SERVER then
else
    include("UI/base/claimButton.lua") 
    include("UI/base/baseHUD.lua")
    include("UI/base/baseQuestCardHUDNoButton.lua")
    include("UI/base/baseQuestCardHUD.lua")
    include("UI/KillQuestHUD.lua") 
    include("UI/WalkerQuestHUD.lua") 
    include("UI/SurviveQuestHUD.lua") 
    include("UI/KarmaQuestHUD.lua") 
    include("quests/base/finishedQuests.lua")

    hook.Add("InitPostEntity", "OnQuestsGamemodeLoaded", function()
        surface.CreateFont("CustomFont", {
            font = "Arial", -- Font face (e.g., Arial, Roboto, etc.)
            size = 30,      -- Font size in pixels
            weight = 700,   -- Font weight (e.g., 500 for normal, 700 for bold)
            antialias = true, -- Enable smooth edges
        })
        surface.CreateFont("DermaBold", {
            font = "Tahoma", -- Font face (e.g., Arial, Roboto, etc.)
            size = 13,      -- Font size in pixels
            weight = 700,   -- Font weight (e.g., 500 for normal, 700 for bold)
            antialias = true, -- Enable smooth edges
        })
        CreateBaseHUD()
    end)
end

PrintPinkLL("Quest System Loaded", 1)
PrintPinkLL("----------==============================----------", 1)
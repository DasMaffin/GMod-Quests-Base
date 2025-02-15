function PrintPinkLL(msg, logLevel)
    if logLevel > 0 then
        MsgC(Color(255, 105, 180), "[Quests] ", Color(255, 182, 193), msg, "\n")
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

function bool_to_number(value)
    return value and 1 or 0
end  

if SERVER then 
    resource.AddWorkshop("3424588083")
end

questsDir = "quests/quests.json"
activeQuestsDir = "quests/activeQuests.json"
file.CreateDir("quests")

CreateConVar("quests_startingQuests", "1", FCVAR_NOTIFY)
CreateConVar("daily_reroll_time", "00:00", FCVAR_NOTIFY, "Time of day to execute the function (HH:MM)")
CreateConVar("max_steps_per_frame", "9", FCVAR_NOTIFY, "The maximum allowed steps per frame. Else it will not count at all.")

AddCSLuaFile("ui/admin/questList.lua")
AddCSLuaFile("ui/admin/questEditor.lua")
AddCSLuaFile("ui/base/adminBaseHUD.lua")
AddCSLuaFile("ui/base/baseHUD.lua")
AddCSLuaFile("ui/base/claimButton.lua")
AddCSLuaFile("ui/base/baseQuestCardHUDNoButton.lua")
AddCSLuaFile("ui/base/baseQuestCardHUD.lua")
AddCSLuaFile("ui/base/displayClaimedRewardsHUD.lua")
AddCSLuaFile("ui/KillQuestHUD.lua")
AddCSLuaFile("ui/WalkerQuestHUD.lua")
AddCSLuaFile("ui/SurviveQuestHUD.lua")
AddCSLuaFile("ui/KarmaQuestHUD.lua")

AddCSLuaFile("quests/base/questBase.lua")
AddCSLuaFile("quests/base/questManager.lua")
AddCSLuaFile("quests/base/loadQuests.lua")
AddCSLuaFile("quests/base/finishedQuests.lua")

AddCSLuaFile("cl/chatCommands.lua")

AddCSLuaFile("UI/base/claimButton.lua") 
AddCSLuaFile("ui/base/adminBaseHUD.lua")
AddCSLuaFile("UI/base/baseHUD.lua")
AddCSLuaFile("UI/base/baseQuestCardHUDNoButton.lua")
AddCSLuaFile("UI/base/baseQuestCardHUD.lua")
AddCSLuaFile("ui/base/displayClaimedRewardsHUD.lua")
AddCSLuaFile("UI/KillQuestHUD.lua")
AddCSLuaFile("UI/WalkerQuestHUD.lua") 
AddCSLuaFile("UI/SurviveQuestHUD.lua") 
AddCSLuaFile("UI/KarmaQuestHUD.lua") 

include("quests/base/questBase.lua")
include("quests/base/questManager.lua")
include("quests/base/loadQuests.lua")
include("cl/chatCommands.lua")


if SERVER then
else
    include("ui/admin/questList.lua")
    include("ui/admin/questEditor.lua")
    include("ui/base/adminBaseHUD.lua")
    include("ui/base/baseHUD.lua")
    include("ui/base/claimButton.lua")
    include("ui/base/baseQuestCardHUDNoButton.lua")
    include("ui/base/baseQuestCardHUD.lua")
    include("ui/base/displayClaimedRewardsHUD.lua")
    include("ui/KillQuestHUD.lua")
    include("ui/WalkerQuestHUD.lua")
    include("ui/SurviveQuestHUD.lua")
    include("ui/KarmaQuestHUD.lua")
    include("quests/base/finishedQuests.lua")

    hook.Add("InitPostEntity", "OnQuestsGamemodeLoaded", function()
        surface.CreateFont("CustomFont", {
            font = "Arial",
            size = 30,
            weight = 700,
            antialias = true,
        })
        surface.CreateFont("DermaBold", {
            font = "Tahoma",
            size = 13,
            weight = 700,
            antialias = true,
        })
        surface.CreateFont("DermaLargeCustom", {
            font = "Tahoma",
            size = 36,
            weight = 700,
            antialias = true,
        })

        CreateBaseHUD()
    end)
end

PrintPinkLL("Quest System Loaded", 1)
PrintPinkLL("----------==============================----------", 1)
if SERVER then
    ULib.ucl.registerAccess("quests.manage", "superadmin", "Allows managing Quests", "Quests")
end

-- local rerollCommand = ulx.command("TTT Quest", "ulx rerollquests", AssignDailyQuest, "!rerollquests")
-- rerollCommand:defaultAccess("superadmin")
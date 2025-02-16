hook.Add("OnPlayerChat", "QueueChatCommand", function(ply, text, teamChat, isDead)
    local input = string.lower(text)
    if input == "!quest" or input == "!quests"  then
        OpenQuestMenu()
        return true
    end        
end)
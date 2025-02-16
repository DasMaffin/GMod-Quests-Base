hook.Add("OnPlayerChat", "QueueChatCommand", function(ply, text, teamChat, isDead)
    local input = string.lower(text)
    if input == "!quest" or input == "!quests"  then
        if ply == LocalPlayer() then
            OpenQuestMenu()
        end
        return true
    end        
end)
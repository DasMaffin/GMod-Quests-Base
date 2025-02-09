local PANEL = {}

function PANEL:Init()
    
end

function PANEL:InitWithArgs(hasButton)
    if hasButton == true then
        BaseQuestCard.Init(self)
    else
        BaseQuestCardNoButton.Init(self)
    end
end

local function getRoleString(roleValue)
    if roleValue == 0 or roleValue == "0" then
        return "<color=0,255,0>Innocent</color>" -- Green
    elseif roleValue == 1 or roleValue == "1" then
        return "<color=255,0,0>Traitor</color>" -- Red
    elseif roleValue == 2 or roleValue == "2" then
        return "<color=0,0,255>Detective</color>" -- Blue
    else
        return "<color=255,255,255>Unknown</color>" -- Fallback (white)
    end
end

function PANEL:SetQuest(data)
    self.title:SetText(data.title or "Kill Quest")
    self.requirementLabel:SetText(("Required Kills: %d"):format(data.requiredKills or 0))
    self.progressLabel:SetText(("  |  Kills: %d"):format(data.currentKills or 0))
    local descriptionMarkupText
    if LEVELSYSTEM then
        descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must kill %d </color>%s<color=255,255,255> as </color>%s\n\n<color=255,255,255>Rewards: <color=0, 255, 0>%d standard points</color>, <color=230, 184, 0>%d premium points</color> and <color=0, 30, 201>%d experience points</color>.</font>"):format(
            data.requiredKills,
            getRoleString(data.killedRole),
            getRoleString(data.killerRole),
            data.rewards[1], data.rewards[2], data.rewards[3])
    else
        descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must kill %d </color>%s<color=255,255,255> as </color>%s\n\n<color=255,255,255>Rewards: <color=0, 255, 0>%d standard points</color>, <color=230, 184, 0>%d premium points</color>.</font>"):format(
        data.requiredKills,
        getRoleString(data.killedRole),
        getRoleString(data.killerRole),
        data.rewards[1], data.rewards[2])
    end
    if data.finishInOneRound ~= "0" then
        descriptionMarkupText = descriptionMarkupText .. "\n\n<font=CustomFont>This quest must be finished in a single round!"
    end
    local descriptionMarkup = markup.Parse(descriptionMarkupText, ScrW() * 0.6 - 16)
    self.descriptionLabel:SetText("")
    self.descriptionLabel.Paint = function(s, w, h)
        descriptionMarkup:Draw(0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    self.progressBar.Paint = function(s, w, h)
        local progress = data.currentKills / data.requiredKills
        progress = math.Clamp(progress, 0, 1)

        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35, 255))
        draw.RoundedBox(4, 0, 0, w * progress, h, Color(0, 150, 155, 255))

        draw.SimpleText(("%d%%"):format(progress * 100), "DermaBold", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)-- (marginRight / 2)
    end

    if self.claimButton then
        if data.completed then
            self.claimButton.Paint = function(s, w, h)
                draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 125, 35, 255), true, true, true, true)
                draw.SimpleText("Claim!", "DermaBold", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            self.claimButton.DoClick = function()
                net.Start("ClaimRewards")
                net.WriteTable(data)
                net.SendToServer()
            end
        else
            self.claimButton.Paint = function(s, w, h)
                draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
                draw.SimpleText("Claim!", "DermaDefault", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- Size labels appropriately
    self.title:SizeToContents()
    self.requirementLabel:SizeToContents()
end

vgui.Register("KillQuestHUD", PANEL, "EditablePanel")
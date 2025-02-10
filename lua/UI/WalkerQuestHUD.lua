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

function PANEL:SetQuest(data)
    self.title:SetText(data.title or "Walker Quest")
    self.requirementLabel:SetText(("Required Steps: %d"):format(data.requiredSteps or 0))
    self.progressLabel:SetText(("  |  Steps: %d"):format(data.currentSteps or 0))

    self.questTypeImage:SetTooltip("This quest is a walker-quest!")
    function self.questTypeImage:Paint(w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        
        -- Draw the image
        surface.SetMaterial(Material("walkerQuest.png"))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    -- REGION DESCRIPTION --

    local descriptionMarkupText
    if LEVELSYSTEM then
        descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must walk %d steps.</color>\n\n<color=255,255,255>Rewards: <color=0, 255, 0>%d standard points</color>, <color=230, 184, 0>%d premium points</color> and <color=0, 30, 201>%d experience points</color>.</font>"):format(
            data.requiredSteps,
            data.rewards[1], data.rewards[2], data.rewards[3])
    else
        descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must walk %d steps.</color>\n\n<color=255,255,255>Rewards: <color=0, 255, 0>%d standard points</color>, <color=230, 184, 0>%d premium points</color>.</font>"):format(
        data.requiredSteps,
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

    -- ENDREGION DESCRIPTION --

    -- REGION PROGERSS-BAR --

    self.progressBar.Paint = function(s, w, h)
        local progress = data.currentSteps / data.requiredSteps
        progress = math.Clamp(progress, 0, 1)

        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35, 255))
        draw.RoundedBox(4, 0, 0, w * progress, h, Color(0, 150, 155, 255))

        draw.SimpleText(("%d%%"):format(progress * 100), "DermaBold", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)-- (marginRight / 2)
    end

    -- ENDREGION PROGERSS-BAR --

    -- REGION CLAIM-BUTTON --

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
    
    -- ENDREGION CLAIM-BUTTON --

    self.requirementLabel:SizeToContents()
    self.progressLabel:SizeToContents()
end

vgui.Register("WalkerQuestHUD", PANEL, "EditablePanel")
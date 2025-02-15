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
        return "<color=52, 189, 235>Detective</color>" -- Blue
    else
        return "<color=255,255,255>Unknown</color>" -- Fallback (white)
    end
end

function PANEL:SetQuest(data)
    self.title:SetText(data.title or "Kill Quest")
    self.requirementLabel:SetText(("Required Kills: %d"):format(data.requiredKills or 0))
    self.progressLabel:SetText(("  |  Kills: %d"):format(data.currentKills or 0))    
   
    self.questTypeImage:SetTooltip("This quest is a kill-quest!")
    function self.questTypeImage:Paint(w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        
        -- Draw the image
        surface.SetMaterial(Material("killQuest.png"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
    local margin = 250 + 24 + 2
    if data.finishInOneRound and data.finishInOneRound ~= "0" then
        self.finishInOneImage = vgui.Create("DPanel", self)
        self.finishInOneImage:SetSize(24, 24)
        self.finishInOneImage:Center()    
        self.finishInOneImage:SetContentAlignment(4) 
        self.finishInOneImage:SetPos(margin, self.title:GetTall() + 13)
        self.finishInOneImage:SetTooltip("This quest must be completed in one round!")
        margin = margin + 24 + 2
        function self.finishInOneImage:Paint(w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            
            -- Draw the image
            surface.SetMaterial(Material("oneRoundQuestModifier.png"))
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end
    if data.headshotsOnly and data.headshotsOnly == true then
        self.headshotImage = vgui.Create("DPanel", self)
        self.headshotImage:SetSize(24, 24)
        self.headshotImage:Center()    
        self.headshotImage:SetContentAlignment(4) 
        self.headshotImage:SetPos(margin, self.title:GetTall() + 13)
        self.headshotImage:SetTooltip("This quest only counts progress with headshots!")
        margin = margin + 24 + 2
        function self.headshotImage:Paint(w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            
            -- Draw the image
            surface.SetMaterial(Material("headshotQuestModifier.png"))
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end   

    local descriptionMarkupText
    descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must kill %d </color>%s<color=255,255,255> as </color>%s\n\n<color=255,255,255>Rewards: </font>"):format(
        data.requiredKills,
        getRoleString(data.killedRole),
        getRoleString(data.killerRole)
    )
    for _, reward in ipairs(data.rewards) do
        if reward and reward != "0" then
            if _ == 1 then
                self.pointRewardsImage = vgui.Create("DPanel", self.rewardsPreview)
                self.pointRewardsImage:Dock(LEFT)
                self.pointRewardsImage:SetSize(24, 24)
                self.pointRewardsImage:Center()
                self.pointRewardsImage:SetContentAlignment(4)
                function self.pointRewardsImage:Paint(w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    
                    -- Draw the image
                    surface.SetMaterial(Material("pointshop2/dollar103.png"))
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                self.pointRewardsLabel = vgui.Create("DLabel", self.rewardsPreview)
                self.pointRewardsLabel:Dock(LEFT)
                self.pointRewardsLabel:DockMargin(5, 0, 0, 0)
                self.pointRewardsLabel:SetTextColor(Color(0, 255, 0))
                self.pointRewardsLabel:SetText(data.rewards[1])
                descriptionMarkupText = descriptionMarkupText .. ("<font=CustomFont><color=0, 255, 0>%d standard points</color>. </font>"):format(
                    reward
                )
            elseif _ == 2 then 
                self.premPointRewardsImage = vgui.Create("DPanel", self.rewardsPreview)
                self.premPointRewardsImage:Dock(LEFT)
                self.premPointRewardsImage:SetSize(24, 24)
                self.premPointRewardsImage:Center()
                self.premPointRewardsImage:SetContentAlignment(4)
                function self.premPointRewardsImage:Paint(w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    
                    -- Draw the image
                    surface.SetMaterial(Material("pointshop2/donation.png"))
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                self.premPointRewardsLabel = vgui.Create("DLabel", self.rewardsPreview)
                self.premPointRewardsLabel:Dock(LEFT)
                self.premPointRewardsLabel:DockMargin(5, 0, 0, 0)
                self.premPointRewardsLabel:SetTextColor(Color(230, 184, 0))
                self.premPointRewardsLabel:SetText(data.rewards[2])
                descriptionMarkupText = descriptionMarkupText .. ("<font=CustomFont><color=230, 184, 0>%d premium points</color>. </font>"):format(
                reward
            )
            elseif _ == 3 then 
                self.XPRewardsImage = vgui.Create("DPanel", self.rewardsPreview)
                self.XPRewardsImage:Dock(LEFT)
                self.XPRewardsImage:SetSize(24, 24)
                self.XPRewardsImage:Center()
                self.XPRewardsImage:SetContentAlignment(4)
                function self.XPRewardsImage:Paint(w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    
                    -- Draw the image
                    surface.SetMaterial(Material("rewardXP.png"))
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                self.XPRewardsLabel = vgui.Create("DLabel", self.rewardsPreview)
                self.XPRewardsLabel:Dock(LEFT)
                self.XPRewardsLabel:DockMargin(5, 0, 0, 0)
                self.XPRewardsLabel:SetTextColor(Color(52, 189, 235))
                self.XPRewardsLabel:SetText(data.rewards[3])
                descriptionMarkupText = descriptionMarkupText .. ("<font=CustomFont><color=52, 189, 235>%d experience points</color>.</font>"):format(
                reward
            )
            end
        end
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
                draw.SimpleText("Claim rewards!", "DermaBold", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            self.claimButton.DoClick = function()
                LocalPlayer():EmitSound("claimQuest.wav", 75, 100, 1 * bool_to_number(soundState) )
                net.Start("ClaimRewards")
                net.WriteTable(data)
                net.SendToServer()
            end
        else
            self.claimButton.Paint = function(s, w, h)
                draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
                draw.SimpleText("Claim rewards!", "DermaDefault", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- Size labels appropriately
    self.title:SizeToContents()
    self.requirementLabel:SizeToContents()
end

vgui.Register("KillQuestHUD", PANEL, "EditablePanel")
local PANEL = {}

function PANEL:Init()    
    -- Modern card-style background
    self.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 55, 200))
    end
    
    -- Quest content container
    self.content = vgui.Create("DPanel", self)
    self.content:Dock(FILL)
    self.content:DockMargin(8, 8, 8, 8)
    self.content.Paint = nil
    self.content:SetMouseInputEnabled(false)
    
    -- Title styling
    self.title = vgui.Create("DLabel", self.content)
    self.title:Dock(TOP)
    self.title:SetFont("Trebuchet24")
    self.title:SetTextColor(color_white)
    self.title:SetContentAlignment(4)

    self.claimButton = vgui.Create("DButton", self)
    self.claimButton:SetSize(150, 32)
    self.claimButton:SetText("")
    self.claimButton:SetFont("DermaLarge")
    self.claimButton:SetMouseInputEnabled(true)

    -- Progress container
    self.progress = vgui.Create("DPanel", self.content)
    self.progress:Dock(TOP)
    self.progress:DockMargin(0, 5, 0, 0)
    self.progress:SetTall(24)
    self.progress.Paint = nil

    -- Kill requirement display
    self.requiredKillsLabel = vgui.Create("DLabel", self.progress)
    self.requiredKillsLabel:Dock(LEFT)
    self.requiredKillsLabel:SetFont("Trebuchet18")
    self.requiredKillsLabel:SetTextColor(Color(200, 200, 255))
    self.requiredKillsLabel:SetContentAlignment(4)
    
    self.killsLabel = vgui.Create("DLabel", self.progress)
    self.killsLabel:Dock(LEFT)
    self.killsLabel:SetFont("Trebuchet18")
    self.killsLabel:SetTextColor(Color(200, 200, 255))
    self.killsLabel:SetContentAlignment(4)
    
    
    self.progressBar = vgui.Create("DPanel", self.content)
    self.progressBar:Dock(TOP)
    self.progressBar:DockMargin(0, 5, self.claimButton:GetWide() + 20, 0)

    self.descriptionLabel = vgui.Create("DLabel", self.content)
    self.descriptionLabel:Dock(TOP)
    self.descriptionLabel:DockMargin(0, 5, 0, 0)
    self.descriptionLabel:SetTextColor(Color(200, 200, 255))
    self.descriptionLabel:SetContentAlignment(4)
    self.descriptionLabel:SetSize(self.content:GetWide(), 250)

    function self.content:OnSizeChanged(w, h)
        if IsValid(self:GetParent().claimButton) then
            self:GetParent().claimButton:SetPos(w - 150, h - 24)
        end
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
    self.requiredKillsLabel:SetText(("Required Kills: %d"):format(data.requiredKills or 0))
    self.killsLabel:SetText(("  |  Kills: %d"):format(data.currentKills or 0))
    
    local descriptionMarkupText = ("<font=CustomFont><color=255,255,255>You must kill %d </color>%s<color=255,255,255> as </color>%s\n\n<color=255,255,255>Rewards: <color=0, 255, 0>%d standard points</color>, <color=0, 255, 0>%d premium points</color></font>"):format(
    data.requiredKills,
    getRoleString(data.killedRole),
    getRoleString(data.killerRole),
    data.rewards[1], data.rewards[2])
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

        draw.SimpleText(("%d%%"):format(progress * 100), "DermaDefault", (w / 2), (h / 2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)-- (marginRight / 2)
    end

    if(data.completed) then
        self.claimButton.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
            draw.SimpleText("Claim!", "DermaDefault", (w / 2), (h / 2), Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        self.claimButton.DoClick = function()
            net.Start("ClaimRewards")
            net.WriteTable(data)
            net.SendToServer()
        end
    else
        self.claimButton.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(125, 125, 135, 255), true, true, true, true)
            draw.SimpleText("Claim!", "DermaDefault", (w / 2), (h / 2), Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Size labels appropriately
    self.title:SizeToContents()
    self.requiredKillsLabel:SizeToContents()
end

vgui.Register("killQuestHUD", PANEL, "EditablePanel")
local PANEL = {}
local BaseHUDisActive = false

vgui.Register("BaseHUD", PANEL, "EditablePanel")

function PANEL:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    self:SetPos(ScrW() * 0.2, ScrH() * 0.2)
    self:SetVisible(false)
    
    -- Modern background with slight transparency
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
    end
    
    -- Close button (top right)
    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetSize(32, 32)
    self.closeButton:SetPos(self:GetWide() - 40, 8)
    self.closeButton:SetText("")
    self.closeButton:SetFont("DermaLarge")
    self.closeButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
        draw.SimpleText("×", "DermaDefault", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.closeButton.DoClick = function()
        self:SetVisible(false)
        BaseHUDisActive = false
        gui.EnableScreenClicker(false)
    end
    
    -- Horizontal line below the close button
    self.lineY = 50 -- Y position of the line
    self.PaintOver = function(s, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 50)) -- Light gray line
        surface.DrawLine(10, self.lineY, w - 10, self.lineY)
    end
    
    -- Register cards container
    self.registerCards = vgui.Create("DIconLayout", self)
    self.registerCards:SetPos(10, 10) -- Position below the close button
    self.registerCards:SetSize(self:GetWide() - 80, self.lineY - 10) -- Height up to the line
    self.registerCards:SetSpaceX(5) -- Spacing between cards
    
    -- Add register cards
    self:AddRegisterCard("Active Quests")
    self:AddRegisterCard("Finished Quests")
    if ULib.ucl.query(LocalPlayer(), "quests.manage") then
        self:AddRegisterCard("Admin")
    end
    
    -- Styled scroll panel
    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:SetPos(10, self.lineY + 10) -- Position below the line
    self.scrollPanel:SetSize(self:GetWide() - 20, self:GetTall() - self.lineY - 20)

    -- Quest container layout
    self.questLayout = vgui.Create("DIconLayout", self.scrollPanel)
    self.questLayout:SetSpaceY(5)
    self.questLayout:SetSize(self.scrollPanel:GetWide(), 1000)--self.scrollPanel:GetTall() * 3)
    self.questLayout.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(125, 125, 135, 255), true, true, true, true)
    end

    -- Admin UI placeholder (initially hidden)
    self.adminPanel = vgui.Create("DPanel", self.scrollPanel)
    self.adminPanel:Dock(FILL)
    self.adminPanel:SetSize(self:GetWide() - 40, self:GetTall() - self.lineY - 20)
    self.adminPanel:SetPos(10, self.lineY + 10)
    self.adminPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50, 255)) -- Admin panel background
        draw.SimpleText("Admin UI Placeholder", "DermaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.adminPanel:SetVisible(false) -- Hide by default

    self.finishedQuestLayout = vgui.Create("DIconLayout", self.scrollPanel)
    self.finishedQuestLayout:SetSpaceY(5)
    self.finishedQuestLayout:SetSize(self.scrollPanel:GetWide(), 1000)--self.scrollPanel:GetTall() * 3)
    self.finishedQuestLayout.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(125, 125, 135, 255), true, true, true, true)
    end
end

function PANEL:AddRegisterCard(name)
    local card = vgui.Create("DButton", self.registerCards)
    card:SetSize(100, self.lineY - 10)
    card:SetText("")
    card.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(50, 50, 70, 255), true, true, false, false)
        draw.SimpleText(name, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    card.DoClick = function()
        if name == "Active Quests" then
            self:ShowQuests()
        elseif name == "Finished Quests" then
            self:ShowFinishedQuests()
        elseif name == "Admin" then
            self:ShowAdmin()
        end
    end
end

function PANEL:ShowQuests()
    self.questLayout:SetVisible(true)
    self.adminPanel:SetVisible(false)
    self.finishedQuestLayout:SetVisible(false)
end

function PANEL:ShowAdmin()
    self.questLayout:SetVisible(false)
    self.adminPanel:SetVisible(true)
    self.finishedQuestLayout:SetVisible(false)
end

function PANEL:ShowFinishedQuests()
    self.questLayout:SetVisible(false)
    self.adminPanel:SetVisible(false)
    self.finishedQuestLayout:SetVisible(true)
end

function PANEL:UpdateQuests(quests, panel, hasButton)
    panel:Clear()
    for _, questData in ipairs(quests) do
        local questPanel
        questPanel = vgui.Create(questData.type .. "HUD", panel)
        questPanel:InitWithArgs(hasButton)

        if IsValid(questPanel) then
            questPanel:SetQuest(questData)
            questPanel:SetSize(self:GetWide() - 20, 70)
            questPanel.targetHeight = 105
            questPanel.animationSpeed = 10

            function questPanel:OnMousePressed(mouseCode)
                if mouseCode == MOUSE_LEFT then
                    local parent = self:GetParent()
                    if self.targetHeight == 105 then
                        self.targetHeight = 350
                    else
                        self.targetHeight = 105
                        parent:SetSize(parent:GetWide(), parent:GetTall() - 245)
                    end
                    parent:InvalidateLayout() -- Force parent layout to update
                end
            end

            function questPanel:Think()
                local currentHeight = self:GetTall()
                if currentHeight ~= self.targetHeight then
                    local newHeight = Lerp(FrameTime() * self.animationSpeed, currentHeight, self.targetHeight)
                    self:SetSize(self:GetWide(), newHeight)
                    local parent = self:GetParent()
                    parent:InvalidateLayout() -- Force parent layout to update
                end
            end
        end
    end

    if hasButton then
        self.claimAllButton = vgui.Create("DButton", panel)
        self.claimAllButton:Dock(BOTTOM)
        self.claimAllButton:SetSize(32, 32)
        self.claimAllButton:SetPos(self:GetWide() - 40, 8)
        self.claimAllButton:SetText("")
        self.claimAllButton:SetFont("DermaLarge")
        self.claimAllButton.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
            draw.SimpleText("Claim All!", "DermaDefault", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        self.claimAllButton.DoClick = function()
            for _, questData in ipairs(quests) do
                if(questData.completed and not questData.rewardsClaimed) then
                    net.Start("ClaimRewards")
                    net.WriteTable(questData)
                    net.SendToServer()
                end
            end
        end
    end
end

function PANEL:Think()
    gui.EnableScreenClicker(true)
end

-- Global access and hook handling
local baseHUD

hook.Add("QuestsUpdated", "UpdateQuestHUD", function(questsTable)
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    
    baseHUD:UpdateQuests(questsTable, baseHUD.questLayout, true)
end)

hook.Add("UpdateFinishedQuests", "UpdateFinishedQuestHUD", function(questsTable)
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    
    baseHUD:UpdateQuests(questsTable, baseHUD.finishedQuestLayout, false)
end)

function CreateBaseHUD()
    baseHUD = vgui.Create("BaseHUD")
    return baseHUD
end

concommand.Add("ttt_quest_menu", function(ply, cmd, args)
    BaseHUDisActive = not BaseHUDisActive
    gui.EnableScreenClicker(BaseHUDisActive)
    if IsValid(baseHUD) then
        baseHUD:SetVisible(BaseHUDisActive)
    end
    
    if BaseHUDisActive then
        net.Start("QuestMenuOpened")
        net.SendToServer()
    end
end)
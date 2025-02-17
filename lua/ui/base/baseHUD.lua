_G.CreateBaseHUD = function()
    if not baseHUD or not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
        baseHUD:SetVisible(false)
        baseHUD:MakePopup()
    end
    return baseHUD
end

local PANEL = {}
local BaseHUDisActive = false
soundState = true

vgui.Register("BaseHUD", PANEL, "EditablePanel")

function PANEL:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    self:SetPos(ScrW() * 0.2, ScrH() * 0.2)
    self:SetVisible(false)
    
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
    end
    
    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetSize(32, 32)
    self.closeButton:SetPos(self:GetWide() - 40, 8)
    self.closeButton:SetText("")
    self.closeButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
        draw.SimpleText("×", "DermaBold", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.closeButton.DoClick = function()
        self:SetVisible(false)
        BaseHUDisActive = false
        gui.EnableScreenClicker(false)
    end

    self.muteButton = vgui.Create("DButton", self)
    self.muteButton:SetSize(32, 32)
    self.muteButton:SetPos(self:GetWide() - 40 - 32 - 8, 8)
    self.muteButton:SetText("")
    self.muteButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
    end

    self.loudspeakerIcon = vgui.Create("DPanel", self.muteButton)
    self.loudspeakerIcon:SetSize(24, 24)
    self.loudspeakerIcon:SetPos(4, 4)
    self.loudspeakerIcon:SetMouseInputEnabled(false)
    function self.loudspeakerIcon:Paint(w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        
        if soundState == true then
            surface.SetMaterial(Material("soundOn.png"))
        else
            surface.SetMaterial(Material("soundOff.png"))
        end
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.muteButton.DoClick = function()
        soundState = not soundState
    end

    self.infoButton = vgui.Create("DButton", self)
    self.infoButton:SetSize(32, 32)
    self.infoButton:SetPos(self:GetWide() - 40 - 64 - 16, 8)
    self.infoButton:SetText("")
    self.infoButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
        draw.SimpleText("i", "DermaBold", (w / 2), (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local questMessage = [[
Quest Basics:

1. You receive 1 quest by default.
2. After finishing the quest, you can claim your rewards by clicking the 'Claim Rewards!' button.
3. To view more details about a quest, simply click anywhere on the quest to open it up and reveal additional information.]]
    self.infoButton:SetTooltip(questMessage)

    -- Horizontal line below the close button
    self.lineY = 50 -- Y position of the line
    self.PaintOver = function(s, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 50)) -- Light gray line
        surface.DrawLine(10, self.lineY, w - 10, self.lineY)
    end
    
    -- Register cards container
    self.registerCards = vgui.Create("DIconLayout", self)
    self.registerCards:SetPos(10, 10) -- Position below the close button
    self.registerCards:SetSize(315, self.lineY - 10) -- Height up to the line
    self.registerCards:SetSpaceX(5) -- Spacing between cards
    
    -- Add register cards
    self:AddRegisterCard("Active Quests")
    self:AddRegisterCard("Finished Quests")
    if ULib.ucl.query(LocalPlayer(), "quests.manage") then
        self:AddRegisterCard("Admin")
    end
    
    -- Styled scroll panel
    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:SetPos(10, self.lineY + 10)
    self.scrollPanel:SetSize(self:GetWide() - 20, self:GetTall() - self.lineY - 20)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(10, self.lineY + 10, 10, 10)

    -- Style the scrollbar
    local sbar = self.scrollPanel:GetVBar()
    sbar:SetHideButtons(true)
    sbar.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
    end
    sbar.btnGrip.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150))
    end

    -- Quest container layout
    self.questLayout = vgui.Create("DIconLayout", self.scrollPanel)
    self.questLayout:SetSpaceY(5)
    self.questLayout:SetSize(self.scrollPanel:GetWide(), 1000)

    -- Make admin panel if user has permissions
    if ULib.ucl.query(LocalPlayer(), "quests.manage") then
        self.adminContainer = vgui.Create("DPanel", self.scrollPanel)
        self.adminContainer:Dock(FILL)
        self.adminContainer:DockMargin(0, 0, 0, 0) -- Remove margins
        self.adminContainer:SetVisible(false)
        self.adminContainer:SetSize(self:GetWide(), self:GetTall()) -- Use full size
        self.adminContainer.Paint = nil

        self.adminContainer:SetSize(math.max(800, self:GetWide()), math.max(600, self:GetTall() - self.lineY - 20))

        self.adminBaseHUD = vgui.Create("AdminBaseHUD", self.adminContainer)
        self.adminBaseHUD:Dock(FILL)
        self.adminBaseHUD:DockMargin(0, 0, 0, 0)
        self.adminBaseHUD:InvalidateLayout(true)

        timer.Simple(0.1, function()
            if IsValid(self.adminBaseHUD) then
                self.adminBaseHUD:InvalidateLayout(true)
            end
        end)
    end

    self.finishedQuestLayout = vgui.Create("DIconLayout", self.scrollPanel)
    self.finishedQuestLayout:SetSpaceY(5)
    self.finishedQuestLayout:SetSize(self.scrollPanel:GetWide() - self.scrollPanel:GetVBar():GetWide() - 5, 1000)
    self.finishedQuestLayout:SetVisible(false)
end

local cards = {}
local names = {}

function PANEL:AddRegisterCard(name)
    local card = vgui.Create("DButton", self.registerCards)
    card:SetSize(100, self.lineY - 10)
    card:SetText("")
    card.Paint = function(s, w, h)
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
    table.insert(names, name)
    table.insert(cards, card)
end

function PANEL:DrawCards(activeID)
    for _, card in ipairs(cards) do        
        card.Paint = function(s, w, h)
            if(_ == activeID) then
                draw.RoundedBoxEx(8, 0, 5, w, h - 5, Color(50, 50, 70, 255), true, true, false, false)
            else
                draw.RoundedBoxEx(8, 0, 0, w, h, Color(50, 50, 70, 255), true, true, false, false)
            end
            draw.SimpleText(names[_], "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end        
    end

end

function PANEL:ShowQuests()
    self:DrawCards(1)
    self.questLayout:SetVisible(true)
    self.adminContainer:SetVisible(false)
    self.finishedQuestLayout:SetVisible(false)
end

function PANEL:ShowFinishedQuests()
    self:DrawCards(2)
    self.questLayout:SetVisible(false)
    self.adminContainer:SetVisible(false)
    self.finishedQuestLayout:SetVisible(true)
end

function PANEL:ShowAdmin()
    if not IsValid(self.adminContainer) or not IsValid(self.adminBaseHUD) then return end
    
    self:DrawCards(3)
    self.questLayout:SetVisible(false)
    self.finishedQuestLayout:SetVisible(false)
    
    -- Set size before making visible to avoid flicker
    self.adminContainer:SetSize(self:GetWide(), self:GetTall() - self.lineY - 20)
    self.adminContainer:SetVisible(true)
    self.adminContainer:Dock(FILL)
    self.adminContainer:DockMargin(0, 0, 0, 0)
    
    self.adminBaseHUD:SetSize(self.adminContainer:GetWide(), self.adminContainer:GetTall())
    self.adminBaseHUD:Dock(FILL)
    self.adminBaseHUD:DockMargin(0, 0, 0, 0)
    self.adminBaseHUD:InvalidateLayout(true)
    
    self.scrollPanel:InvalidateLayout(true)
    
    timer.Simple(0.1, function()
        if IsValid(self.adminBaseHUD) then
            self.adminBaseHUD:InvalidateLayout(true)
        end
        if IsValid(self.adminContainer) then
            self.adminContainer:InvalidateLayout(true)
        end
    end)
end

function PANEL:UpdateQuests(quests, panel, hasButton)
    panel:Clear()
    for _, questData in ipairs(quests) do
        local questPanel = vgui.Create(questData.type .. "HUD", panel)
        questPanel:InitWithArgs(hasButton)

        if IsValid(questPanel) then
            questPanel:SetQuest(questData)
            questPanel:SetSize(self:GetWide(), 125)
            questPanel.targetHeight = 125
            questPanel.animationSpeed = 10
            questPanel.isAnimating = false

            function questPanel:OnMousePressed(mouseCode)
                if mouseCode == MOUSE_LEFT then
                    self.isAnimating = true
                    local parent = self:GetParent()
                    if self.targetHeight == 125 then
                        self.targetHeight = 350
                    else
                        self.targetHeight = 125
                        parent:SetSize(parent:GetWide(), parent:GetTall() - 245)
                    end
                    parent:InvalidateLayout()
                end
            end

            function questPanel:Think()
                if self.isAnimating then
                    local curHeight = self:GetTall()
                    if self.targetHeight == 125 and curHeight < 125 then
                        self:SetSize(self:GetWide(), 125)
                        self.isAnimating = false
                    else
                        local newHeight = Lerp(FrameTime() * self.animationSpeed, curHeight, self.targetHeight)
                        if math.abs(newHeight - self.targetHeight) < 1 then
                            self:SetSize(self:GetWide(), self.targetHeight)
                            self.isAnimating = false
                        else
                            self:SetSize(self:GetWide(), newHeight)
                        end
                    end
                    self:GetParent():InvalidateLayout()
                else
                    if self:GetTall() ~= self.targetHeight then
                        self:SetSize(self:GetWide(), self.targetHeight)
                    end
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
    else
        self.deleteAllButton = vgui.Create("DButton", panel)
        self.deleteAllButton:Dock(BOTTOM)
        self.deleteAllButton:SetSize(32, 32)
        self.deleteAllButton:SetPos(self:GetWide() - 40, 8)
        self.deleteAllButton:SetText("")
        self.deleteAllButton:SetFont("DermaLarge")
        self.deleteAllButton.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
            draw.SimpleText("Delete All!", "DermaDefault", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        self.deleteAllButton.DoClick = function()
            QuestManager.finishedQuests = {}
            file.Write(questsDir, util.TableToJSON(QuestManager.finishedQuests, true)) 
            hook.Run("UpdateFinishedQuests", QuestManager.finishedQuests)
        end        
    end
    
    if panel == self.questLayout then
        self:ShowQuests()
    elseif panel == self.finishedQuestLayout then
        self:ShowFinishedQuests()
    end
end

function PANEL:Think()
    gui.EnableScreenClicker(true)
end

-- Global access and hook handling

hook.Add("QuestsUpdated", "UpdateQuestHUD", function(questsTable)
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    PrintTable(questsTable)
    
    baseHUD:UpdateQuests(questsTable.quests, baseHUD.questLayout, true)
end)

hook.Add("UpdateFinishedQuests", "UpdateFinishedQuestHUD", function(questsTable)   
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    baseHUD:UpdateQuests(questsTable, baseHUD.finishedQuestLayout, false)
end)

function CreateBaseHUD()
    -- if LocalPlayer():IsAdmin() then
    --     if CreateAdminBaseHUD then
    --         local adminHUD = CreateAdminBaseHUD()
    --         if IsValid(adminHUD) then
    --             adminHUD:InvalidateLayout(true)
    --         end
    --     else
    --         ErrorNoHalt("[Quests] Failed to find CreateAdminBaseHUD function\n")
    --     end
    -- end

    baseHUD = vgui.Create("BaseHUD")
    return baseHUD
end

function OpenQuestMenu()
    BaseHUDisActive = not BaseHUDisActive
    gui.EnableScreenClicker(BaseHUDisActive)
    if IsValid(baseHUD) then
        baseHUD:SetVisible(BaseHUDisActive)
    end
    
    if BaseHUDisActive then
        net.Start("QuestMenuOpened")
        net.SendToServer()
    end
end

concommand.Add("ttt_quest_menu", function(ply, cmd, args)
    OpenQuestMenu()
end)
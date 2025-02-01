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
    local closeButton = vgui.Create("DButton", self)
    closeButton:SetSize(32, 32)
    closeButton:SetPos(self:GetWide() - 40, 8)
    closeButton:SetText("")
    closeButton:SetFont("DermaLarge")
    closeButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
        draw.SimpleText("×", "DermaDefault", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeButton.DoClick = function()
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
    self:AddRegisterCard("Quests")
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
    self.questLayout:SetSize(self.scrollPanel:GetWide(), self.scrollPanel:GetTall())
    
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
        if name == "Quests" then
            self:ShowQuests() -- Show quests
        elseif name == "Admin" then
            self:ShowAdmin() -- Show admin UI
        end
    end
end

function PANEL:ShowQuests()
    self.questLayout:SetVisible(true) -- Show quests scroll panel
    self.adminPanel:SetVisible(false) -- Hide admin panel
end

function PANEL:ShowAdmin()
    self.questLayout:SetVisible(false) -- Hide quests scroll panel
    self.adminPanel:SetVisible(true) -- Show admin panel
end

function PANEL:UpdateQuests(quests)
    self.questLayout:Clear()
    PrintTable(quests)
    for _, questData in ipairs(quests) do
        local questPanel
        if questData.type == "KillQuest" then
            questPanel = vgui.Create("killQuestHUD", self.questLayout)
            questPanel:SetQuest(questData)
        end

        if IsValid(questPanel) then
            questPanel:SetSize(self:GetWide() - 20, 70)
            questPanel.targetHeight = 70
            questPanel.animationSpeed = 10

            function questPanel:OnMousePressed(mouseCode)
                if mouseCode == MOUSE_LEFT then
                    local parent = self:GetParent()
                    if self.targetHeight == 70 then
                        self.targetHeight = 350
                        self.test:SetVisible(true)
                    else
                        self.targetHeight = 70
                        self.test:SetVisible(false)
                        parent:SetSize(parent:GetWide(), parent:GetTall() - 280)
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
end

-- Global access and hook handling
local baseHUD

hook.Add("QuestsUpdated", "UpdateQuestHUD", function(questsTable)
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    
    baseHUD:UpdateQuests(questsTable)
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
end)
local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)

    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(5, 5, 5, 5)
    
    self:SetBackgroundColor(Color(240, 240, 240))

    self.headerLabel = vgui.Create("DLabel", self)
    self.headerLabel:Dock(TOP)
    self.headerLabel:SetTall(25)
    self.headerLabel:SetFont("DermaBold")
    self.headerLabel:SetTextColor(Color(0, 0, 0))
    
    self.questList = vgui.Create("DListLayout", self.scrollPanel)
    self.questList:Dock(FILL)
    self.questList:DockMargin(0, 5, 0, 0)

    local bar = self.scrollPanel:GetVBar()
    if IsValid(bar) then
        bar:SetHideButtons(true)
        bar.Paint = function(_, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
        end
        bar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150))
        end
    end
end

function PANEL:SetTitle(title)
    if IsValid(self.headerLabel) then
        self.headerLabel:SetText(title)
        self.headerLabel:SetVisible(true)
    end
end

function PANEL:AddQuest(quest, onClick, onRightClick)
    if not IsValid(self.questList) then return end

    local questBtn = vgui.Create("DButton", self.questList)
    questBtn:SetTall(50)
    questBtn:Dock(TOP)
    questBtn:DockMargin(0, 0, 0, 5)
    questBtn:SetText(quest.name or "Unnamed Quest")
    questBtn:SetFont("DermaBold")
    questBtn:SetTextColor(Color(0, 0, 0))
    
    questBtn.Paint = function(s, w, h)
        local bgColor = quest.completed and Color(200, 255, 200, 255) or Color(200, 200, 200, 255)
        if s:IsHovered() then
            bgColor = Color(220, 220, 220, 255)
        end
        draw.RoundedBox(8, 0, 0, w, h, bgColor)

        local iconSize = h - 10
        local iconX = w - iconSize - 5
        local iconY = 5
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material(quest.type:lower() .. "Quest.png"))
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
    end

    questBtn.DoClick = function()
        if self.OnQuestClick then
            self.OnQuestClick(quest)
        elseif onClick then
            onClick(quest)
        end
    end

    questBtn.DoRightClick = function()
        if self.OnQuestRightClick then
            self.OnQuestRightClick(quest)
        elseif onRightClick then
            onRightClick(quest)
        end
    end

    return questBtn
end

function PANEL:Clear()
    if IsValid(self.questList) then
        self.questList:Clear()
    end
end

function PANEL:SetBackgroundColor(color)
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, color)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.questList) then
        self.questList:InvalidateLayout(true)
    end
    
    if IsValid(self.scrollPanel) then
        self.scrollPanel:InvalidateLayout(true)
    end
end

vgui.Register("QuestList", PANEL, "DScrollPanel")

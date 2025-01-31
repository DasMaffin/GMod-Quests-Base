local PANEL = {}

vgui.Register("BaseHUD", PANEL, "EditablePanel")

function PANEL:Init()
    self:SetSize(400, ScrH() * 0.6)
    self:SetPos(ScrW() - 420, 20)
    self:SetVisible(false)
    
    -- Modern background with slight transparency
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
    end
    
    -- Close button (top right)
    local closeButton = vgui.Create("DButton", self)
    closeButton:SetSize(32, 32)
    closeButton:SetPos(self:GetWide() - 40, 8)
    closeButton:SetText("×")
    closeButton:SetFont("DermaLarge")
    closeButton.DoClick = function()
        self:SetVisible(false)
    end
    
    -- Styled scroll panel for quests
    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(10, 50, 10, 10)
    
    -- Quest container layout
    self.questLayout = vgui.Create("DIconLayout", self.scrollPanel)
    self.questLayout:Dock(FILL)
    self.questLayout:SetSpaceY(5)
end

function PANEL:UpdateQuests(quests)
    self.questLayout:Clear()
    
    PrintTable(quests)
    for _, questData in ipairs(quests) do
        local questPanel = vgui.Create("IntegratedHUDOne", self.questLayout)
        questPanel:SetQuest(questData)
        questPanel:SetSize(self:GetWide() - 20, 60)
    end
end

-- Global access and hook handling
local baseHUD

hook.Add("QuestsUpdated", "UpdateQuestHUD", function(questsTable)
    if not IsValid(baseHUD) then
        baseHUD = vgui.Create("BaseHUD")
    end
    
    baseHUD:SetVisible(true)
    baseHUD:UpdateQuests(questsTable)
end)

function CreateBaseHUD()
    baseHUD = vgui.Create("BaseHUD")
    return baseHUD
end
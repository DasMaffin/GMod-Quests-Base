local AdminHUD = {}

vgui.Register("AdminBaseHUD", AdminHUD, "EditablePanel")

function AdminHUD:Init()
    -- Neuer Quest Editor Bereich
    self.questEditorArea = vgui.Create("DPanel", self)
    self.questEditorArea:SetSize(self:GetWide(), self:GetTall())
    self.questEditorArea:SetPos(0, 0)
    self.questEditorArea:SetVisible(true) -- Sichtbar, wenn der Editor genutzt werden soll
    self.questEditorArea.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(60,60,70,255))
    end

    -- Linkes Panel: Dropdown + Questliste
    self.questEditorLeft = vgui.Create("DPanel", self.questEditorArea)
    self.questEditorLeft:SetSize(self:GetWide() * 0.4, self:GetTall())
    self.questEditorLeft:SetPos(0, 0)
    self.questEditorLeft.Paint = function() end

    -- Dropdown für alle Quest-Typen (angenommene globale Tabelle QuestManager.questTypes)
    self.questTypeDropdown = vgui.Create("DComboBox", self.questEditorLeft)
    self.questTypeDropdown:SetSize(self.questEditorLeft:GetWide() - 20, 30)
    self.questTypeDropdown:SetPos(10, 10)
    -- Dropdown füllen
    for _, questType in ipairs(QuestManager.questTypes or {}) do
        self.questTypeDropdown:AddChoice(questType)
    end

    -- Questliste (unten im linken Panel)
    self.questList = vgui.Create("DIconLayout", self.questEditorLeft)
    self.questList:SetSize(self.questEditorLeft:GetWide() - 20, self.questEditorLeft:GetTall() - 50)
    self.questList:SetPos(10, 50)
    -- Questliste füllen (angehende globale Tabelle QuestManager.availableQuests)
    for _, quest in ipairs(QuestManager.availableQuests or {}) do
        local btn = self.questList:Add("DButton")
        btn:SetSize(self.questList:GetWide() - 10, 30)
        btn:SetText(quest.name or "Unnamed Quest")
        btn.DoClick = function()
            self:ShowQuestFields(quest)
        end
    end

    -- Rechtes Panel: Felder zum Editieren/Erstellen einer Quest 
    self.questEditorRight = vgui.Create("DPanel", self.questEditorArea)
    self.questEditorRight:SetSize(self:GetWide() * 0.6, self:GetTall())
    self.questEditorRight:SetPos(self:GetWide() * 0.4, 0)
    self.questEditorRight.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(45,45,55,250))
    end

    -- Methode zum Füllen des rechten Panels mit Quest-Feldern
    function self:ShowQuestFields(quest)
        self.questEditorRight:Clear()
        local y = 10
        
        -- Namensfeld
        local nameEntry = vgui.Create("DTextEntry", self.questEditorRight)
        nameEntry:SetPos(10, y)
        nameEntry:SetSize(self.questEditorRight:GetWide() - 20, 30)
        nameEntry:SetText(quest.name or "")
        y = y + 40
        
        -- Beschreibungsfeld
        local descEntry = vgui.Create("DTextEntry", self.questEditorRight)
        descEntry:SetPos(10, y)
        descEntry:SetSize(self.questEditorRight:GetWide() - 20, 100)
        descEntry:SetText(quest.description or "")
        descEntry:SetMultiline(true)
        
        -- Weitere Felder können hier eingefügt werden
    end
end

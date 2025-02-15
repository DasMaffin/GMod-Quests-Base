include("ui/admin/questEditor.lua")
include("ui/admin/questList.lua")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)
    
    self.minWidth = 800
    self.minHeight = 600
    
    self.Paint = function(s, w, h)
        local finalWidth = math.max(w, self.minWidth)
        local finalHeight = math.max(h, self.minHeight)
        draw.RoundedBox(8, 0, 0, finalWidth, finalHeight, Color(255, 255, 255, 255))
    end

    self.leftPanel = vgui.Create("DPanel", self)
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(450)
    self.leftPanel:DockMargin(5, 5, 5, 5)
    self.leftPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(240, 240, 240, 255))
    end

    self:CreateButtonContainer()

    self:QueuePanelCreation()
end

function PANEL:QueuePanelCreation()
    local function CreateQuestList(parent, dock, tall, margin, title)
        local panel = vgui.Create("QuestList", parent)
        if IsValid(panel) then
            panel:Dock(dock)
            panel:DockMargin(unpack(margin))
            if tall then 
                panel:SetTall(tall)
                panel:SetMinimumSize(0, tall * 0.6)
            end
            panel:SetTitle(title)
            return panel
        end
        return nil
    end

    self:SetSize(self.minWidth, self.minHeight)
    self:InvalidateLayout(true)

    timer.Simple(0.1, function()
        if not IsValid(self) then return end
        self.availableQuests = CreateQuestList(
            self.leftPanel, 
            TOP, 
            400, 
            {5, 140, 5, 5}, 
            "Available Quests"
        )
        
        timer.Simple(0.1, function()
            if not IsValid(self) then return end
            self.activeQuests = CreateQuestList(
                self.leftPanel,
                FILL,
                nil,
                {5, 5, 5, 5},
                "Active Quests"
            )
            
            timer.Simple(0.1, function()
                if not IsValid(self) then return end
                self.rightPanel = vgui.Create("QuestEditor", self)
                if IsValid(self.rightPanel) then
                    self.rightPanel:Dock(FILL)
                    self.rightPanel:DockMargin(5, 5, 5, 5)
                    self.rightPanel:SetMinimumSize(400, 500)
                end
                
                timer.Simple(0.1, function()
                    if not IsValid(self) then return end
                    self:SetupCallbacks()
                    self:UpdateQuestLists()
                    self:InvalidateLayout(true)
                    
                    self:InvalidateChildren(true)
                end)
            end)
        end)
    end)
end

function PANEL:CreateButtonContainer()
    local buttonContainer = vgui.Create("DPanel", self.leftPanel)
    buttonContainer:Dock(TOP)
    buttonContainer:SetTall(130)
    buttonContainer:DockMargin(5, 5, 5, 5)
    buttonContainer.Paint = nil

    local dropdownContainer = vgui.Create("DPanel", buttonContainer)
    dropdownContainer:Dock(TOP)
    dropdownContainer:SetTall(40)
    dropdownContainer:DockMargin(0, 0, 0, 5)
    dropdownContainer.Paint = nil

    local dropdownLabel = vgui.Create("DLabel", dropdownContainer)
    dropdownLabel:SetText("New Quest Type:")
    dropdownLabel:SetTextColor(Color(0, 0, 0))
    dropdownLabel:SetFont("DermaBold")
    dropdownLabel:Dock(LEFT)
    dropdownLabel:SetWide(100)
    dropdownLabel:DockMargin(5, 0, 5, 0)

    self.questTypeDropdown = vgui.Create("DComboBox", dropdownContainer)
    self.questTypeDropdown:Dock(FILL)
    self.questTypeDropdown:DockMargin(0, 5, 0, 5)
    self.questTypeDropdown:SetValue("Select Quest Type")
    self.questTypeDropdown:SetTextColor(Color(0, 0, 0))

    for questType, _ in pairs(QuestManager.questTypes) do
        self.questTypeDropdown:AddChoice(questType)
    end

    self.questTypeDropdown.OnSelect = function(_, _, value)
        self:CreateNewQuest(value)
        timer.Simple(0.1, function()
            if IsValid(self.questTypeDropdown) then
                self.questTypeDropdown:SetValue("Select Quest Type")
            end
        end)
    end

    self.deleteAllBtn = vgui.Create("DButton", buttonContainer)
    self.deleteAllBtn:Dock(TOP)
    self.deleteAllBtn:SetTall(40)
    self.deleteAllBtn:DockMargin(0, 5, 0, 0)
    self.deleteAllBtn:SetText("Delete All Quests")
    self.deleteAllBtn:SetFont("DermaBold")
    self.deleteAllBtn:SetTextColor(Color(255, 255, 255))
    self.deleteAllBtn.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() and Color(200, 0, 0, 255) or Color(180, 0, 0, 255))
    end
    
    self.deleteAllBtn.DoClick = function()
        self:ConfirmDeleteAll()
    end
end

function PANEL:ShowQuestTypeSelection()
    local questTypes = {}
    for questType, _ in pairs(QuestManager.questTypes) do
        table.insert(questTypes, questType)
    end

    local dropdown = DermaMenu()
    
    for _, questType in pairs(questTypes) do
        dropdown:AddOption(questType, function()
            self:CreateNewQuest(questType)
        end)
    end
    
    dropdown:Open()
end

function PANEL:CreateNewQuest(questType)
    if not questType then return end

    local newQuest = {
        type = questType,
        completed = false,
        rewardsClaimed = false,
        uniqueId = util.SHA256(tostring(os.time()) .. tostring(math.random())),
        finishInOneRound = "0",
        weight = 1,
        rewards = {"0", "0", "0"}
    }

    if IsValid(self.rightPanel) then
        self.rightPanel:LoadQuest(newQuest)
    end
end

function PANEL:ConfirmDeleteAll()
    Derma_Query(
        "Are you sure you want to delete all quests?",
        "Confirm Deletion",
        "Yes",
        function()
            QuestManager.availableQuests = {}
            file.Write(questsDir, util.TableToJSON(QuestManager.availableQuests, true))
            self:UpdateQuestLists()
        end,
        "No",
        function() end
    )
end

function PANEL:SetupCallbacks()
    if IsValid(self.availableQuests) then
        self.availableQuests.OnQuestClick = function(quest)
            if IsValid(self.rightPanel) then
                self.rightPanel:LoadQuest(quest)
            end
        end
        
        self.availableQuests.OnQuestRightClick = function(quest)
            local menu = DermaMenu()
            menu:AddOption("Edit", function()
                if IsValid(self.rightPanel) then
                    self.rightPanel:LoadQuest(quest)
                end
            end)
            menu:AddOption("Delete", function()
                self:ConfirmDeleteQuest(quest)
            end)
            menu:Open()
        end
    end

    if IsValid(self.rightPanel) then
        self.rightPanel.OnQuestSaved = function()
            self:UpdateQuestLists()
        end
    end
end

function PANEL:ConfirmDeleteQuest(quest)
    Derma_Query(
        "Are you sure you want to delete this quest?",
        "Confirm Deletion",
        "Yes",
        function()
            table.RemoveByValue(QuestManager.availableQuests, quest)
            file.Write(questsDir, util.TableToJSON(QuestManager.availableQuests, true))
            self:UpdateQuestLists()
        end,
        "No",
        function() end
    )
end

function PANEL:UpdateQuestLists()
    self:UpdateAvailableQuests()
    self:UpdateActiveQuests()
end

function PANEL:UpdateAvailableQuests()
    self.availableQuests:Clear()
    
    if QuestManager and QuestManager.availableQuests then
        for _, quest in ipairs(QuestManager.availableQuests) do
            self.availableQuests:AddQuest(quest, 
                function(q) self.availableQuests.OnQuestClick(q) end,
                function(q) self.availableQuests.OnQuestRightClick(q) end
            )
        end
    end
end

function PANEL:UpdateActiveQuests()
    self.activeQuests:Clear()
    
    if QuestManager and QuestManager.activeQuests then
        for steamID, playerQuests in pairs(QuestManager.activeQuests) do
            local ply = FindPlayerBySteamID64(steamID)
            if ply and playerQuests.quests then
                local header = vgui.Create("DPanel", self.activeQuests.questList)
                header:SetTall(30)
                header:Dock(TOP)
                header:DockMargin(0, 5, 0, 0)
                header.Paint = function(s, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(180, 180, 180, 255))
                end

                local playerLabel = vgui.Create("DLabel", header)
                playerLabel:SetText("Player: " .. ply:Nick())
                playerLabel:SetTextColor(Color(0, 0, 0))
                playerLabel:SetFont("DermaBold")
                playerLabel:Dock(FILL)
                playerLabel:DockMargin(5, 0, 0, 0)
                playerLabel:SetContentAlignment(4)

                for _, quest in ipairs(playerQuests.quests) do
                    self.activeQuests:AddQuest(quest)
                end
            end
        end
    end
end

function PANEL:PerformLayout(w, h)
    local width = math.max(w, self.minWidth)
    local height = math.max(h, self.minHeight)
    
    self:SetSize(width, height)
    
    if IsValid(self.leftPanel) then
        self.leftPanel:SetTall(height)
        self.leftPanel:SetWide(math.min(450, width * 0.3))
    end
    
    if IsValid(self.rightPanel) then
        self.rightPanel:SetSize(width - self.leftPanel:GetWide() - 15, height)
    end

    if IsValid(self.availableQuests) then
        self.availableQuests:SetTall(math.max(300, height * 0.4))
        self.availableQuests:InvalidateLayout(true)
    end
    
    if IsValid(self.activeQuests) then
        self.activeQuests:SetTall(math.max(300, height * 0.4))
        self.activeQuests:InvalidateLayout(true)
    end
end

function PANEL:SetupScrollbars()
    local function StyleScrollbar(panel)
        if not IsValid(panel) then
            print("[AdminBaseHUD] Invalid panel passed to StyleScrollbar")
            return
        end
        
        if not panel.GetVBar then
            print("[AdminBaseHUD] Panel does not have GetVBar method:", panel:GetName())
            return
        end
        
        local sbar = panel:GetVBar()
        if not IsValid(sbar) then
            print("[AdminBaseHUD] Invalid scrollbar for panel:", panel:GetName())
            return
        end
        
        sbar:SetHideButtons(true)
        sbar.Paint = function(_, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
        end
        sbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150))
        end
    end

    if IsValid(self.availableQuests) then
        if self.availableQuests.scrollPanel then
            print("[AdminBaseHUD] Styling availableQuests scrollbar")
            StyleScrollbar(self.availableQuests.scrollPanel)
        else
            print("[AdminBaseHUD] availableQuests has no scrollPanel")
        end
    end
    
    if IsValid(self.activeQuests) then
        if self.activeQuests.scrollPanel then
            print("[AdminBaseHUD] Styling activeQuests scrollbar")
            StyleScrollbar(self.activeQuests.scrollPanel)
        else
            print("[AdminBaseHUD] activeQuests has no scrollPanel")
        end
    end
    
    if IsValid(self.rightPanel) then
        if self.rightPanel.GetVBar then
            print("[AdminBaseHUD] Styling rightPanel scrollbar")
            StyleScrollbar(self.rightPanel)
        else
            print("[AdminBaseHUD] rightPanel is not a DScrollPanel")
        end
    end
end

vgui.Register("AdminBaseHUD", PANEL, "DPanel")

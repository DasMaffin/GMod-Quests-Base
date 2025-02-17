local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self.fields = {}
    self.events = {}

    timer.Simple(0, function()
        if IsValid(self) then
            local bar = self:GetVBar()
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
    end)
end

function PANEL:GetQuestTypeFields(questType)
    local fields = {
        {name = "weight", label = "Weight", type = "number", default = 1},
        {name = "finishInOneRound", label = "Must finish in one round", type = "boolean", default = false},
        -- Reward fields
        {name = "rewardPoints", label = "Standard Points Reward", type = "number", default = 0},
        {name = "rewardPremium", label = "Premium Points Reward", type = "number", default = 0},
        {name = "rewardXP", label = "XP Reward", type = "number", default = 0},
    }

    local typeFields = {
        KillQuest = {
            {name = "requiredKills", label = "Required Kills", type = "number", default = 1},
            {name = "killedRole", label = "Role to be killed", type = "select", options = {
                {value = "0", text = "Innocent"},
                {value = "1", text = "Traitor"},
                {value = "2", text = "Detective"}
            }, default = "0"},
            {name = "killerRole", label = "Role of killer", type = "select", options = {
                {value = "0", text = "Innocent"},
                {value = "1", text = "Traitor"},
                {value = "2", text = "Detective"}
            }, default = "0"}
        },
        WalkerQuest = {
            {name = "requiredSteps", label = "Required Steps", type = "number", default = 1000}
        },
        SurviveQuest = {
            {name = "requiredRounds", label = "Required Rounds", type = "number", default = 1}
        },
        KarmaQuest = {
            {name = "requiredRounds", label = "Required Rounds", type = "number", default = 1},
            {name = "minKarma", label = "Minimum Karma", type = "number", default = 1000}
        }
    }

    if typeFields[questType] then
        for _, field in ipairs(typeFields[questType]) do
            table.insert(fields, field)
        end
    end

    return fields
end

function PANEL:CreateField(fieldInfo, value)
    local container = vgui.Create("DPanel", self)
    container:Dock(TOP)
    container:SetTall(fieldInfo.type == "multiline" and 100 or 40)
    container:DockMargin(5, 5, 5, 5)
    container.Paint = nil

    local lbl = vgui.Create("DLabel", container)
    lbl:SetText(fieldInfo.label)
    lbl:Dock(LEFT)
    lbl:SetTextColor(Color(0, 0, 0))
    lbl:SetWide(200)
    lbl:DockMargin(0, 10, 5, 0)

    local entry
    if fieldInfo.type == "boolean" then
        local checkboxContainer = vgui.Create("DPanel", container)
        checkboxContainer:Dock(LEFT)
        checkboxContainer:SetWide(16)
        checkboxContainer:DockMargin(5, 12, 0, 0)
        checkboxContainer.Paint = nil
        
        entry = vgui.Create("DCheckBox", checkboxContainer)
        entry:SetSize(14, 14)
        entry:Center()
        entry:SetValue(value == "1" or value == true)
        
        entry.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(200, 200, 200))
            if self:GetChecked() then
                draw.RoundedBox(2, 2, 2, w-4, h-4, Color(41, 128, 185))
            end
        end
    elseif fieldInfo.type == "select" then
        entry = vgui.Create("DComboBox", container)
        entry:Dock(FILL)
        entry:DockMargin(0, 8, 0, 8)
        entry:SetSortItems(false)
        entry:SetTextColor(Color(0, 0, 0))
        
        for _, option in ipairs(fieldInfo.options) do
            entry:AddChoice(option.text, option.value)
        end
        
        for i, option in ipairs(fieldInfo.options) do
            if option.value == value then
                entry:ChooseOptionID(i)
                break
            end
        end
        
        if not entry:GetSelected() then
            entry:ChooseOptionID(1)
        end
    elseif fieldInfo.type == "number" then
        entry = vgui.Create("DNumberWang", container)
        entry:Dock(FILL)
        entry:DockMargin(0, 8, 0, 8)
        entry:SetValue(tonumber(value) or fieldInfo.default)
        entry:SetMin(0)
        entry:SetTextColor(Color(0, 0, 0))
    else
        entry = vgui.Create("DTextEntry", container)
        entry:Dock(FILL)
        entry:DockMargin(0, 8, 0, 8)
        entry:SetText(value or fieldInfo.default or "")
        entry:SetTextColor(Color(0, 0, 0))
        if fieldInfo.type == "multiline" then
            entry:SetMultiline(true)
            container:SetTall(100)
        end
    end
    
    return entry
end

function PANEL:LoadQuest(quest)
    self:Clear()
    
    if not IsValid(self) then return end
    
    local title = vgui.Create("DLabel", self)
    title:SetText(quest and "Edit Quest" or "New Quest")
    title:SetFont("DermaLarge")
    title:SetTextColor(Color(0, 0, 0))
    title:Dock(TOP)
    title:DockMargin(5, 5, 5, 20)
    title:SetTall(30)

    self.currentQuestType = quest and quest.type or nil
    self.fields = {}

    local fieldDefs = self:GetQuestTypeFields(self.currentQuestType)

    for _, fieldDef in ipairs(fieldDefs) do
        self.fields[fieldDef.name] = self:CreateField(fieldDef, quest and quest[fieldDef.name])
    end

    local saveBtn = vgui.Create("DButton", self)
    saveBtn:Dock(TOP)
    saveBtn:SetTall(40)
    saveBtn:DockMargin(5, 20, 5, 5)
    saveBtn:SetText("Save Quest")
    saveBtn:SetTextColor(Color(0, 0, 0))
    saveBtn.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() and Color(200, 255, 200, 255) or Color(180, 235, 180, 255))
    end

    saveBtn.DoClick = function()
        self:SaveQuest(quest)
    end
end

function PANEL:SaveQuest(quest)
    local questData = {
        type = self.currentQuestType,
        weight = tonumber(self.fields.weight:GetValue() or 1),
        uniqueId = quest and quest.uniqueId or util.SHA256(tostring(os.time()) .. tostring(math.random())),
        completed = false,
        rewardsClaimed = false,
        finishInOneRound = self.fields.finishInOneRound:GetChecked() and "1" or "0",
        rewards = {
            tostring(self.fields.rewardPoints:GetValue() or 0),
            tostring(self.fields.rewardPremium:GetValue() or 0),
            tostring(self.fields.rewardXP:GetValue() or 0)
        }
    }

    if self.currentQuestType == "KillQuest" then
        questData.requiredKills = tonumber(self.fields.requiredKills:GetValue() or 1)
        questData.killedRole = self.fields.killedRole:GetValue() or "0"
        questData.killerRole = self.fields.killerRole:GetValue() or "0"
        questData.currentKills = 0
    elseif self.currentQuestType == "WalkerQuest" then
        questData.requiredSteps = tonumber(self.fields.requiredSteps:GetValue() or 1000)
        questData.currentSteps = 0
    elseif self.currentQuestType == "SurviveQuest" then
        questData.requiredRounds = tonumber(self.fields.requiredRounds:GetValue() or 1)
        questData.currentRounds = 0
    elseif self.currentQuestType == "KarmaQuest" then
        questData.requiredRounds = tonumber(self.fields.requiredRounds:GetValue() or 1)
        questData.minKarma = tonumber(self.fields.minKarma:GetValue() or 1000)
        questData.currentRounds = 0
    end
    
    net.Start("AddQuest")
    net.WriteString(questData.type)
    net.WriteTable(questData)
    net.SendToServer()
    
    if self.OnQuestSaved then
        self.OnQuestSaved()
    end
end

vgui.Register("QuestEditor", PANEL, "DScrollPanel")

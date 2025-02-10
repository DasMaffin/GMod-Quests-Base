BaseQuestCardNoButton = {}

function BaseQuestCardNoButton:Init()
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

    -- Handle content resizing
    function self.content:OnSizeChanged(w, h)
        if IsValid(self:GetParent().claimButton) then
            self:GetParent().claimButton:SetPos(w - 150, h - 24)
        end
    end

    -- Progress container
    self.progress = vgui.Create("DPanel", self.content)
    self.progress:Dock(TOP)
    self.progress:DockMargin(0, 5, 0, 0)
    self.progress:SetTall(24)
    self.progress.Paint = nil
    
    self.requirementLabel = vgui.Create("DLabel", self.progress)
    self.requirementLabel:Dock(LEFT)
    self.requirementLabel:SetFont("Trebuchet18")
    self.requirementLabel:SetTextColor(Color(200, 200, 255))
    self.requirementLabel:SetContentAlignment(4)    
    
    self.progressLabel = vgui.Create("DLabel", self.progress)
    self.progressLabel:Dock(LEFT)
    self.progressLabel:SetFont("Trebuchet18")
    self.progressLabel:SetTextColor(Color(200, 200, 255))
    self.progressLabel:SetContentAlignment(4)
    
    self.questTypeImage = vgui.Create("DPanel", self)
    self.questTypeImage:SetSize(24, 24)
    self.questTypeImage:Center()    
    self.questTypeImage:SetContentAlignment(4) 
    self.questTypeImage:SetPos(250, self.title:GetTall() + 13)
    
    self.progressBar = vgui.Create("DPanel", self.content)
    self.progressBar:Dock(TOP)
    self.progressBar:DockMargin(0, 5, 5, 0)

    self.rewardsPreview = vgui.Create("DPanel", self.content)
    self.rewardsPreview:Dock(TOP)
    self.rewardsPreview:DockMargin(0, 0, 0, 0)
    self.rewardsPreview:SetSize(24, 24)
    self.rewardsPreview:Center()    
    self.rewardsPreview:SetContentAlignment(4)
    self.rewardsPreview.Paint = nil

    self.descriptionLabel = vgui.Create("DLabel", self.content)
    self.descriptionLabel:Dock(TOP)
    self.descriptionLabel:DockMargin(0, 5, 0, 0)
    self.descriptionLabel:SetTextColor(Color(200, 200, 255))
    self.descriptionLabel:SetContentAlignment(4)
    self.descriptionLabel:SetSize(self.content:GetWide(), 250)        
end

-- Register the base class
vgui.Register("BaseQuestCardNoButton", BaseQuestCardNoButton, "DPanel")
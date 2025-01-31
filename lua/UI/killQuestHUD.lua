local PANEL = {}

function PANEL:Init()
    --self:SetPaintBackground(false)
    PrintPink("Drawing Quest!")
    
    -- Modern card-style background
    self.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 55, 200))
    end
    
    -- Quest content container
    self.content = vgui.Create("DPanel", self)
    self.content:Dock(FILL)
    self.content:DockMargin(8, 8, 8, 8)
    self.content.Paint = nil
    
    -- Title styling
    self.title = vgui.Create("DLabel", self.content)
    self.title:Dock(TOP)
    self.title:SetFont("Trebuchet24")
    self.title:SetTextColor(color_white)
    self.title:SetContentAlignment(4)
    
    -- Progress container
    self.progress = vgui.Create("DPanel", self.content)
    self.progress:Dock(TOP)
    self.progress:DockMargin(0, 5, 0, 0)
    self.progress:SetTall(24)
    self.progress.Paint = nil
    
    -- Kill requirement display
    self.killsLabel = vgui.Create("DLabel", self.progress)
    self.killsLabel:Dock(LEFT)
    self.killsLabel:SetFont("Trebuchet18")
    self.killsLabel:SetTextColor(Color(200, 200, 255))
    self.killsLabel:SetContentAlignment(4)
end

function PANEL:SetQuest(data)
    self.title:SetText(data.title or "Unknown Quest")
    self.killsLabel:SetText(("Required Kills: %d"):format(data.requiredKills or 0))
    
    -- Size labels appropriately
    self.title:SizeToContents()
    self.killsLabel:SizeToContents()
end

vgui.Register("IntegratedHUDOne", PANEL, "EditablePanel")
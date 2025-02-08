ClaimButton = {}

function ClaimButton:Init()
    self.claimButton = vgui.Create("DButton", self)
    self.claimButton:SetSize(150, 32)
    self.claimButton:SetText("")
    self.claimButton:SetFont("DermaLarge")
    self.claimButton:SetMouseInputEnabled(true)
end

vgui.Register("ClaimButton", ClaimButton, "DPanel")
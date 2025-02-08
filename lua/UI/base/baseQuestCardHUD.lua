BaseQuestCard = {}

function BaseQuestCard:Init()
    BaseQuestCardNoButton.Init(self)

    ClaimButton.Init(self)

    self.progressBar:DockMargin(0, 5, self.claimButton:GetWide() + 20, 0)
    function self.content:OnSizeChanged(w, h)
        if IsValid(self:GetParent().claimButton) then
            self:GetParent().claimButton:SetPos(w - 150, h - 24)
        end
    end
end

-- Register the base class
vgui.Register("BaseQuestCard", BaseQuestCard, "DPanel")
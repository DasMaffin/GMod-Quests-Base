BaseQuestCard = {}

function BaseQuestCard:Init()
    BaseQuestCardNoButton.Init(self)

    ClaimButton.Init(self)

    self.progressBar:DockMargin(0, 5, 0, 0)
    function self.content:OnSizeChanged(w, h)
        if IsValid(self:GetParent().claimButton) then
            self:GetParent().claimButton:SetPos(w - 140, h - 20)
        end
    end
end

-- Register the base class
vgui.Register("BaseQuestCard", BaseQuestCard, "DPanel")
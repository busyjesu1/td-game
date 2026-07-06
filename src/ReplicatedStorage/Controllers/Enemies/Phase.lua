local TweenService = game:GetService("TweenService")

local Enemy = {}
Enemy.__index = Enemy

function Enemy:Hide(Transparent)
	self.Model.Head.Teleport:Play()
	
	local Transparency = Transparent and 1 or 0
	for i, v in pairs(self.Model:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = Transparency
			}):Play()
		end
	end
end

return Enemy
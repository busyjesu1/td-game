local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Cyrogunner = {}
Cyrogunner.__index = Cyrogunner

function Cyrogunner:Face(Target)
	if Target and Target.PrimaryPart then
		self.Model:PivotTo(CFrame.new(self.Model.PrimaryPart.Position, Vector3.new(Target.PrimaryPart.Position.X, self.Model.PrimaryPart.Position.Y, Target.PrimaryPart.Position.Z)))
	end
end

function Cyrogunner:Fire(ID)
	local Weapon = self.Model.Weapon:WaitForChild("Handle")
	local Target = workspace.Enemies:FindFirstChild(ID)
	if not Target then return end
	self:Face(Target)

	local StartAttach = Weapon:FindFirstChild("Start")
	if StartAttach then
		for _, Particle in pairs(StartAttach:GetDescendants()) do
			if Particle:IsA("ParticleEmitter") then Particle:Emit(1) end
		end
	end	
end

return Cyrogunner

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Projectile = require(ReplicatedStorage.Shared.Projectile)

local Mortar = {}
Mortar.__index = Mortar

function Mortar:Face(Target)
	if Target and Target.PrimaryPart then
		self.Model:PivotTo(CFrame.new(self.Model.PrimaryPart.Position, Vector3.new(Target.PrimaryPart.Position.X, self.Model.PrimaryPart.Position.Y, Target.PrimaryPart.Position.Z)))
	end
end

function Mortar:Fire(Data)
	local Target = workspace.Enemies:FindFirstChild(Data.Target)
	if not Target then return end
	self:Face(Target)

	local Weapon = self.Model.Weapon:WaitForChild("Handle")
	local StartAttach = Weapon:FindFirstChild("Start")
	if StartAttach then
		for _, Particle in pairs(StartAttach:GetDescendants()) do
			if Particle:IsA("ParticleEmitter") then Particle:Emit(1) end
		end
	end
	Data.Projectile.Model = ReplicatedStorage.Assets.Projectile.Bomb
	Projectile.Throw(Data.Projectile)
end

return Mortar

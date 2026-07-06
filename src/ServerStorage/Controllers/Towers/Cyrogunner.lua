local RunService = game:GetService("RunService")

local Minigunner = {}
Minigunner.__index = Minigunner

function Minigunner:Initialize()
	self.CurrentDelta = 0
	self.RevTime = 1.4
	self.Standing = true

	self.lastStance = tick()
	self.lastTarget = tick()

	self.Maid:GiveTask(RunService.Stepped:Connect(function(Time : number, DeltaTime : number)
		self.CurrentDelta += DeltaTime / self:GetCooldown()

		local Target = self:FindTarget()
		
		local serverTime = tick()

		if Target and self.CurrentDelta >= 1 then
			local RoundedShots = math.floor(self.CurrentDelta)
			self.CurrentDelta -= RoundedShots
			self:Replicate("Fire", Target.ID)
			Target.Debuffs:setTimed("Frozen", true, 2)
			Target:Damage(self, self:GetDamage() * RoundedShots)
		else
			self.CurrentDelta = math.min(self.CurrentDelta, 1)
		end
	end))
end

return Minigunner
local RunService = game:GetService("RunService")

local Minigunner = {}
Minigunner.__index = Minigunner

function Minigunner:Initialize()
	self.Burst = 5
	self.Cooldown = self:GetCooldown()
	self.CurrentDelta = 0

	self.Maid:GiveTask(RunService.Stepped:Connect(function(Time : number, DeltaTime : number)
		self.CurrentDelta += DeltaTime / self.Cooldown

		local Target = self:FindTarget()
		
		if Target and self.CurrentDelta >= 1 then
			self.Burst = math.clamp(self.Burst - 1, 0, math.huge)
			if self.Burst <= 0 then
				self.Burst = 5
				self.Cooldown = 0.4 / self:GetCooldown()
			else
				self.Cooldown = self:GetCooldown()
			end
			
			local RoundedShots = math.floor(self.CurrentDelta)
			self.CurrentDelta -= RoundedShots
			Target.Debuffs:setTimed("Slowness", true, 1)
			self:Replicate("Fire", Target.ID)
		else
			self.CurrentDelta = math.min(self.CurrentDelta, 1)
		end
	end))
end

return Minigunner
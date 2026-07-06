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

		if Target then
			if self.Standing then
				self.Standing = false
				self.lastStance = serverTime
			end

			if self.Standing == false and self.RevTime <= serverTime - self.lastStance then
				if self.CurrentDelta >= 1 then
					local RoundedShots = math.floor(self.CurrentDelta)
					self.CurrentDelta -= RoundedShots
					Target:Damage(self, self:GetDamage() * RoundedShots)
				end
			else
				self.CurrentDelta = math.min(self.CurrentDelta, 1)
			end

			self.lastTarget = serverTime
			return
		else
			if self.Standing == false and tick() - self.lastTarget >= 1 then
				self.Standing = true
			end

			self.CurrentDelta = math.min(self.CurrentDelta, 1)
		end
	end))
end

return Minigunner
local RunService = game:GetService("RunService")

local Enemy = {}
Enemy.__index = Enemy

function Enemy:Initialize()
	self.lastHide = tick()
	self.Cooldown = math.random(4, 8)

	self.Maid:GiveTask(RunService.Heartbeat:Connect(function(DeltaTime)
		if tick() - self.lastHide >= self.Cooldown then
			if self.Modifiers:get("Hidden") then
				self:Replicate("Hide", false)
				self.Modifiers:set("Hidden", false)
			else
				self:Replicate("Hide", true)
				self.Modifiers:set("Hidden", true)
			end
			
			self.lastHide = tick()
			self.Cooldown = math.random(4, 8)
		end
	end))
end

return Enemy
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)

local Enemy = {}
Enemy.__index = Enemy

function Enemy:Initialize()
	self.lastHeal = tick()
	self.Cooldown = math.random(15, 25)

	self.Maid:GiveTask(RunService.Heartbeat:Connect(function(DeltaTime)
		if tick() - self.lastHeal >= self.Cooldown then
			self.lastHeal = tick()
			self.Cooldown = math.random(15, 25)
			
			for _, Entity in pairs(EntityService.Entities) do
				if Entity.Type ~= "Enemies" then continue end
				
				local Distance = (self.CFrame.Position - Entity.CFrame.Position).Magnitude
				if Distance <= 12 then
					self.Health = math.clamp(self.Health + 25, 0, self.MaxHealth)
					self.Replicator:set("Health", self.Health)
				end
			end
		end
	end))
end

return Enemy
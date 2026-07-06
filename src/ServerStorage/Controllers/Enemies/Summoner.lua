local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)

local Enemy = {}
Enemy.__index = Enemy

function Enemy:Initialize()
	local spawns = {
		{"Normal", 5},
		{"Phase", 2},
		{"Slow", 3}
	}
	self.lastHide = tick()
	self.Cooldown = math.random(5, 15)

	self.Maid:GiveTask(RunService.Heartbeat:Connect(function(DeltaTime)
		if tick() - self.lastHide >= self.Cooldown then
			self.lastHide = tick()
			self.Cooldown = math.random(5, 15)
			
			local summonEnemy = spawns[math.random(1, #spawns)]
			if summonEnemy then
				for i = 1, summonEnemy[2] do
					EntityService:CreateEntity({
						Type = "Enemies",
						Name = summonEnemy[1],
						PathNumber = self.PathNumber,
						PathDistance = self.PathDistance + Random.new():NextNumber(-0.05, 0.05)
					})
				end
			end
		end
	end))
end

return Enemy
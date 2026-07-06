local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)

local Enemy = {}
Enemy.__index = Enemy

function Enemy:OnDeath()
	for i = 1, 3 do
		EntityService:CreateEntity({
			Type = "Enemies",
			Name = "Slow",
			
			PathNumber = self.PathNumber,
			PathDistance = self.PathDistance + Random.new():NextNumber(-0.05, 0.05)
		})
	end
end

return Enemy
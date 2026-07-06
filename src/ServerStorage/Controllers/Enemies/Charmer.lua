local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)

local Enemy = {}
Enemy.__index = Enemy

function Enemy:OnDeath()
	local hitCount = 0
	
	for _, Entity in pairs(EntityService.Entities) do
		if Entity.ID == self.ID or Entity.Type ~= "Enemies" then continue end

		local Distance = (self.CFrame.Position - Entity.CFrame.Position).Magnitude
		if Distance <= 12 and hitCount < 3 then
			hitCount += 1
			Entity.Reverse = true
			Entity.Replicator:set("Reverse", true)
		end
	end
end

return Enemy
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)
local Modules = Loader:Initialize()

task.delay(10, function()
	for _, Enemy in pairs(ReplicatedStorage.Assets.Enemies:GetChildren()) do
		for i = 1, 1 do
			Modules.EntityService:CreateEntity({
				Type = "Enemies",
				Name = Enemy.Name,  
				Health = 100,
				PathNumber = 1,
				Speed = 4,
			})
			task.wait(0.08)
		end
		task.wait(0.5)
	end
end)
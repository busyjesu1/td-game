local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EntityClass = require(ReplicatedStorage.Classes.Entity)

local EntityService = {}

function EntityService:CreateEntity(props)
	assert(props.Type, "Missing entity type")
	
	local Entity = EntityClass.new(props)
	if Entity then
		self.Entities[Entity.RootPointer] = Entity
		Entity.Maid:GiveTask(function()
			self.Entities[Entity.RootPointer] = nil
		end)
	end
	
	return Entity
end

function EntityService.Initialize(self)
	self.Entities = {}

	local StartTime = workspace:GetServerTimeNow()
	RunService.Heartbeat:Connect(function(deltaTime)
		local Elapsed = workspace:GetServerTimeNow() - StartTime
		StartTime = workspace:GetServerTimeNow()
		for _, Entity in self.Entities do
			Entity:Update(Elapsed)
		end
	end)
end

return EntityService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Packets = require(ReplicatedStorage.Shared.Packets)
local EntityClass = require(ReplicatedStorage.Classes.Entity)

local NPCReplicate = Packets.NPCReplicate

local EntityController = {}

function EntityController.Initialize(self)
	self.Entities = {}
	
	local StartTime = workspace:GetServerTimeNow()
	RunService.Heartbeat:Connect(function(deltaTime)
		local Elapsed = workspace:GetServerTimeNow() - StartTime
		StartTime = workspace:GetServerTimeNow()
		for _, Entity in self.Entities do
			Entity:Update(Elapsed)
		end
	end)
	
	NPCReplicate.OnClientEvent:Connect(function(ActionName, ID, ...)
		local RootPointer = ReplicatedStorage.Replicators:FindFirstChild(ID)
		local Entity = self.Entities[RootPointer]
		if Entity then
			Entity:Replicate(ActionName, ...)
		end
	end)
	
	local CreateEntity = function(RootPointer)
		local Entity = EntityClass.new({
			RootPointer = RootPointer
		})
		self.Entities[RootPointer] = Entity
	end
	
	CollectionService:GetInstanceAddedSignal("Entity"):Connect(CreateEntity)
	CollectionService:GetInstanceRemovedSignal("Entity"):Connect(function(RootPointer)
		local Entity = self.Entities[RootPointer]
		if Entity then
			Entity:Destroy()
			self.Entities[RootPointer] = nil
		end
	end)
	for _, RootPointer in CollectionService:GetTagged("Entity") do
		CreateEntity(RootPointer)
	end
end

return EntityController
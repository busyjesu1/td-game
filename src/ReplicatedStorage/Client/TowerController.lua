local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Packets = require(ReplicatedStorage.Shared.Packets)
local TowerClass = require(ReplicatedStorage.Classes.Tower)

local TowerReplicate = Packets.TowerReplicate

local TowerController = {}

function TowerController.Initialize(self)
	self.Towers = {}
	
	local CreateTower = function(RootPointer)
		local Tower = TowerClass.new({
			RootPointer = RootPointer
		})
		self.Towers[RootPointer] = Tower
	end
	

	TowerReplicate.OnClientEvent:Connect(function(ActionName, ID, ...)
		local RootPointer = ReplicatedStorage.Replicators:FindFirstChild(ID)
		local Tower = self.Towers[RootPointer]
		if Tower then
			Tower:Replicate(ActionName, ...)
		end
	end)
	
	CollectionService:GetInstanceAddedSignal("Tower"):Connect(CreateTower)
	CollectionService:GetInstanceRemovedSignal("Tower"):Connect(function(RootPointer)
		local Tower = self.Towers[RootPointer]
		if Tower then
			Tower:Destroy()
			self.Towers[RootPointer] = nil
		end
	end)
	for _, RootPointer in CollectionService:GetTagged("Entity") do
		CreateTower(RootPointer)
	end
end

return TowerController
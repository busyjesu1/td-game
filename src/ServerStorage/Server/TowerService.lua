local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerClass = require(ReplicatedStorage.Classes.Tower)
local TowerStats = require(ReplicatedStorage.Shared.TowerStats)
local Packet = require(ReplicatedStorage.Packages.Packet)

local Place = Packet("Place", Packet.String, Packet.String, Packet.CFrameF24U8):Response(Packet.Boolean8)

local TowerService = {}

function TowerService:CreateTower(props)
	assert(props.Name, "Missing tower type")
	
	local Tower = TowerClass.new(props)
	if Tower then
		self.Towers[Tower.RootPointer] = Tower
		Tower.Maid:GiveTask(function()
			self.Towers[Tower.RootPointer] = nil
		end)
	end
	
	return Tower
end

function TowerService.Initialize(self)
	self.Towers = {}
	
	Place.OnServerInvoke = function(player, tower, skin, pos)
		local Tower = self:CreateTower({
			Owner = player,
			Name = tower,
			Skin = skin,
			Stats = TowerStats[tower],
			CFrame = pos,
		})
		
		return Tower ~= nil
	end
end

return TowerService
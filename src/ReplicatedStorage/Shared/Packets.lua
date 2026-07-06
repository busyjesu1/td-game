local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packet = require(ReplicatedStorage.Packages.Packet)

local NPCReplicate = Packet("NPCReplicate", Packet.String, Packet.StringLong, Packet.Any)
local TowerReplicate = Packet("TowerReplicate", Packet.String, Packet.StringLong, Packet.Any)

return {
	TowerReplicate = TowerReplicate,
	NPCReplicate = NPCReplicate
}
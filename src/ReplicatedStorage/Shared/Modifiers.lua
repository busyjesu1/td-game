local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttributeReplicator = require(ReplicatedStorage.Shared.AttributeReplicator)

local Modifiers = {}
Modifiers.__index = Modifiers

function Modifiers.new(Entity)
	local self = setmetatable({}, Modifiers)
	
	self.Entity = Entity
	
	self.Maid = self.Entity.Maid
	self.Replicator = AttributeReplicator.new(Entity.RootPointer.Modifiers, {})
	
	return self
end

function Modifiers.get(self, name, value)
	return self.Replicator:get(name)
end

function Modifiers.set(self, name, value)
	return self.Replicator:set(name, value)
end

function Modifiers.Destroy(self)
	if self.Replicator then
		self.Replicator:Destroy()
		self.Replicator = nil
	end
end

return Modifiers

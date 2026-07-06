local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttributeReplicator = require(ReplicatedStorage.Shared.AttributeReplicator)

local Debuffs = {}
Debuffs.__index = Debuffs

local Modules = {}
for _, module in script:GetChildren() do
	Modules[module.Name] = require(module)
end

function Debuffs.new(Entity)
	local self = setmetatable({}, Debuffs)
	
	self.Entity = Entity
	self.Queues = {}
	self.Maid = self.Entity.Maid
	self.Replicator = AttributeReplicator.new(Entity.RootPointer.Debuffs, {})
	
	self.Maid:GiveTask(self.Replicator.StateChanged:Connect(function(name, value)
		self:onChanged(name, value)
	end))
	
	return self
end

function Debuffs.onChanged(self, name, value)
	local _debuff = Modules[name]
	if not _debuff then 
		return
	else
		local method = value and _debuff.onAdded or _debuff.onRemoved
		
		if method and typeof(method) == "function" then
			method(self.Entity)
		end
	end
end

function Debuffs.get(self, name)
	return self.Replicator:get(name)
end

function Debuffs.setTimed(self, name, value, waitTime)
	local oldQueue = self.Queues[name]
	if oldQueue then
		task.cancel(oldQueue)
		self.Queues[name] = nil
	end
	
	self.Replicator:set(name, value)
	self.Queues[name] = task.delay(waitTime, function()
		self.Queues[name] = nil
		if self.Replicator then
			self.Replicator:set(name, false)
		end
	end)
end

function Debuffs.set(self, name, value)
	return self.Replicator:set(name, value)
end

function Debuffs.Destroy(self)
	if self.Replicator then
		self.Replicator:Destroy()
		self.Replicator = nil
	end
end

return Debuffs

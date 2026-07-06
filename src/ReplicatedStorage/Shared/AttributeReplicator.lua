local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Maid = require(ReplicatedStorage.Packages.Maid)
local Signal = require(ReplicatedStorage.Packages.Signal)

local AttributeSerializer = require(script.Parent.AttributeSerializer)

local AttributeReplicator = {}
AttributeReplicator.__index = AttributeReplicator

function AttributeReplicator.new(RootPointer, initialState : {[string] : any})
	local self = setmetatable({}, AttributeReplicator) 
	
	self.StateChanged = Signal.new()
	self.Maid = Maid.new()
	self.RootPointer = RootPointer
	self.State = {}
	
	if RunService:IsServer() then
		for name, value in pairs(initialState) do
			self.RootPointer:SetAttribute(name, AttributeSerializer.Serialize(value))
		end
	end
	
	for name, value in pairs(RootPointer:GetAttributes()) do
		self.State[name] = AttributeSerializer.Deserialize(value)
	end
	
	self.Maid:GiveTask(function()
		if RunService:IsServer() then
			self.RootPointer:Destroy()
			self.RootPointer = nil
		end
	end)
	self.Maid:GiveTask(RootPointer.AttributeChanged:Connect(function(attribute)
		local newValue = RootPointer:GetAttribute(attribute)
		if newValue ~= nil then
			newValue = AttributeSerializer.Deserialize(newValue)
		end
		self.State[attribute] = newValue
		self.StateChanged:Fire(attribute, newValue)
	end))
	
	return self
end

function AttributeReplicator.Hook(self, tbl)
	for name, value in pairs(self.RootPointer:GetAttributes()) do
		tbl[name] = AttributeSerializer.Deserialize(value)
	end
	
	self.Maid:GiveTask(self.StateChanged:Connect(function(attribute, value)
		tbl[attribute] = AttributeSerializer.Deserialize(value)
	end))
end

function AttributeReplicator.Destroy(self)
	if self.Maid then
		self.Maid:Destroy()
		self.Maid = nil
	end
end

function AttributeReplicator.OnChanged(self, name)
	local onChanged = Signal.new()
	self.Maid:GiveTask(onChanged)
	self.Maid:GiveTask(self.StateChanged:Connect(function(N, value)
		if N == name then
			onChanged:Fire(value)
		end
	end))	
	return onChanged
end

function AttributeReplicator.getAll(self)
	return self.State
end

function AttributeReplicator.get(self, name)
	return AttributeSerializer.Deserialize(self.RootPointer:GetAttribute(name))
end

function AttributeReplicator.set(self, name, value)
	local Serialized = AttributeSerializer.Serialize(value)
	if self.RootPointer then
		self.RootPointer:SetAttribute(name, Serialized)
	end
end

return AttributeReplicator

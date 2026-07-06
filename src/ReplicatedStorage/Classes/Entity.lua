local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Maid = require(ReplicatedStorage.Packages.Maid)
local Modifiers = require(ReplicatedStorage.Shared.Modifiers)
local Debuffs = require(ReplicatedStorage.Shared.Debuffs)
local Packets = require(ReplicatedStorage.Shared.Packets)
local AttributeReplicator = require(ReplicatedStorage.Shared.AttributeReplicator)
local PathController = require(ReplicatedStorage.Shared.PathController)

local NPCReplicate = Packets.NPCReplicate

local Entity = {}
Entity.__index = Entity

function Entity.new(props)
	local self = setmetatable({}, Entity)
	
	self.Maid = Maid.new()
	
	if RunService:IsServer() then
		self:_initServer(props)
	else
		self:_initClient(props)
	end
	
	self.Path = PathController.Paths[self.PathNumber]
	self.Debuffs = Debuffs.new(self)
	self.Modifiers = Modifiers.new(self)
	
	self.Maid:GiveTask(self.Modifiers)
	self.Maid:GiveTask(self.Debuffs)
	self.Maid:GiveTask(function()
		if self.Replicator then
			self.Replicator:Destroy()
			self.Replicator = nil
		end
	end)
	
	if self.Initialize then
		self:Initialize()
	end
	
	return self
end

function Entity._playAnimation(self, Animation, AdjustSpeed)
	if self.Model and Animation then
		local AnimationController = self.Model:FindFirstChildOfClass("AnimationController")
		local Animator = AnimationController:FindFirstChildOfClass("Animator")
			or Instance.new("Animator", AnimationController)
		
		local Track = Animator:LoadAnimation(Animation)
		Track:Play(0.01)
		if AdjustSpeed then
			task.spawn(function()
				while Track.Length == 0 do task.wait() end
				Track:AdjustSpeed((self.Speed / (Track.Length * 2.7) * (Animation:GetAttribute("Speed") or 1)))
			end)
			
			local Connection = self.Replicator:OnChanged("Speed"):Connect(function(Value)
				Track:AdjustSpeed((Value / (Track.Length * 2.7) * (Animation:GetAttribute("Speed") or 1)))
			end)
			Track.Destroying:Once(function()
				Connection:Disconnect()
				Connection = nil
			end)
		end
		return Track
	end
end

function Entity._createModel(self)
	local EntityModel = ReplicatedStorage.Assets[self.Type]:FindFirstChild(self.Name)
	if EntityModel then
		self.Model = EntityModel:Clone()
		self.Model.Name = self.ID
		self.Model.Parent = workspace.Enemies
		self.Maid:GiveTask(self.Model)
	end
	
	local WalkAnimation = self.Model.Animations:FindFirstChild("Walk")
	if WalkAnimation then
		local Animation = WalkAnimation:IsA("Folder") and WalkAnimation:GetChildren()[math.random(1, #WalkAnimation:GetChildren())] or WalkAnimation
		self:_playAnimation(Animation, true)
	end
	
	local Origin = self.Model.PrimaryPart:FindFirstChild("Origin") or self.Model.PrimaryPart:FindFirstChild("Node")
	self.Height = -Origin.Position.Y
end

function Entity._initClient(self, props)
	self.RootPointer = props.RootPointer
	self.Replicator = AttributeReplicator.new(props.RootPointer)
	
	self.Replicator:Hook(self)
	
	local Controller = ReplicatedStorage.Controllers[self.Type]:FindFirstChild(self.Name)
	if Controller then
		Controller = require(Controller)
		setmetatable(self, setmetatable(Controller, Entity))
	end
		
	self:_createModel()
end

function Entity._initServer(self, props)
	local ID = props.ID or HttpService:GenerateGUID(false)
	local RootPointer = Instance.new("Folder")
	RootPointer.Name = ID
	RootPointer.Parent = ReplicatedStorage.Replicators
	
	local Debuffs = Instance.new("Folder")
	Debuffs.Name = "Debuffs"
	Debuffs.Parent = RootPointer
	
	local Modifiers = Instance.new("Folder")
	Modifiers.Name = "Modifiers"
	Modifiers.Parent = RootPointer
	
	RootPointer:AddTag("Entity")
	
	self.RootPointer = RootPointer
	
	self.Type = props.Type or "Enemies"
	self.ID = ID
	self.Name = props.Name or "Normal"
	self.MaxHealth = props.Health or 100
	self.Health = props.Health or 100
	self.PositionOffset = props.PositionOffset or Random.new():NextNumber(-0.5, 0.5)
	self.PathDistance = props.PathDistance or 0
	self.PathNumber = props.PathNumber or 1
	self.Speed = props.Speed or 5
	self.BaseSpeed = self.Speed
	self.Stopped = false
	self.Reverse = false
	
	self.Replicator = AttributeReplicator.new(RootPointer, {
		Type = self.Type,
		Name = self.Name,
		ID = self.ID,
		Health = self.Health,
		PositionOffset = self.PositionOffset,
		PathDistance = self.PathDistance,
		PathNumber = self.PathNumber,
		Speed = self.Speed,
		BaseSpeed = self.BaseSpeed,
		Stopped = self.Stopped,
		Reverse = self.Reverse,
	})
	
	local Controller = ServerStorage.Controllers[self.Type]:FindFirstChild(self.Name)
	if Controller then
		Controller = require(Controller)
		setmetatable(self, setmetatable(Controller, Entity))
	end
	
	self.Replicator:OnChanged("Health"):Connect(function(Value)
		if Value <= 0 then
			self:Destroy()
		end
	end)
end

function Entity.IsAlive(self)
	return self.Replicator ~= nil and self.Health > 0
end

function Entity.UpdateSpeed(self)
	local debuffs = 0
	for _, perc in pairs({
		self.FrostDebuff,
		self.SlownessDebuff,
		self.StunDebuff,
		}) do
		debuffs += perc
	end
	self.Speed = math.clamp(self.BaseSpeed - (self.BaseSpeed * (debuffs / 100)), 0, math.huge)
	self.Replicator:set("Speed", self.Speed)
end

function Entity.Replicate(self, Action, ...)
	if RunService:IsServer() then
		NPCReplicate:Fire(Action, self.ID, {...})
	else
		local Executable = self.Executables and self.Executables[Action] or self[Action]
		if Executable and typeof(Executable) == "function" then
			Executable(self, unpack(...))
		end
	end
end

function Entity.Damage(self, Origin, Amount)
	if self:IsAlive() then
		self.Health = math.clamp(self.Health - Amount, 0, self.MaxHealth)
		self.Replicator:set("Health", self.Health)
	end
end

function Entity.Update(self, deltaTime)
	
	if not self.Stopped and self.Path then
		local PathLength = self.Path:GetPathLength()
		if not self.Replicator then
			return
		else
			if self.Reverse then
				self.PathDistance = math.clamp(self.PathDistance - deltaTime * self.Speed, 0, PathLength)
			else
				self.PathDistance = math.clamp(self.PathDistance + deltaTime * self.Speed, 0, PathLength)
			end
		end

		local T = self.PathDistance / PathLength
		self.CFrame = self.Path:CalculateUniformCFrame(T)
		
		if RunService:IsServer() then
			if T >= 1 then
				self:Destroy()
			end
		end
		if self.Model and RunService:IsClient() then
			workspace:BulkMoveTo(
				{ self.Model.PrimaryPart },
				{ self.CFrame * CFrame.new(self.PositionOffset, self.Height, self.PositionOffset) },
				Enum.BulkMoveMode.FireCFrameChanged
			)
		end 
	end
end

function Entity.Destroy(self)
	if self.OnDeath then
		self:OnDeath()
	end
	
	if self.Maid then
		self.Maid:DoCleaning()
		self.Maid = nil
	end
end

return Entity

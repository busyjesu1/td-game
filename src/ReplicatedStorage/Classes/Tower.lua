local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local AttributeReplicator = require(ReplicatedStorage.Shared.AttributeReplicator)
local Packets = require(ReplicatedStorage.Shared.Packets)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Targetting = RunService:IsServer() and require(ServerStorage.Server.Modules.Targetting) or nil

local TowerReplicate = Packets.TowerReplicate

local Tower = {}
Tower.__index = Tower

function Tower.new(props)
	local self = setmetatable({}, Tower)
	
	self.Maid = Maid.new()
	
	if RunService:IsServer() then
		self:_initServer(props)
	else
		self:_initClient(props)
	end
	
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

function Tower._loadAnimation(self, Properties)
	assert(self.Model and RunService:IsClient(), "Animations can only be loaded on the client")
	
	local Track = self.Animator:LoadAnimation(Properties.Track)
	Track.Looped = Properties.Looped
	return Track
end

function Tower._createModel(self)
	assert(self.Name and self.Skin, "Missing name and skin")
	local TowerFolder = ReplicatedStorage.Assets.Towers:FindFirstChild(self.Name)
	if TowerFolder then
		local TowerModel = TowerFolder.Skins:FindFirstChild(self.Skin) or TowerFolder.Skins:FindFirstChild("Default")
		if TowerModel then
			TowerModel = TowerModel:Clone()
			self.Model = TowerModel
		end
	end
	
	if self.Model then
		local Origin = self.Model.PrimaryPart:FindFirstChild("Origin") or self.Model.PrimaryPart:FindFirstChild("HeightOffset")
		local AnimationController = self.Model:FindFirstChildOfClass("AnimationController")
		local Animator = AnimationController:FindFirstChildOfClass("Animator")
			or Instance.new("Animator", AnimationController)
		self.Animator = Animator
		
		local IdleAnim = self.Model.Animations:FindFirstChild("Idle")
		
		if IdleAnim then
			IdleAnim = IdleAnim:IsA("Folder") and IdleAnim:GetChildren()[math.random(1, #IdleAnim:GetChildren())] or IdleAnim
			local Anima = self:_loadAnimation({
				Track = IdleAnim,
				Looped = true
			})
			Anima:Play(0.01)
		end
		
		self.Height = -Origin.Position.Y
		self.Model:PivotTo(self.CFrame * CFrame.new(0, self.Height, 0))
		self.Model.Parent = workspace.Towers
	end
end

function Tower._initClient(self, props)
	self.Replicator = AttributeReplicator.new(props.RootPointer)
	
	self.Name = self.Replicator:get("Name")
	self.Skin = self.Replicator:get("Skin")
	self.TargetMode = self.Replicator:get("TargetMode")
	self.Detections = self.Replicator:get("Detections")
	self.Stats = self.Replicator:get("Stats")
	self.CFrame = self.Replicator:get("CFrame")
	self.Owner = self.Replicator:get("Owner")
	self.ID = self.Replicator:get("ID")
	
	local Controller = ReplicatedStorage.Controllers.Towers:FindFirstChild(self.Name)
	if Controller then
		Controller = require(Controller)
		setmetatable(self, setmetatable(Controller, Tower))
	end
	
	self:_createModel()
end

function Tower._initServer(self, props)
	local ID = props.ID or HttpService:GenerateGUID(false)
	local RootPointer = Instance.new("Folder")
	RootPointer.Name = ID
	RootPointer.Parent = ReplicatedStorage.Replicators
	RootPointer:AddTag("Tower")
	
	self.RootPointer = RootPointer
	
	self.Name = props.Name or "Minigunner"
	self.Skin = props.Skin or "Default"
	self.ID = ID
	self.Target = ""
	self.TargetMode = props.TargetMode or "First"
	self.Detections = props.Detections or {}
	self.Stats = props.Stats or {
		Damage = 10,
		Cooldown = 1,
		Range = 12,
	}
	self.CFrame = props.CFrame or CFrame.new()
	self.Owner = props.Owner ~= nil and props.Owner.UserId
	
	self.Replicator = AttributeReplicator.new(RootPointer, {
		Name = self.Name,
		Skin = self.Skin,
		ID = self.ID,
		Target = self.Target,
		TargetMode = self.TargetMode,
		Detections = self.Detections,
		Stats = self.Stats,
		CFrame = self.CFrame,
		Owner = self.Owner
	})
	
	local Controller = ServerStorage.Controllers.Towers:FindFirstChild(self.Name)
	if Controller then
		Controller = require(Controller)
		setmetatable(self, setmetatable(Controller, Tower))
	end
end

function Tower.FindTarget(self)
	if Targetting then
		local BestTarget = Targetting.FindTarget(self)
		if BestTarget then
			self.Target = BestTarget.ID
			self.Replicator:set("Target", self.Target)
		end
		
		return BestTarget
	else
		local TargetID = self.Replicator:get("Target")
		return (TargetID ~= nil and TargetID ~= "") and workspace.Enemies:FindFirstChild(TargetID)
	end
end

function Tower.Replicate(self, Action, ...)
	if RunService:IsServer() then
		TowerReplicate:Fire(Action, self.ID, {...})
	else
		local Executable = self.Executables and self.Executables[Action] or self[Action]
		if Executable and typeof(Executable) == "function" then
			Executable(self, unpack(...))
		end
	end
end

function Tower.GetDamage(self)
	return self.Stats.Damage
end

function Tower.GetCooldown(self)
	return self.Stats.Cooldown
end

function Tower.GetRange(self)
	return self.Stats.Range
end

function Tower.Destroy(self)
	if self.Maid then
		self.Maid:DoCleaning()
		self.Maid = nil
	end
end

return Tower
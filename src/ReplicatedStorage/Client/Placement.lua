local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Maid = require(ReplicatedStorage.Packages.Maid)
local Packet = require(ReplicatedStorage.Packages.Packet)

local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local CurrentCamera = workspace.CurrentCamera
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Include
RayParams.IgnoreWater = true
RayParams.FilterDescendantsInstances = {
	workspace.Map.Cliff,
	workspace.Map.Ground,
}

local Keybinds = {
	[1] = Enum.KeyCode.One,
	[2] = Enum.KeyCode.Two,
	[3] = Enum.KeyCode.Three,
	[4] = Enum.KeyCode.Four,
	[5] = Enum.KeyCode.Five,
}
local Loadout = {"Cyrogunner", "Gunner", "Mortar", "Minigunner", "Sniper"}
local CliffTowers = {"Sniper", "Mortar"}

local Place = Packet("Place", Packet.String, Packet.String, Packet.CFrameF24U8):Response(Packet.Boolean8)

local Placement = {}

function Placement.Initialize(self)
	self.Maid = Maid.new()
	
	self.State = {
		Tower = "Mortar",
		Skin = "Default",
	}
	
	InputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		for slot, bind in pairs(Keybinds) do
			if input.KeyCode == bind then
				local tower = Loadout[slot]
				self.State.Tower = tower
				if self.Active then
					self:Stop()
				else
					self:Start()
				end
			end
		end
	end)
end

function Placement.Start(self)
	local Tower = ReplicatedStorage.Assets.Towers:FindFirstChild(self.State.Tower)
	if Tower and Tower:FindFirstChild("Skins") then
		local Skin = Tower.Skins:FindFirstChild(self.State.Skin)
		if Skin then
			Tower = Skin:Clone()
		end
	end
	assert(Tower, "Missing tower model")
	
	self.Maid:DoCleaning()
	self.Rotation = 0
	self.Active = true
	
	local IdleAnim = Tower.Animations:FindFirstChild("Idle")
	local Origin = Tower.PrimaryPart:FindFirstChild("Origin")
	if IdleAnim then
		Tower.AnimationController:LoadAnimation(IdleAnim):Play()
	end
	if Origin then
		self.Height = -Origin.Position.Y
	end
	
	self.Model = Tower
	self.Model.Parent = CurrentCamera
	self.Maid:GiveTask(self.Model)
	
	RunService:BindToRenderStep("Placement", Enum.RenderPriority.Camera.Value, function()
		self:Update()
	end)
	
	self.Maid:GiveTask(InputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:Place()
			return
		end
		
		if input.KeyCode == Enum.KeyCode.R then
			self.Rotation = self.Rotation + 90
		elseif input.KeyCode == Enum.KeyCode.Q then
			self:Stop()
		end
	end))
	
	self.Maid:GiveTask(function()
		RunService:UnbindFromRenderStep("Placement")
	end)
end

function Placement.Cast(self)
	local RayPoint = CurrentCamera:ScreenPointToRay(PlayerMouse.X, PlayerMouse.Y)
	local RayResult = workspace:Raycast(RayPoint.Origin, RayPoint.Direction * 2048, RayParams)
	return RayResult
end

function Placement.Update(self)
	local RayResult : RaycastResult = self:Cast()
	local Class = table.find(CliffTowers, self.State.Tower) and "Cliff" or "Ground"
	if RayResult and RayResult.Instance and RayResult.Position then
		if RayResult.Instance:FindFirstAncestor(Class) and RayResult.Normal:Dot(Vector3.yAxis) > 0.99 then
			self.Authorized = true
		else
			self.Authorized = false
		end
		
		self.Position = CFrame.new(RayResult.Position + Vector3.new(0, self.Height, 0)) * CFrame.Angles(0, math.rad(self.Rotation), 0)
		self.Model:PivotTo(self.Position)
	end
end

function Placement.Place(self)
	if not self.Authorized then return "Invalid placement" end
	
	local Success = Place:Fire(self.State.Tower, self.State.Skin, self.Position * CFrame.new(0, -self.Height, 0))
	
	if Success then
		self:Stop()
	end
end

function Placement.Stop(self)
	self.Maid:DoCleaning()
	self.Active = false
end

return Placement

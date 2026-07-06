local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Loader = {}

function Loader:InitModules(Folder)
	for _, Module in pairs(Folder:GetChildren()) do
		if Module:IsA("ModuleScript") then
			if Module == script then continue end
			local Controller = require(Module)
			if Controller.Initialize then
				Controller:Initialize()
			end
			self.Modules[Module.Name] = Controller
		end
	end
end

function Loader:Initialize()
	self.Modules = {}
	
	self:InitModules(ReplicatedStorage.Shared)
	if RunService:IsClient() then
		self:InitModules(ReplicatedStorage.Client)
	else
		self:InitModules(ServerStorage.Server)
	end
	
	return self.Modules
end

return Loader
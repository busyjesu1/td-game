local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)
local Projectile = require(ReplicatedStorage.Shared.Projectile)

local Mortar = {}
Mortar.__index = Mortar

function Mortar:Initialize()
	self.Cooldown = self:GetCooldown()
	self.CurrentDelta = 0
	warn(self.Cooldown)
	self.Maid:GiveTask(RunService.Stepped:Connect(function(Time : number, DeltaTime : number)
		self.CurrentDelta += DeltaTime / self.Cooldown

		local Target = self:FindTarget()
		
		if Target and self.CurrentDelta >= 1 then
			local RoundedShots = math.floor(self.CurrentDelta)
			self.CurrentDelta -= RoundedShots
			
			local Data = {
				Start = self.CFrame.Position,
				End = Target.CFrame.Position,
				Speed = 0.4,
				Type = "Curve",
				Time = workspace:GetServerTimeNow(),
			}

			self:Replicate("Fire", {
				Projectile = Data,
				Target = Target.ID
			})

			Projectile.Throw(Data).Reached:Connect(function()
				for _, Entity in pairs(EntityService.Entities) do
					if Entity:IsAlive() and Entity.Type == "Enemies" and (self.CFrame.Position - Entity.CFrame.Position).Magnitude <= 10 then
						Target:Damage(self, self:GetDamage() * RoundedShots)
					end
				end
			end)
		else
			self.CurrentDelta = math.min(self.CurrentDelta, 1)
		end
	end))
end

return Mortar
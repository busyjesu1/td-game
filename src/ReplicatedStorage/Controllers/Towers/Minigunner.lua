local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Minigunner = {}
Minigunner.__index = Minigunner

local function HandleParticles(Parent, Bool)
	for _, Object in pairs(Parent:GetDescendants()) do
		if Object:IsA("ParticleEmitter") then
			Object.Enabled = Bool
		end
	end
end

local function HandleEffects(Weapon, Bool)
	local Handle = Weapon:FindFirstChild("Handle")
	local BarrelPart = Weapon:FindFirstChild("Barrel")
	local Barrel = Handle:FindFirstChild("Barrel")
	if Barrel then
		TweenService:Create(Barrel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			MaxVelocity = Bool and 0.25 or 0
		}):Play()
		HandleParticles(BarrelPart, Bool)
	end
end

function Minigunner:Face()
	if self._Target and self._Target.PrimaryPart then
		self.Model:PivotTo(CFrame.new(self.Model.PrimaryPart.Position, Vector3.new(self._Target.PrimaryPart.Position.X, self.Model.PrimaryPart.Position.Y, self._Target.PrimaryPart.Position.Z)))
	end
end

function Minigunner:Initialize()
	local fireAnim = self:_loadAnimation({
		Track = self.Model.Animations.Fire,
	})
	local holsterAnim = self:_loadAnimation({
		Track = self.Model.Animations.Holster,
	})

	self.CurrentDelta = 0
	self.RevTime = 1.4
	self.Standing = true

	self.lastStance = tick()
	self.lastTarget = tick()

	self.Maid:GiveTask(RunService.Heartbeat:Connect(function(DeltaTime : number)
		self.CurrentDelta += DeltaTime / self.Stats.Cooldown
		self._Target = self:FindTarget()
		
		local serverTime = tick()
		if (self._Target) then
			if self.Standing then
				self.Standing = false
				HandleEffects(self.Model.Weapon.Minigun, true)
				holsterAnim:Play()
				fireAnim:Stop()
				self.lastStance = serverTime
			end

			if self.Standing == false and self.RevTime <= serverTime - self.lastStance then
				if self.CurrentDelta >= 1 then
					local RoundedShots = math.floor(self.CurrentDelta)
					self.CurrentDelta -= RoundedShots

					local Weapon = self.Model.Weapon:FindFirstChild("Minigun") and self.Model.Weapon:FindFirstChild("Minigun"):FindFirstChild("Handle")
					if Weapon then							
						local FireSound = Weapon:FindFirstChild("Fire")
						if FireSound then
							FireSound = FireSound:Clone()
							FireSound.Parent = Weapon
							FireSound.PlaybackSpeed = Random.new():NextNumber(0.8, 1.2)
							FireSound:Play()
							game.Debris:AddItem(FireSound, FireSound.TimeLength)
						end

						local StartAttach = Weapon:FindFirstChild("Start")
						if StartAttach then
							for _, Particle in pairs(StartAttach:GetDescendants()) do
								if Particle:IsA("ParticleEmitter") then
									Particle:Emit(1)
								end
							end
						end
					end
					
					fireAnim:AdjustSpeed(1 / (self.Stats.Cooldown * 10))
					fireAnim:Play()
					self:Face()
				end
			else
				self:Face()
				self.CurrentDelta = math.min(self.CurrentDelta, 1)
			end

			self.lastTarget = serverTime
			return
		else
			if self.Standing == false and tick() - self.lastTarget >= 1 then
				self.Standing = true
				holsterAnim:Stop(1)
				fireAnim:Stop(1)
				HandleEffects(self.Model.Weapon.Minigun, false)
			end

			self.CurrentDelta = math.min(self.CurrentDelta, 1)
		end
	end))
end

return Minigunner

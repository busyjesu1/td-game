local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsClient = RunService:IsClient()

local Signal = require(ReplicatedStorage.Packages.Signal)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Assets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Projectile")

function lerp(a, b, t)
	return a + (b - a) * t
end

function quadraticBezier(t, p0, p1, p2)
	local l1 = lerp(p0, p1, t)
	local l2 = lerp(p1, p2, t)
	local quad = lerp(l1, l2, t)
	return quad
end

local Projectile = {}

function Projectile.Throw(Data)
	local ProjType = Data.Type or "Linear"
	if Data.Model then
		Data.Model = Data.Model:Clone()
		Data.Model.Parent = workspace.CurrentCamera
	end

	local Reached = Signal.new()
	local ProjectileMaid = Maid.new()
	local Alpha = 0
	local Connection = nil
	local Distance = (Data.Start - Data.End).Magnitude
	
	if Data.Model then
		ProjectileMaid:GiveTask(Data.Model)
	end
	
	local MiddlePoint = (Data.Start + Data.End) / 2 + Vector3.new(0, Data.Turn or 10, 0)
	ProjectileMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
		local Calculation = (workspace:GetServerTimeNow() - Data.Time) / (Distance / Data.Speed)
		Alpha += Calculation
		if Alpha >= 1 then
			Reached:Fire()
			ProjectileMaid:Destroy()
			return
		end
		if IsClient and Data.Model then
			if ProjType == "Curve" then
				local bezierCurve = quadraticBezier(Alpha, Data.Start, MiddlePoint, Data.End)
				
				Data.Model.CFrame = CFrame.new(Data.Model.Position, bezierCurve) - Data.Model.Position + bezierCurve
			else
				Data.Model.CFrame = CFrame.new(Data.Start:Lerp(Data.End, Alpha), Data.Start:Lerp(Data.End, math.min(Alpha + 0.01, 1)))
			end
		else
			if Data.OnStepFunction then
				Data.OnStepFunction(deltaTime, Alpha)
			end
		end
	end))
	
	return {
		Connection = Connection,
		Reached = Reached
	}
end

return Projectile
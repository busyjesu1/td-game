local ServerStorage = game:GetService("ServerStorage")

local EntityService = require(ServerStorage.Server.EntityService)

local Targetting = {}

function Targetting.FindTarget(Origin, Priority)
	local Stats = Origin.Stats
	local Position = Origin.CFrame.Position
	local Range = Origin:GetRange() or Stats.Range
	
	local function RunSearch(UsePriority) 
		local States = {
			BestTime = nil,
			BestHealth = nil,
			BestDistance = nil,
			BestTarget = nil,
		}
		local OriginDetections = Origin.Replicator and Origin.Replicator:get("Detections") or {}
		for RootPointer, Value in pairs(EntityService.Entities) do
			if Value.Type ~= "Enemies" then print("Not Enemy") continue end
			local EnemyCFrame = Value.CFrame
			if EnemyCFrame ~= nil then
				local Health = Value.Replicator and Value.Replicator:get("Health")
				local Progress = Value.PathDistance
				local Distance = (Vector2.new(EnemyCFrame.Position.X, EnemyCFrame.Position.Z) - Vector2.new(Position.X,Position.Z)).Magnitude

				if Health <= 0 then print("Bro is dead") continue end
				if Distance <= Range then
					if UsePriority and Priority and typeof(Priority) == "function" then
						if not Priority(Value) then print("Not in priority list") continue end
					end
					if Origin.TargetMode == "First" then
						if not States.BestTime or Progress >= States.BestTime then
							States.BestTarget = Value
							States.BestTime = Progress
						end
					elseif Origin.TargetMode == "Last" then
						if not States.BestTime or Progress <= States.BestTime then
							States.BestTarget = Value
							States.BestTime = Progress
						end
					elseif Origin.TargetMode == "Closest" then
						if not States.BestDistance or Distance <= States.BestDistance then
							States.BestTarget = Value
							States.BestDistance = Distance
						end
					end
				end
			end
		end
		
		return States.BestTarget
	end
	
	if Priority and typeof(Priority) == "function" then
		return RunSearch(true) or RunSearch(false)
	end

	return RunSearch(false)
end

return Targetting
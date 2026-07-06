local RunService = game:GetService("RunService")

return {
	onAdded = function(Entity)
		if RunService:IsClient() then
			local ExtentsSize = Entity.Model:GetExtentsSize()
			local Part = Instance.new("Part")
			Part.Anchored = true
			Part.CanCollide = false
			Part.CFrame = Entity.Model:GetPivot()
			Part.Size = ExtentsSize
			Part.BrickColor = BrickColor.new("Pastel light blue")
			Part.Material = Enum.Material.Glass;
			Part.Transparency = 0.25
			Part.Parent = workspace.CurrentCamera
			Entity.Maid:GiveTask(Part)
			Entity.FrostEffect = Part
		else
			Entity.FrostDebuff = 100
			Entity:UpdateSpeed()
		end
	end,
	
	onRemoved = function(Entity)
		if RunService:IsClient() then
			if Entity.FrostEffect then
				Entity.FrostEffect.Anchored = false
				Entity.FrostEffect = nil
			end
		else
			Entity.FrostDebuff = 0
			Entity:UpdateSpeed()
		end
	end,
}
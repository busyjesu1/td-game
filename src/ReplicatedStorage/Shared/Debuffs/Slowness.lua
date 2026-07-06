local RunService = game:GetService("RunService")

return {
	onAdded = function(Entity)
		Entity.SlownessDebuff = 25
		Entity:UpdateSpeed()
	end,
	
	onRemoved = function(Entity)
		Entity.SlownessDebuff = 0
		Entity:UpdateSpeed()
	end,
}
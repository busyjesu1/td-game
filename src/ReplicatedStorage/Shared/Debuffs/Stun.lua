local RunService = game:GetService("RunService")

return {
	onAdded = function(Entity)
		Entity.StunDebuff = 100
		Entity:UpdateSpeed()
	end,
	
	onRemoved = function(Entity)
		Entity.StunDebuff = 0
		Entity:UpdateSpeed()
	end,
}
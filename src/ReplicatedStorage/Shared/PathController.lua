local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BezierPath = require(ReplicatedStorage.Packages.BezierPath)

local PathController = {}

function PathController.Initialize(self)
	self.Paths = {}
	
	local Positions = {}
	for _, Path in workspace.Map.Paths:GetChildren() do
		Positions[tonumber(Path.Name)] = {}
		for _, Node in Path:GetChildren() do
			Positions[tonumber(Path.Name)][tonumber(Node.Name)] = Node.Position
		end
	end
	for Path, Nodes in Positions do
		self.Paths[Path] = BezierPath.new(Nodes, 3)
	end
end

return PathController
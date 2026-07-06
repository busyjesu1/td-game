local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)
repeat task.wait(2) until game:IsLoaded()
Loader:Initialize()

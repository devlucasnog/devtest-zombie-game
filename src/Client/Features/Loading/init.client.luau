local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Loader = require(ReplicatedStorage.Packages.Loader)

local player = Players.LocalPlayer

local function main()
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	local Client = player.PlayerScripts.Client

	Loader.SpawnAll(Loader.LoadDescendants(Client.Core, Loader.MatchesName("Controller$")), "OnStart")
	Loader.SpawnAll(Loader.LoadDescendants(Client.Features, Loader.MatchesName("Controller$")), "OnStart")
	Loader.LoadDescendants(Client, Loader.MatchesName("Component$"))

	pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
	end)
end

main()

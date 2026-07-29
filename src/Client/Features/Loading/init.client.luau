local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Loader = require(ReplicatedStorage.Packages.Loader)

local player = Players.LocalPlayer
local loadingGui = player.PlayerGui:WaitForChild("LoadingGui")
local content = loadingGui.Wrapper.Content
local fill = content.ProgressBar.Fill
local percentage = content.ProgressBar.Label

local function main()
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	loadingGui.Enabled = true

	local Client = player.PlayerScripts.Client

	Loader.SpawnAll(Loader.LoadDescendants(Client.Core, Loader.MatchesName("Controller$")), "OnStart")
	Loader.SpawnAll(Loader.LoadDescendants(Client.Features, Loader.MatchesName("Controller$")), "OnStart")
	Loader.LoadDescendants(Client, Loader.MatchesName("Component$"))

	for i = 1, 100 do
		fill.Size = UDim2.fromScale(i / 100, 1)
		percentage.Text = `{i}%`

		task.wait(0.02)
	end

	task.wait(1)

	local tween = TweenService:Create(
		loadingGui.Wrapper,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ GroupTransparency = 1 }
	)

	tween:Play()

	tween.Completed:Wait()
	loadingGui:Destroy()
end

main()

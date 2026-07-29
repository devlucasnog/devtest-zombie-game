local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)
local ClientUtils = require(script.Parent.Parent.Parent.Utils)

local LeaderboardCard = ReplicatedStorage.Assets.GUIs.LeaderboardCard
local NumberUtils = Utils.NumberUtils
local PopupUtils = ClientUtils.PopupUtils

local player = Players.LocalPlayer
local leaderboardGui = player.PlayerGui:WaitForChild("LeadboardGui")
local wrapper = leaderboardGui.Wrapper
local header = wrapper.Header
local closeButton = header.CloseButton
local scrollingFrame = wrapper.ScrollingFrame

local janitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.LeaderboardUpdated.On(Private.OnLeaderboardUpdated)
end

function Private.OnLeaderboardUpdated(data: { Entries: { { Thumbnail: string, DisplayName: string, Points: number } } })
	janitor:Cleanup()

	Private.Populate(data.Entries)

	PopupUtils.ShowPopup(leaderboardGui):andThen(function()
		janitor:Add(function()
			PopupUtils.HidePopup(leaderboardGui)
		end)

		janitor:Add(
			closeButton.Activated:Once(function()
				janitor:Cleanup()
			end),
			"Disconnect"
		)
	end)
end

function Private.Populate(entries: { { Thumbnail: string, DisplayName: string, Points: number } })
	for i, entry in entries do
		local card = LeaderboardCard:Clone()
		card.Name = tostring(i)
		card.LayoutOrder = i

		card.Thumbnail.Image = entry.Thumbnail
		card.DisplayName.Text = `{i}. {entry.DisplayName}`
		card.Points.Text = NumberUtils.FormatWithSuffix(entry.Points)

		card.Parent = scrollingFrame
		janitor:Add(card, "Destroy")
	end
end

return Shared

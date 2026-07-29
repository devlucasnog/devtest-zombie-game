local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Store = require(ReplicatedStorage.Shared.Store)
local Utils = require(ReplicatedStorage.Shared.Utils)

local NumberUtils = Utils.NumberUtils

local Private = {}
local Shared = {}

local player = Players.LocalPlayer
local hudGui = player.PlayerGui:WaitForChild("HUDGui")
local cashAmount = hudGui.Cash.Amount
local janitor = Janitor.new()

function Shared.OnStart()
	janitor:Add(Charm.effect(Private.UpdateCashText), true)
end

function Private.UpdateCashText()
	local total = Store.Profile().Currencies.Cash
	cashAmount.Text = NumberUtils.FormatWithSuffix(total)
end

return Shared

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Store = require(ReplicatedStorage.Shared.Store)
local Types = require(ReplicatedStorage.Shared.Types)
local Network = require(script.Parent.Parent.Parent.Network)

local player = Players.LocalPlayer
local hudGui = player.PlayerGui:WaitForChild("HUDGui")
local ammoWrapper = hudGui.Ammo
local janitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.AmmoUpdated.On(Private.OnAmmoUpdated)

	janitor:Add(Charm.effect(Private.UpdateAmmoText), true)
end

function Private.OnAmmoUpdated(payload: Types.AmmoType)
	Store.Ammo(payload)
end

function Private.UpdateAmmoText()
	local ammo = Store.Ammo()
	local reloading = ammo.Max > 0 and ammo.Current == 0

	ammoWrapper.Reloading.Visible = reloading
	ammoWrapper.Amount.Visible = not reloading
	ammoWrapper.Amount.Text = `{ammo.Current}/{ammo.Max}`
end

return Shared

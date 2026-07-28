local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SmoothShiftLock = require(ReplicatedStorage.Packages.SmoothShiftLock)

local WEAPON_TAG = "Weapon"
local SHIFT_LOCK_TOGGLE_ACTION = "ShiftLockSwitchAction"

local player = Players.LocalPlayer
local janitor = Janitor.new()

local Private = {}
local Shared = {}

function Shared.OnStart()
	ContextActionService:UnbindAction(SHIFT_LOCK_TOGGLE_ACTION)

	player.CharacterAdded:Connect(Private.OnCharacterAdded)

	if player.Character then
		Private.OnCharacterAdded(player.Character)
	end
end

function Private.OnCharacterAdded(character: Model)
	janitor:Cleanup()

	janitor:Add(character.ChildAdded:Connect(Private.OnChildAdded), "Disconnect")

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		janitor:Add(humanoid.Died:Connect(Private.OnDied), "Disconnect")
	end
end

function Private.OnChildAdded(child: Instance)
	if not (child:IsA("Model") and child:HasTag(WEAPON_TAG)) then
		return
	end

	SmoothShiftLock:ToggleShiftLock(true)
end

function Private.OnDied()
	SmoothShiftLock:ToggleShiftLock(false)
end

return Shared

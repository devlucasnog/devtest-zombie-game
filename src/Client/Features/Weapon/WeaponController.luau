local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SmoothShiftLock = require(ReplicatedStorage.Packages.SmoothShiftLock)
local Network = require(script.Parent.Parent.Parent.Network)

local WEAPON_TAG = "Weapon"
local SHIFT_LOCK_TOGGLE_ACTION = "ShiftLockSwitchAction"
local FIRE_WEAPON_ACTION = "FireWeapon"

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local janitor = Janitor.new()
local equippedWeapon: Tool? = nil

local Private = {}
local Shared = {}

function Shared.OnStart()
	ContextActionService:UnbindAction(SHIFT_LOCK_TOGGLE_ACTION)
	ContextActionService:BindAction(
		FIRE_WEAPON_ACTION,
		Private.OnFireAction,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)

	player.CharacterAdded:Connect(Private.OnCharacterAdded)

	if player.Character then
		Private.OnCharacterAdded(player.Character)
	end
end

function Private.OnCharacterAdded(character: Model)
	janitor:Cleanup()
	equippedWeapon = nil

	janitor:Add(character.ChildAdded:Connect(Private.OnChildAdded), "Disconnect")
	janitor:Add(character.ChildRemoved:Connect(Private.OnChildRemoved), "Disconnect")

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		janitor:Add(humanoid.Died:Connect(Private.OnDied), "Disconnect")
	end
end

function Private.OnChildAdded(child: Instance)
	if not (child:IsA("Tool") and child:HasTag(WEAPON_TAG)) then
		return
	end

	equippedWeapon = child
	SmoothShiftLock:ToggleShiftLock(true)
end

function Private.OnChildRemoved(child: Instance)
	if child == equippedWeapon then
		equippedWeapon = nil
	end
end

function Private.OnDied()
	SmoothShiftLock:ToggleShiftLock(false)
end

function Private.OnFireAction(_actionName: string, inputState: Enum.UserInputState)
	if inputState ~= Enum.UserInputState.Begin or not equippedWeapon then
		return Enum.ContextActionResult.Pass
	end

	Network.FireWeapon.Fire({ Direction = camera.CFrame.LookVector })

	return Enum.ContextActionResult.Sink
end

return Shared

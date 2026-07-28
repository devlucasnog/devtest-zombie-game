local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SmoothShiftLock = require(ReplicatedStorage.Packages.SmoothShiftLock)
local Config = require(ReplicatedStorage.Shared.Config)
local Store = require(ReplicatedStorage.Shared.Store)
local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)

local WeaponConfig = Config.WeaponConfig
local WeaponUtils = Utils.WeaponUtils
local VFXUtils = Utils.VFXUtils

local WEAPON_TAG = "Weapon"
local SHIFT_LOCK_TOGGLE_ACTION = "ShiftLockSwitchAction"
local FIRE_WEAPON_ACTION = "FireWeapon"

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local janitor = Janitor.new()
local equippedWeapon: Tool? = nil
local lastFireTime = 0

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

	local ammo = Charm.peek(Store.Ammo)
	if ammo.Current <= 0 then
		return Enum.ContextActionResult.Pass
	end

	local weaponConfig = WeaponConfig[equippedWeapon.Name]
	if os.clock() - lastFireTime < weaponConfig.FireRate then
		return Enum.ContextActionResult.Pass
	end

	lastFireTime = os.clock()

	local direction = camera.CFrame.LookVector
	Network.FireWeapon.Fire({ Direction = direction })

	local muzzle = WeaponUtils.GetMuzzle(equippedWeapon)
	VFXUtils.PlayMuzzleFlash(muzzle)

	if muzzle then
		local origin = muzzle.WorldPosition
		VFXUtils.PlayTracer(origin, Private.PredictEndPoint(origin, direction, weaponConfig.Range))
	end

	return Enum.ContextActionResult.Sink
end

function Private.PredictEndPoint(origin: Vector3, direction: Vector3, range: number): Vector3
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { player.Character }

	local result = Workspace:Raycast(origin, direction * range, raycastParams)
	return result and result.Position or origin + direction * range
end

return Shared

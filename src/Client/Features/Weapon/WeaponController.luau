local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SmoothShiftLock = require(ReplicatedStorage.Packages.SmoothShiftLock)
local Config = require(ReplicatedStorage.Shared.Config)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Store = require(ReplicatedStorage.Shared.Store)
local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)
local WeaponAnimation = require(script.Parent.WeaponAnimation)
local WeaponFeedback = require(script.Parent.WeaponFeedback)

local WEAPON_TAG = "Weapon"
local SHIFT_LOCK_TOGGLE_ACTION = "ShiftLockSwitchAction"
local FIRE_WEAPON_ACTION = "FireWeapon"

local WeaponConfig = Config.WeaponConfig
local MatchState = Enums.MatchState
local WeaponUtils = Utils.WeaponUtils
local SFXUtils = Utils.SFXUtils

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local hudGui = player.PlayerGui:WaitForChild("HUDGui")
local mobileAim = hudGui.MobileAim
local janitor = Janitor.new()
local matchJanitor = Janitor.new()
local equippedWeapon: Tool? = nil
local lastFireTime = 0

local Private = {}
local Shared = {}

function Shared.OnStart()
	ContextActionService:UnbindAction(SHIFT_LOCK_TOGGLE_ACTION)
	ContextActionService:BindAction(
		FIRE_WEAPON_ACTION,
		Private.OnFireAction,
		true,
		Enum.UserInputType.MouseButton1
	)

	player.CharacterAdded:Connect(Private.OnCharacterAdded)

	if player.Character then
		Private.OnCharacterAdded(player.Character)
	end

	matchJanitor:Add(Charm.effect(Private.UpdateShiftLock), true)
	matchJanitor:Add(Charm.subscribe(Store.Ammo, Private.OnAmmoChanged), true)
end

function Private.OnCharacterAdded(character: Model)
	janitor:Cleanup()
	Private.SetEquippedWeapon(WeaponUtils.GetWeaponFromCharacter(character))

	janitor:Add(character.ChildAdded:Connect(Private.OnChildAdded), "Disconnect")
	janitor:Add(character.ChildRemoved:Connect(Private.OnChildRemoved), "Disconnect")

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		janitor:Add(humanoid.Died:Connect(Private.OnDied), "Disconnect")
	end

	WeaponAnimation.SetCharacter(character)
end

function Private.OnChildAdded(child: Instance)
	if not (child:IsA("Tool") and child:HasTag(WEAPON_TAG)) then
		return
	end

	Private.SetEquippedWeapon(child)
end

function Private.OnChildRemoved(child: Instance)
	if child == equippedWeapon then
		Private.SetEquippedWeapon(nil)
	end
end

function Private.OnDied()
	Private.SetEquippedWeapon(nil)
end

function Private.OnAmmoChanged(ammo: { Current: number, Max: number }, previousAmmo: { Current: number, Max: number })
	if ammo.Current == 0 and previousAmmo.Current > 0 then
		WeaponAnimation.Play("Reload")
	end
end

function Private.OnFireAction(_actionName: string, inputState: Enum.UserInputState)
	if inputState ~= Enum.UserInputState.Begin or not equippedWeapon then
		return Enum.ContextActionResult.Pass
	end

	local ammo = Charm.peek(Store.Ammo)
	if ammo.Current <= 0 then
		SFXUtils.Play("DryFire")
		return Enum.ContextActionResult.Pass
	end

	local weaponConfig = WeaponConfig[equippedWeapon.Name]
	if os.clock() - lastFireTime < weaponConfig.FireRate then
		return Enum.ContextActionResult.Pass
	end

	lastFireTime = os.clock()

	local direction = camera.CFrame.LookVector
	Network.FireWeapon.Fire({ Direction = direction })
	WeaponAnimation.Play("Recoil")

	local muzzle = WeaponUtils.GetMuzzle(equippedWeapon)
	WeaponFeedback.PlayFired(muzzle, direction, weaponConfig.Range)

	return Enum.ContextActionResult.Sink
end

function Private.SetEquippedWeapon(weapon: Tool?)
	equippedWeapon = weapon
	Store.Weapon(weapon ~= nil)
	Private.UpdateShiftLock()
end

function Private.UpdateShiftLock()
	local match = Store.Match()
	local shouldLock = equippedWeapon ~= nil and match.State == MatchState.RoundActive
	SmoothShiftLock:ToggleShiftLock(shouldLock)
	mobileAim.Visible = shouldLock and UserInputService.TouchEnabled
end

return Shared

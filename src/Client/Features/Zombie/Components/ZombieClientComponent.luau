local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Types = require(ReplicatedStorage.Shared.Types)
local Utils = require(ReplicatedStorage.Shared.Utils)

local SFXUtils = Utils.SFXUtils

local TAG = "Zombie"
local TWEEN_IN = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local DAMAGE_DURATION = 0.5

type ZombieClientComponentType = Types.ZombieClientComponentType
type DamageLabel = Frame & { UIScale: UIScale, Amount: TextLabel }

local ZombieGui = ReplicatedStorage.Assets.GUIs.ZombieGui

local ZombieClientComponent = Component.new({ Tag = TAG, Ancestors = { workspace } }) :: ZombieClientComponentType

function ZombieClientComponent:Construct()
	self._janitor = Janitor.new()
end

function ZombieClientComponent:Start()
	self._gui = self._janitor:Add(ZombieGui:Clone(), "Destroy")
	self._gui.Adornee = self.Instance.Head
	self._gui.Parent = self.Instance.Head

	self:_PlayGrowl()

	self._janitor:Add(
		self.Instance.Humanoid.Died:Connect(function()
			self:_OnDied()
		end),
		"Disconnect"
	)
end

function ZombieClientComponent:_PlayGrowl()
	local growl = SFXUtils.CreateSound("Growl", self.Instance.HumanoidRootPart)
	if not growl then
		return
	end

	growl.Looped = true
	self._janitor:Add(growl, "Destroy", "Growl"):Play()
end

function ZombieClientComponent:_OnDied()
	self._janitor:Remove("Growl")
	SFXUtils.PlayAtPosition("Die", self.Instance.HumanoidRootPart.CFrame)
end

function ZombieClientComponent:TakeDamage(damage: number)
	local clone = self:_CreateDamageLabel(damage)
	self:_PlayDamageIn(clone)
end

function ZombieClientComponent:Stop()
	self._janitor:Destroy()
end

function ZombieClientComponent:_CreateDamageLabel(damage: number): DamageLabel
	local clone = self._janitor:Add(self._gui.TemplateDamage:Clone(), "Destroy")
	clone.UIScale.Scale = 0.1
	clone.Amount.Text = tostring(damage)
	clone.Visible = true
	clone.Parent = self._gui

	return clone
end

function ZombieClientComponent:_PlayDamageIn(clone: DamageLabel)
	local xScale = math.random(0, 4) * 0.25
	local yScale = math.random(0, 4) * 0.1
	local targetPosition = UDim2.fromScale(xScale, yScale)

	local tweenIn = self._janitor:Add(TweenService:Create(clone, TWEEN_IN, { Position = targetPosition }), "Cancel")
	self._janitor:Add(TweenService:Create(clone.UIScale, TWEEN_IN, { Scale = 1 }), "Cancel"):Play()
	tweenIn:Play()

	tweenIn.Completed:Once(function()
		if clone.Parent then
			self:_PlayDamageOut(clone)
		end
	end)
end

function ZombieClientComponent:_PlayDamageOut(clone: DamageLabel)
	task.wait(DAMAGE_DURATION)

	if not clone.Parent then
		return
	end

	local tweenOut = self._janitor:Add(TweenService:Create(clone.UIScale, TWEEN_OUT, { Scale = 0.1 }), "Cancel")
	tweenOut:Play()

	tweenOut.Completed:Once(function()
		if clone.Parent then
			clone:Destroy()
		end
	end)
end

return ZombieClientComponent

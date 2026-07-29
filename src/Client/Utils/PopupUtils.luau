local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Utils = require(ReplicatedStorage.Shared.Utils)
local BackdropUtils = require(script.Parent.BackdropUtils)

local TAG_HIDE = "HideOnPopup"
local SHOW_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local HIDE_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local EFFECT_IN = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EFFECT_OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local DEFAULT_FOV = 70
local POPUP_FOV = 50
local BLUR_SIZE = 24
local SATURATION = 0

-- local SFXUtils = Utils.SFXUtils

local guis: { [ScreenGui]: boolean } = {}
local camera = workspace.CurrentCamera
local currentPopup: ScreenGui? = nil

local activeTweens: { Tween } = {}

local blurEffect: BlurEffect
local colorCorrection: ColorCorrectionEffect

do
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "Popup_BlurEffect"
	blurEffect.Size = 0
	blurEffect.Enabled = false
	blurEffect:AddTag("PopupEffect")
	blurEffect.Parent = game.Lighting

	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "Popup_ColorCorrectionEffect"
	colorCorrection.Saturation = 0
	colorCorrection.Enabled = false
	colorCorrection:AddTag("PopupEffect")
	colorCorrection.Parent = game.Lighting
end

local Private = {}
local Shared = {}

function Shared.ShowPopup(gui: ScreenGui)
	local wrapper = gui:FindFirstChild("Wrapper")
	if not (wrapper and (wrapper:IsA("Frame") or wrapper:IsA("ImageLabel"))) then
		return
	end

	if currentPopup and currentPopup ~= gui then
		return Promise.resolve()
	end

	Private.DisableTopBar()
	Private.DisableHud()
	Shared.HideAllGuis()
	BackdropUtils.Show()

	gui.Enabled = true
	wrapper.Position = UDim2.fromScale(0.5, 1.5)
	currentPopup = gui

	blurEffect.Enabled = true
	blurEffect.Size = 0
	colorCorrection.Enabled = true
	colorCorrection.Saturation = 0

	Private.PlayEffects(EFFECT_IN, { BlurSize = BLUR_SIZE, Saturation = SATURATION, FieldOfView = POPUP_FOV })

	-- SFXUtils.Play("PopupOpen")

	return Promise.new(function(resolve)
		local tween = TweenService:Create(wrapper, SHOW_INFO, {
			Position = UDim2.fromScale(0.5, 0.5),
		})

		tween.Completed:Connect(resolve)
		tween:Play()
	end)
end

function Shared.HidePopup(gui: ScreenGui)
	if gui ~= currentPopup then
		return
	end

	local wrapper = gui:FindFirstChild("Wrapper")
	if not (wrapper and (wrapper:IsA("Frame") or wrapper:IsA("ImageLabel"))) then
		return
	end

	Private.EnableTopBar()
	Private.EnableHud()
	Private.PlayEffects(EFFECT_OUT, { BlurSize = 0, Saturation = 0, FieldOfView = DEFAULT_FOV })

	-- SFXUtils.Play("PopupClose")

	return Promise.new(function(resolve)
		local tween = TweenService:Create(wrapper, HIDE_INFO, {
			Position = UDim2.fromScale(0.5, 1.5),
		})

		tween.Completed:Connect(function()
			blurEffect.Enabled = false
			colorCorrection.Enabled = false
			gui.Enabled = false
			currentPopup = nil
			Shared.ShowAllGuis()
			BackdropUtils.Hide()
			resolve()
		end)

		tween:Play()
	end)
end

function Shared.HideAllGuis()
	for _, gui in CollectionService:GetTagged(TAG_HIDE) do
		if not gui:IsA("ScreenGui") then
			continue
		end

		if gui.Enabled then
			gui.Enabled = false
			guis[gui] = true
		end
	end
end

function Shared.ShowAllGuis()
	for gui in guis do
		gui.Enabled = true
	end

	guis = {}
end

function Private.CancelActiveTweens()
	for _, tween in activeTweens do
		tween:Cancel()
	end
	table.clear(activeTweens)
end

function Private.PlayEffects(tweenInfo: TweenInfo, props: { [string]: any })
	Private.CancelActiveTweens()

	local tweens = {
		TweenService:Create(blurEffect, tweenInfo, { Size = props.BlurSize }),
		TweenService:Create(colorCorrection, tweenInfo, { Saturation = props.Saturation }),
		TweenService:Create(camera, tweenInfo, { FieldOfView = props.FieldOfView }),
	}

	for _, tween in tweens do
		table.insert(activeTweens, tween)
		tween:Play()
	end
end

return Shared

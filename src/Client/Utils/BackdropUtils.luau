local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local backdropGui = player.PlayerGui.BackdropGui
local background = backdropGui.Background

local Shared = {}

function Shared.Show()
	background.BackgroundTransparency = 1
	background.Visible = true

	TweenService:Create(background, TWEEN_INFO, { BackgroundTransparency = 0.6 }):Play()
end

function Shared.Hide(onComplete: (() -> ())?)
	local tween = TweenService:Create(background, TWEEN_INFO, { BackgroundTransparency = 1 })
	tween:Play()

	tween.Completed:Once(function()
		background.Visible = false

		if onComplete then
			onComplete()
		end
	end)
end

return Shared

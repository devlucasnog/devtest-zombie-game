local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Store = require(ReplicatedStorage.Shared.Store)
local Utils = require(ReplicatedStorage.Shared.Utils)
local Network = require(script.Parent.Parent.Parent.Network)

local MatchState = Enums.MatchState
local NumberUtils = Utils.NumberUtils

local PULSE_THRESHOLD = 10
local PULSE_COLOR = Color3.fromRGB(255, 0, 0)
local PULSE_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

local player = Players.LocalPlayer
local matchGui = player.PlayerGui:WaitForChild("MatchGui")

local wrapper = matchGui.Wrapper
local state = wrapper.State
local timer = wrapper.Timer

local defaultTimerColor = timer.TextColor3
local isPulsing = false
local janitor = Janitor.new()
local pulseTween = janitor:Add(TweenService:Create(timer, PULSE_TWEEN_INFO, { TextColor3 = PULSE_COLOR }), "Cancel")

local Private = {}
local Shared = {}

function Shared.OnStart()
	Network.MatchUpdated.On(Private.OnMatchUpdated)

	janitor:Add(Charm.effect(Private.UpdateStateText), true)
	janitor:Add(RunService.Heartbeat:Connect(Private.UpdateTimerText), "Disconnect")
end

function Private.OnMatchUpdated(payload: { State: string, Round: number, Duration: number })
	Store.Match({
		State = payload.State,
		Round = payload.Round,
		EndsAt = os.clock() + payload.Duration,
	})
end

function Private.UpdateStateText()
	local match = Store.Match()

	if match.State == MatchState.RoundActive then
		state.Text = `Round {match.Round}`
	elseif match.State == MatchState.Intermission then
		state.Text = `Round {match.Round + 1} starting soon`
	elseif match.State == MatchState.GameEnded then
		state.Text = "Game over"
	else
		state.Text = "Waiting for players"
	end
end

function Private.UpdateTimerText()
	local match = Charm.peek(Store.Match)
	local remaining = math.max(match.EndsAt - os.clock(), 0)

	timer.Text = remaining > 0 and NumberUtils.FormatTime(remaining) or ""

	local shouldPulse = match.State == MatchState.RoundActive and remaining > 0 and remaining < PULSE_THRESHOLD
	if shouldPulse and not isPulsing then
		isPulsing = true
		pulseTween:Play()
	elseif not shouldPulse and isPulsing then
		isPulsing = false
		pulseTween:Cancel()
		timer.TextColor3 = defaultTimerColor
	end
end

return Shared

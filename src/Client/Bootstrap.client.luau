local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local PlayerGui = Players.LocalPlayer.PlayerGui

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

return {
	RoundStarted = Signal.new(),
	RoundCleared = Signal.new(),
	GameEnded = Signal.new(),
	GameReset = Signal.new(),
}

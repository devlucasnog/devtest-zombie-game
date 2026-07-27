local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

return {
	Loaded = Signal.new(),
	Updated = Signal.new(),
}

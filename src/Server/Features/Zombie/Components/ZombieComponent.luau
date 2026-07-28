local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)

local TAG = "Zombie"

type ZombieComponentType = Types.ZombieComponentType

local ZombieConfig = Config.ZombieConfig

local ZombieComponent = Component.new({ Tag = TAG, Ancestors = { workspace } }) :: ZombieComponentType

function ZombieComponent:Construct()
	self._janitor = Janitor.new()
	self._config = ZombieConfig[self.Instance.Name]
end

function ZombieComponent:Start()
end

function ZombieComponent:Stop()
	self._janitor:Destroy()
end

return ZombieComponent

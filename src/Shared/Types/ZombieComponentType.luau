local JanitorType = require(script.Parent.JanitorType)
local ZombieConfigType = require(script.Parent.ZombieConfigType)

export type ZombieComponentType = {
	Instance: Model & {
		Humanoid: Humanoid & {
            Animator: Animator
        }
	},

	_janitor: JanitorType.JanitorType,
	_config: ZombieConfigType.ZombieConfigType,

	Construct: (self: ZombieComponentType) -> (),
	Start: (self: ZombieComponentType) -> (),
	Stop: (self: ZombieComponentType) -> (),
}

return {}

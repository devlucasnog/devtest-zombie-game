local JanitorType = require(script.Parent.JanitorType)
local ZombieConfigType = require(script.Parent.ZombieConfigType)

export type ZombieComponentType = {
	Instance: Model & {
		Humanoid: Humanoid & {
			Animator: Animator,
		},
		HumanoidRootPart: BasePart,
	},

	_janitor: JanitorType.JanitorType,
	_config: ZombieConfigType.ZombieConfigType,
	_state: string,
	_humanoid: Humanoid,
	_rootPart: BasePart,
	_lastAttackTime: number,
	_targetElapsed: number,

	Construct: (self: ZombieComponentType) -> (),
	Start: (self: ZombieComponentType) -> (),
	Stop: (self: ZombieComponentType) -> (),
	HeartbeatUpdate: (self: ZombieComponentType, dt: number) -> (),

	_FindNearestTarget: (
		self: ZombieComponentType,
		position: Vector3
	) -> {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}?,

	_SetState: (self: ZombieComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),

	_TryAttack: (self: ZombieComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),

	_FaceTarget: (self: ZombieComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),
}

return {}

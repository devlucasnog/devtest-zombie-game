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
	_animator: Animator,
	_rootPart: BasePart,
	_isAttacking: boolean,
	_idleUntil: number,
	_targetElapsed: number,
	_lastAttacker: Player?,
	_animationTracks: { Idle: AnimationTrack, Walk: AnimationTrack, Attack: AnimationTrack },

	Construct: (self: ZombieComponentType) -> (),
	Start: (self: ZombieComponentType) -> (),
	Stop: (self: ZombieComponentType) -> (),
	HeartbeatUpdate: (self: ZombieComponentType, dt: number) -> (),
	TakeDamage: (self: ZombieComponentType, damage: number, attacker: Player, hitPart: BasePart) -> (),

	_OnDied: (self: ZombieComponentType) -> (),

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

	_PlayAnimation: (self: ZombieComponentType, name: string) -> (),
}

return {}

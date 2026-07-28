local JanitorType = require(script.Parent.JanitorType)
local ZombieConfigType = require(script.Parent.ZombieConfigType)

export type ZombieServerComponentType = {
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

	Construct: (self: ZombieServerComponentType) -> (),
	Start: (self: ZombieServerComponentType) -> (),
	Stop: (self: ZombieServerComponentType) -> (),
	HeartbeatUpdate: (self: ZombieServerComponentType, dt: number) -> (),
	TakeDamage: (self: ZombieServerComponentType, damage: number, attacker: Player, hitPart: BasePart) -> (),

	_OnDied: (self: ZombieServerComponentType) -> (),

	_FindNearestTarget: (
		self: ZombieServerComponentType,
		position: Vector3
	) -> {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}?,

	_SetState: (self: ZombieServerComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),

	_TryAttack: (self: ZombieServerComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),

	_FaceTarget: (self: ZombieServerComponentType, target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}) -> (),

	_PlayAnimation: (self: ZombieServerComponentType, name: string) -> (),
}

return {}

local JanitorType = require(script.Parent.JanitorType)

export type ZombieClientComponentType = {
	Instance: Model & {
		Humanoid: Humanoid,
		Head: BasePart,
	},

	_janitor: JanitorType.JanitorType,
	_gui: BillboardGui & {
		TemplateDamage: Frame & {
			UIScale: UIScale,
			Amount: TextLabel,
		},
	},

	Construct: (self: ZombieClientComponentType) -> (),
	Start: (self: ZombieClientComponentType) -> (),
	Stop: (self: ZombieClientComponentType) -> (),
	TakeDamage: (self: ZombieClientComponentType, damage: number) -> (),

	_CreateDamageLabel: (
		self: ZombieClientComponentType,
		damage: number
	) -> Frame & { UIScale: UIScale, Amount: TextLabel },

	_PlayDamageIn: (self: ZombieClientComponentType, clone: Frame & { UIScale: UIScale, Amount: TextLabel }) -> (),

	_PlayDamageOut: (self: ZombieClientComponentType, clone: Frame & { UIScale: UIScale, Amount: TextLabel }) -> (),
}

return {}

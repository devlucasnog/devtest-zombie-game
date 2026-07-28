local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Config = require(ReplicatedStorage.Shared.Config)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Types = require(ReplicatedStorage.Shared.Types)

local TAG = "Zombie"
local TARGET_REFRESH_INTERVAL = 0.25

type ZombieComponentType = Types.ZombieComponentType
type Target = { RootPart: BasePart, Humanoid: Humanoid }

local ZombieConfig = Config.ZombieConfig
local ZombieState = Enums.ZombieState
local Animations = ReplicatedStorage.Assets.Animations.Zombie

local STATE_ANIMATIONS = {
	[ZombieState.Idle] = "Idle",
	[ZombieState.Chasing] = "Walk",
	[ZombieState.Attacking] = "Attack",
}

local ZombieComponent = Component.new({ Tag = TAG, Ancestors = { workspace } }) :: ZombieComponentType

function ZombieComponent:Construct()
	self._janitor = Janitor.new()
	self._config = ZombieConfig[self.Instance.Name]
	self._state = ZombieState.Idle
	self._isAttacking = false
	self._idleUntil = 0
	self._targetElapsed = 0
end

function ZombieComponent:Start()
	self._humanoid = self.Instance.Humanoid
	self._animator = self.Instance.Humanoid.Animator
	self._rootPart = self.Instance.HumanoidRootPart

	self._humanoid.MaxHealth = self._config.Health
	self._humanoid.Health = self._config.Health
	self._humanoid.WalkSpeed = self._config.WalkSpeed

	self._animationTracks = {
		Idle = self._janitor:Add(self._animator:LoadAnimation(Animations.Idle), "Destroy"),
		Walk = self._janitor:Add(self._animator:LoadAnimation(Animations.Walk), "Destroy"),
		Attack = self._janitor:Add(self._animator:LoadAnimation(Animations.Attack), "Destroy"),
	}
end

function ZombieComponent:HeartbeatUpdate(dt: number)
	if self._humanoid.Health <= 0 then
		return
	end

	self._targetElapsed += dt
	if self._targetElapsed < TARGET_REFRESH_INTERVAL then
		return
	end
	self._targetElapsed = 0

	if os.clock() < self._idleUntil then
		self:_SetState(ZombieState.Idle)
		return
	end

	local target = self:_FindNearestTarget(self._rootPart.Position)
	if not target then
		self:_SetState(ZombieState.Idle)
		return
	end

	local distance = (target.RootPart.Position - self._rootPart.Position).Magnitude
	if distance <= self._config.AttackRange then
		self:_SetState(ZombieState.Attacking, target)
	else
		self:_SetState(ZombieState.Chasing, target)
	end
end

function ZombieComponent:Stop()
	self._janitor:Destroy()
end

function ZombieComponent:_FindNearestTarget(position: Vector3): Target?
	local nearest: Target? = nil
	local nearestDistance = math.huge

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?

		if humanoid and humanoid.Health > 0 and rootPart then
			local distance = (rootPart.Position - position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearest = { RootPart = rootPart, Humanoid = humanoid }
			end
		end
	end

	return nearest
end

function ZombieComponent:_SetState(
	state: string,
	target: {
		RootPart: BasePart,
		Humanoid: Humanoid,
	}
)
	if state ~= self._state then
		self:_PlayAnimation(STATE_ANIMATIONS[state])
	end

	self._state = state

	if state == ZombieState.Idle then
		self._humanoid:MoveTo(self._rootPart.Position)
	elseif state == ZombieState.Chasing then
		self._humanoid:MoveTo((target).RootPart.Position)
	elseif state == ZombieState.Attacking then
		self._humanoid:MoveTo(self._rootPart.Position)
		self:_FaceTarget(target)
		self:_TryAttack(target)
	end
end

function ZombieComponent:_PlayAnimation(name: string)
	for trackName, track in self._animationTracks do
		if trackName == name then
			if not track.IsPlaying then
				track:Play()
			end
		elseif track.IsPlaying then
			track:Stop()
		end
	end
end

function ZombieComponent:_FaceTarget(target: Target)
	local rootPosition = self._rootPart.Position
	local lookAt = Vector3.new(target.RootPart.Position.X, rootPosition.Y, target.RootPart.Position.Z)

	if (lookAt - rootPosition).Magnitude > 0 then
		self._rootPart.CFrame = CFrame.lookAt(rootPosition, lookAt)
	end
end

function ZombieComponent:_TryAttack(target: Target)
	if self._isAttacking then
		return
	end

	self._isAttacking = true

	local track = self._animationTracks.Attack

	track:GetMarkerReachedSignal("Hit"):Once(function()
		if target.Humanoid.Health > 0 then
			target.Humanoid:TakeDamage(self._config.Damage)
		end
	end)

	track.Stopped:Once(function()
		self._isAttacking = false
		self._idleUntil = os.clock() + self._config.AttackCooldown
		self:_SetState(ZombieState.Idle)
	end)
end

return ZombieComponent

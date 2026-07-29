## Overview

### Approach

This project is built on top of a template I created myself for Roblox projects
([roblox-game-template](https://github.com/devlucasnog/roblox-game-template)), using Rojo + Wally,
already structured into Server/Client/Shared and, on the server, into `Core` (infrastructure any
feature can depend on, like the player profile system) and `Features` (weapon, zombies, match).
Starting from that template instead of standalone scripts gave me a base already validated on other
projects, so I could spend the assignment's time on gameplay logic instead of deciding organization
from scratch.

The server is authoritative for everything that matters: damage, ammo, match state, currency. The
client only sends intent (e.g. "I fired in this direction") and renders feedback (tracer, muzzle
flash, damage numbers); it never decides the outcome. Since the brief explicitly asks for weapon
actions to be validated server-side, I treated that as a rule for the whole project, not an isolated
check.

Shared state (match timer, ammo, profile currencies) lives in reactive atoms (Charm), fed by the
server through Replica (profile data) and a typed network layer (Blink) for match/combat events.
Every screen (HUD, timer, leaderboard) reads from that state instead of listening to network events
directly, so adding a new UI element never means wiring a remote by hand.

For the zombies, I used the `Component` package (CollectionService) instead of a single service
managing every zombie inside one giant table indexed by instance. Each zombie becomes its own
component instance, with its own state, lifecycle (`Construct`/`Start`/`Stop`) and cleanup through
Janitor. This avoids a monolithic service piling up logic for every zombie at once and keeps each
zombie isolated enough to debug and extend without affecting the others.

I also kept a clear separation between `Utils` (pure, reusable functions, like weapon raycasting,
number/time formatting, VFX/SFX) and `Config` (balancing values like damage, ammo, HP, round
duration). This keeps behavior logic away from the numbers it uses, so tuning the game's balance
never touches code, only config, and the same utility function can serve multiple places without
duplicating logic.

### Ideas I scrapped

- **Zombie damage through physical `Touched` events.** I considered this first, since it is the
  literal reading of "damage on contact," but scrapped it for a range check tied to an animation
  marker, which gives precise control over exactly when damage lands (synced to the attack animation)
  and avoids the classic multi-touch/double-hit bugs `Touched` produces.
- **Ending the round the moment any player dies.** The brief is worded around a single player, but
  since the game is meant to work like CoD Zombies (multiplayer), I scrapped the literal "one death
  equals game over" rule in favor of ending only when every player is down, closer to how the
  reference game actually plays.
- **Inline raycast/hit-resolution/damage logic inside `WeaponService`.** That is where it lived
  originally, but I pulled it out into pure functions in `WeaponUtils`. The service is now just
  orchestration (validate, consume shot, resolve hit, apply damage), and the actual math is testable
  and reusable on its own.
- **Splitting kill credit between everyone who damaged a zombie.** Scrapped for MVP scope, credit
  goes to whoever lands the killing blow. Simpler, and good enough for a first pass; I would revisit
  it if this went past the assignment.
- **Building UI in code.** I stuck to Studio-built UI with manual Charm bindings instead of a
  declarative UI library, to stay consistent with the project's existing convention rather than
  introducing a second UI paradigm for one feature.

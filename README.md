# [TEST] - Zombie Game

A reusable starting point for Roblox game projects: Rojo + Wally + the architecture documented in
[CLAUDE.md](CLAUDE.md) (Loader-driven Services/Controllers, Charm/Vide state and UI, Replica/ProfileStore
player data).

## Getting Started

Install the pinned toolchain and packages, then build the place from scratch:

```bash
rokit install
wally install
rojo build -o "roblox-game-template.rbxlx"
```

Next, open the built `.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

See [CLAUDE.md](CLAUDE.md) for the project's folder structure and conventions.

For more on Rojo itself, check out [the Rojo documentation](https://rojo.space/docs).

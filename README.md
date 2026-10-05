# Vaporwave Vikings, Idle

Vaporwave Vikings, Idle is a mobile auto-running side-scroller with idle RPG progression. The player runs through side-scrolling stages, collects coins, defeats enemies, earns gold and other resources, then spends those rewards on power, abilities, gear, and idle-style multipliers.

The project is planned as:

- `docs/` - design and technical documentation.
- `vaporwave-vikings-idle/` - Godot game client.
- `backend-service/` - Node.js REST backend service.

The backend will authorize player progression, validate reported run results, and maintain server-side player state. The client will play smoothly and responsively, but progression writes should be checked by the service before becoming authoritative.

Start with [docs/README.md](docs/README.md).

Backend setup lives in [backend-service/README.md](backend-service/README.md).

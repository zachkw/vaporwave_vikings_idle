# Vaporwave Vikings, Idle

Vaporwave Vikings, Idle is a mobile auto-running side-scroller with idle RPG progression. The player runs through side-scrolling stages, collects coins, defeats enemies, earns gold and other resources, then spends those rewards on power, abilities, gear, and idle-style multipliers.

The project is planned as:

- `docs/` - design and technical documentation.
- `vaporwave-vikings-idle/` - Godot game client.
- `backend-service/` - Node.js REST backend service.

The game plays from its own device save, online or offline. The backend keeps a validated copy: the client syncs the difference since the last sync, and the server checks the gold in it was possible in the time played.

Start with [docs/README.md](docs/README.md). The `docs/` folder is the single source of truth; decisions are logged in [docs/decisions.md](docs/decisions.md).

Backend setup lives in [backend-service/README.md](backend-service/README.md).

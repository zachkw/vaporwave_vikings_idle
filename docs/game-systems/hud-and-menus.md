# HUD and menus

Purpose: what the player sees during a run and in the menus. Phone portrait or landscape is not decided; the layout below works for landscape (proposed).

## HUD

| Element | Where | Shows |
| --- | --- | --- |
| Gold | Top centre | `wallet.gold` in short notation, ticking up |
| Gold per second | Under gold | Recent earning rate (rolling 10 s average) |
| Health | Top left, over the Viking's head or as a bar | Current and max health |
| Active effects | Top right | One icon per active dimension or pickup, with remaining time |
| Level and biome | Top left | "Dark Forest 2-3", World+ level when above 1 |
| Badges | Top left, small | Biomes beaten this world |
| Sprint button | Bottom right | Visible once owned; shows cooldown |
| Shop button | Bottom left | Opens the shop; shows a dot when something new is affordable |
| Next unlock hint | Above shop button | "Gloves at 10K" when close |

## Menus

| Menu | Contents | First build |
| --- | --- | --- |
| Shop | Gear rows (see [Gear shop](gear-shop.md)) | Yes |
| Unlocks | Ingredients, pickups and artefacts found, and course completions | Yes, simple list |
| Artefacts | Owned artefacts, levels, upgrades; equip wand and ranged weapon | Later |
| Ascension | Pending points, level, talent web | Later |
| Village | Buildings, garden, workshops | Later |
| Settings | Sound, auto-consume rules | Sound only |

## Screens

- **Course fail:** "Watch an ad to retry" or "Back to the surface".
- **Welcome back:** away gold earned, with "Double it" (ad) and "Collect".
- **Daily reward:** streak and today's reward (later).

## Rules

- UI reads only through selectors and dispatches actions; it never computes rewards.
- The run never pauses for the shop (proposed); course and boss moments may.
- Taps on HUD buttons never cause a jump.

## Open

Orientation; whether the shop pauses the run; exact layout once the art style exists (see [Art](../art/README.md)).

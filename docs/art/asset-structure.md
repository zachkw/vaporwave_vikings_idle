# Asset structure

One rule: **editable sources live outside the Godot project; only exported, game-ready files live inside it.** Godot scans everything under `vaporwave-vikings-idle/`, so keeping Piskel files, generator scripts and previews out of it keeps the editor's file list clean and the export small.

```
Vaporwave Vikings Idle/
├── art-source/                   # sources — never loaded by the game
│   ├── viking/                   # .piskel files + make_viking_anims.py (and _debug/, gitignored)
│   ├── enemies/<enemy>/          # one folder per enemy as they are made
│   ├── previews/                 # animated GIFs for review in chat / docs
│   └── reference/                # mockups, mood boards, palette swatches
│       └── ui/
└── vaporwave-vikings-idle/       # Godot project — res://
    └── assets/
        ├── sprites/
        │   ├── viking/           # viking_<action>.png sheets + viking_frames.tres
        │   ├── enemies/<enemy>/
        │   ├── bosses/<boss>/
        │   └── pickups/          # coin, ingredient box
        ├── backgrounds/<biome>/  # parallax layers, set pieces
        ├── tiles/<biome>/        # ground and platform tiles
        ├── fx/                   # weapon effects, hit flashes, coin sparkle
        ├── ui/
        │   ├── hud/
        │   ├── icons/gear/
        │   ├── icons/ingredients/
        │   └── fonts/
        └── audio/
            ├── music/
            └── sfx/
```

## Naming

- Lowercase `snake_case`, no spaces: `viking_run.png`, `imp_fly.png`, `df_cave_bg_far.png`.
- Sprite sheets: `<entity>_<action>.png`. One animation per sheet, frames in a single row, left to right.
- The Viking is 64×64 per frame. Enemies and bosses pick a frame size per entity and keep it across all their sheets.
- Biome prefixes match the content files: `df_` dark forest, and so on as biomes are added.
- Source and export share a name: `art-source/viking/viking_run.piskel` exports to `assets/sprites/viking/viking_run.png`.

## Godot conventions

- Project texture filter is set to **Nearest** (`rendering/textures/canvas_textures/default_texture_filter = 0`), so pixel art stays crisp without per-node settings.
- Each animated character gets one `SpriteFrames` resource next to its sheets (`viking_frames.tres`) that slices the sheets and names the animations. Scenes use an `AnimatedSprite2D` pointing at that resource, so a frame count change is fixed in one place.
- `.import` files are committed alongside their PNGs; `.godot/` is not.

## Current Viking animations

| Animation | Sheet | Frames | FPS | Loop | Source |
| --- | --- | --- | --- | --- | --- |
| idle | `viking_idle.png` | 1 | — | yes | hand-drawn |
| run | `viking_run.png` | 8 | 12 | yes | generated from idle by `make_viking_anims.py` |
| attack (axe swing) | `viking_attack.png` | 12 | 12 | no | generated from idle; hit frame is 9 (0-based 8) |

`make_viking_anims.py` (needs Python 3 + Pillow) cuts the idle sprite into parts and poses them per frame. Re-run it from `art-source/viking/` after editing the idle sprite; it rewrites the sheets, `.piskel` files and previews. Hand fixes go in the `.piskel` files, then re-export the PNG from Piskel and don't re-run the script for that animation.

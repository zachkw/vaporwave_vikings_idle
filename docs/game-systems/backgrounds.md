# Backgrounds and parallax

Purpose: draw each biome's background as several layers that scroll at different speeds behind the run, giving depth (decided 8 Oct: parallax with multiple layers).

## Rules

- Backgrounds are never interactive. Nothing in them collides, pays gold or blocks the view of the Viking, enemies or coins.
- Each biome has its own background scene with the same layer stack. Dimension set pieces are extra layers switched on while their dimension is active (see [Dimensions](dimensions.md)).
- Each layer repeats horizontally, so a short strip of art covers an endless run.
- The camera only moves sideways, so layers only scroll sideways.

## Layer stack

From back to front. Scroll scale is how fast the layer moves compared with the ground (0 = fixed, 1 = moves with the ground).

| Layer | Scroll scale | Throwaway placeholder | Biome art (from the artist) |
| --- | --- | --- | --- |
| Sky | 0, fixed to screen | Purple-to-orange gradient | Biome light source and sky colour |
| Sun / far element | 0.05 | Striped vaporwave sun | Moon (Dark Forest), volcano glow, and so on |
| Far scenery | 0.2 | Mountains with neon ridge lines | Far silhouettes |
| Mid scenery | 0.45 | Rounded hills | Mid parallax layer |
| Near scenery | 0.75 | Pine trees | Dense trees, rocks; low detail |
| Dimension set pieces | per piece | Not in the proof | Giant spinning triangle faces and others |

Five layers is the starting point; a biome may add or drop one.

## Godot

- `scenes/backgrounds/<biome>_background.tscn`: a `CanvasLayer` (layer −10) for the sky, then one `Parallax2D` node per layer with `scroll_scale`, `repeat_size` (one art strip wide, 1920 px in the proof) and `repeat_times = 3`.
- The art itself comes from the artist. Until then, `systems/parallax_placeholder.gd` draws throwaway shapes (sun, mountains, hills, trees) only to prove the layers scroll correctly. The artist's strips replace each layer's child with a `Sprite2D` or `TextureRect`; the `Parallax2D` setup stays.
- The run scene instances the current biome's background as its first child.

## Acceptance

- Running right, each layer visibly moves at a different speed; the sky does not move.
- No seams where a layer repeats.
- The Viking, enemies and coins stay readable over every layer.

## Open

How many layers each biome gets, and the dimension set-piece layers (D5). Art style (see [Art](../art/README.md)).

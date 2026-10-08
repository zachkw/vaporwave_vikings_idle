# HUD and menus

Purpose: what the player sees during a run and in the menus, in both phone orientations. Decided 8 October 2026: the game supports portrait and landscape, with one menu panel that docks to the bottom half in portrait and slides in as a drawer from the right in landscape.

Reference: the standard layout of idle runner games such as Slayer Legend (screenshot on the Miro board), where the top half is the game and the bottom half is an always-open upgrade panel.

## Orientations

| | Portrait | Landscape |
| --- | --- | --- |
| Game view | Top half of the screen | Whole screen, so a much wider stretch of the run is visible |
| Menu panel | Always open, docked to the bottom half | Closed by default. A menu button opens it as a drawer from the right edge |
| Drawer behaviour | n/a | Overlays the game view; the game keeps running underneath and the camera does not change. About 40 percent of the width (placeholder). A tap outside or the close button closes it |
| Top bar | Across the top of the game view | Across the top of the screen |
| Ability strip | Between the game view and the panel | Along the bottom edge of the game view |
| Switching | The game listens for the window size changing and re-docks the panel. The menu panel scene is instanced once and moved, never rebuilt | |

The camera always fits the 15-block segment height to the game view's height. Portrait therefore shows less ground ahead; landscape shows more.

## HUD (on the game view)

| Element | Where | Shows |
| --- | --- | --- |
| Player bar | Top left | Viking portrait, ascension level, level and biome name ("Dark Forest 2-3"), World+ when above 1 |
| Gold | Top centre | `wallet.gold` in short notation, ticking up, with gold per second beneath |
| Badges | Top bar | Biomes beaten this world |
| Boss | Top right | Progress along the level and distance to the boss |
| Health | Over the Viking's head | Current and max health as a bar |
| Active effects | Top right under the boss | One icon per active dimension or pickup, with remaining time |
| Next unlock hint | Near the gold | "Gloves at 10K" when close |
| Menu button | Bottom right of the game view, landscape only | Opens the drawer; shows a dot when something new is affordable |

## Ability strip

A row of buttons for abilities the player triggers by hand. Taps on the strip never cause a jump.

| Button | Shows when | Does |
| --- | --- | --- |
| Sprint | Legs level 1 owned | Starts a sprint; shows the cooldown as a sweep |
| Later: pickups or talents that need a tap | When owned | |

The wand is not a button: a tap in mid-air casts it. The jump is a tap anywhere on the game view that is not a button.

## Menu panel

One scene, used in both orientations. A bottom navigation bar selects a tab; each tab fills the panel with its own sub-tabs and scrolling content.

| Tab | Contents | First build |
| --- | --- | --- |
| Gear | Gear rows with the green or red buy button (see [Gear shop](gear-shop.md)); sub-tabs by group later (warrior, under-layer, jewellery, sets) | Yes |
| Artefacts | Owned artefacts, levels, material upgrades; equip the wand and ranged weapon | Later |
| Unlocks | Ingredients, pickups and courses found, with their state; achievements, including the seed achievements | Simple list |
| Ascension | Pending points, level, talent web | Later |
| Village | Buildings, garden, workshops | Later |
| Shop | Away-gold doubling, daily reward, any later store | Later |

Settings (sound, auto-consume rules) open from a gear icon in the top bar.

## Screens

- **Course fail:** "Watch an ad to retry" or "Back to the surface".
- **Welcome back:** away gold earned, with "Double it" (ad) and "Collect".
- **Daily reward:** streak and today's reward (later).

These are full-screen overlays in both orientations.

## Rules

- UI reads only through selectors and dispatches actions; it never computes rewards.
- The run never pauses for the menu panel or the drawer. Course and boss moments may pause it.
- Taps on any button are consumed by that button and never reach the jump input.
- Text uses short number notation (1.2K, 3.4M, then scientific); affordability compares full values.

## Godot

- `scenes/ui/menu_panel.tscn`: the panel with its nav bar and tabs. Instanced once by the run scene.
- `scenes/ui/hud.tscn`: top bar, health, effects, ability strip, menu button.
- `systems/layout.gd`: watches `get_viewport().size_changed`, decides portrait or landscape, sets the game view's rect, re-parents the panel between the bottom dock and the drawer, and tells the camera its view height.
- Drawer: a `Control` anchored to the right edge, slid in and out with a short tween; a dim overlay behind it catches outside taps.
- Project settings allow both orientations (`window/handheld/orientation = sensor`). The base viewport is 480 by 480 with `canvas_items` stretch, so the UI is laid out at about 480 units across in both orientations and scales up on phones.
- Built in the proof on 8 Oct: `systems/layout.gd`, `systems/menu_panel.gd`, with tests for both orientations and the drawer.

## Acceptance

- Rotating the phone mid-run re-docks the panel without losing the tab, scroll position or the run.
- In landscape the game view keeps running and its camera does not move while the drawer is open.
- Tapping a buy button or the strip never makes the Viking jump.
- In portrait the gear rows are usable without the game view shrinking below the 15-block height.

## Open

Exact drawer width; exact split in portrait (half, or weighted to the game); whether the panel can be collapsed in portrait for a full-screen run; layout once the art style exists (see [Art](../art/README.md)).

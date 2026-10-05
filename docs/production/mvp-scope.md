# MVP Scope

This document defines the first complete MVP target.

The MVP is not a tiny throwaway prototype. It is a small but complete vertical slice: one zone, deterministic tile generation, basic combat, coins, gear, shop UI, secret routes, powerups, boss gating, backend sessions, validation, and ascension.

## MVP Goal

Build one playable zone that proves the full game loop:

```text
Run -> jump -> collect coins -> kill enemies -> buy gear -> unlock secret routes -> unlock abilities -> beat boss -> ascend -> restart stronger
```

The MVP should be rough but structurally complete. It should show whether the game feels good and whether the backend validation model can support the design.

Supporting system docs:

- [Level Design](../game-design/level-design.md)
- [Tile Map Generation](../game-design/tile-map-generation.md)
- [Gear Progression](../game-design/gear-progression.md)
- [Challenge Courses and Ability Unlocks](../game-design/challenge-courses-and-ability-unlocks.md)
- [Abilities and Powerups](../game-design/abilities-and-powerups.md)
- [Ascension Progression](../game-design/ascension-progression.md)
- [Client State Store](../technical/client-state-store.md)
- [Progression Validation](../technical/progression-validation.md)
- [Validation Service](../technical/validation-service.md)

## Zone Scope

The MVP has one zone.

The zone includes:

- One main generated route.
- One boss at the end of the zone.
- Two common enemy types.
- Blocking behavior when enemy damage checks are not met.
- Two secret routes.
- Basic coin placement.
- Passive gold while running.
- Gear shop and upgrade UI.
- Ascension reset and permanent upgrade.

The zone does not need multiple biomes, multiple worlds, or a full map screen yet.

## Tile Scope

The MVP should use deterministic tile generation.

Tile assumptions:

- Tiles are 15 blocks high.
- Tile widths can vary.
- MVP tiles have one entry connector and one exit connector.
- The first tile set can mostly use row 2 to row 2 connectors.
- The data model should still support tiles that exit at a different Y row and require the next tile to enter at that row.
- Route distance should be trackable by cumulative X distance in block units or a shared pixel conversion.

Minimum tile set:

- Two basic ground tiles.
- One coin-line tile.
- One simple jump tile.
- One enemy tile for Enemy 1.
- One enemy tile for Enemy 2.
- One blocker tile.
- One boss approach tile.
- One boss tile.
- One secret-route entrance tile for speed boost.
- One secret-route entrance tile for magnetism.
- One special-box tile that can appear after magnetism is unlocked.

The route generator should use a server-issued map seed and shared deterministic generation rules so the backend can reproduce the same tile sequence.

## Secret Routes

The MVP has two secret routes.

| Secret Route | Reward |
| --- | --- |
| Speed route | Grants speed boost for immediate use. |
| Magnet route | Unlocks magnet special boxes. |

The speed route should be a more precise platforming section. Completing it grants speed boost immediately, with no initial purchase.

The magnet route should unlock special boxes that can contain magnetism. Magnetism pulls nearby coins to the player for a short duration.

Secret route completion grants its special ability immediately, or enables the relevant powerup type. Wealth-bracket items instead require buying level 1 after the bracket makes them available.

On challenge failure, offer an optional rewarded ad for another attempt or return the player to the level where they entered. The ad does not grant the completion reward. Retry position, retry limits, failed-attempt rewards, and production ad integration timing remain to be defined.

## Enemies and Boss

The MVP has two regular enemy types and one boss.

The broader design includes three enemy layers: biome-grounded creatures, surreal hallucination monsters, and the demonic true layer. Biome enemies are always present; the mushrooms taken determine which extra layers appear, and both overlays can coexist. Confirmed examples are volcanic lava snails, walking stone triangles with eyes and clown shoes, and red flying demon imps. The first build's layer coverage, mushroom effects, and mapping of these examples to the initial roster remain unscoped.

Discoverable world pickups include mushrooms, flowers, and other forms. Discovering a type unlocks future drops, whose effects activate when taken and can stack to provide more enemies, multipliers, and special effects. Mushrooms specifically reveal Whacky World or Demon World, which can appear together over the real biome. Extra-layer enemies can hurt the Viking, but mainly supply more targets and access to higher-grade materials. Discovery sources, drop rates, exact other-pickup effects, stacking arithmetic, reward tables, and inclusion in the first playable build remain to be scoped.

Mushroom discovery specifically uses the existing challenge rooms/courses. Their rewards unlock future drops of the discovered type. Exact room assignments, other pickup discovery sources, and the first build's mushroom content remain to be scoped.

Repeating the same pickup adds its full duration to the remaining duration. Garden-grown and world-dropped versions are different items and can apply the same buff concurrently with separate durations. Exact numerical combination and duration values remain open.

An ascension upgrade unlocks late-game cultivation. Repeated use of each growable item unlocks its seeds, and both unlocks survive ascension. The player grows stock and enables a simple Auto use toggle, consuming another unit whenever the current effect expires to maintain its extra enemy layer for gold farming. This belongs beyond the first playable slice. Upgrade costs, use thresholds, growth rates, durations, offline behavior, and retention of unfinished use progress, crops, stock, and active effects remain open.

Late-game production may eventually use a village with gardens and breweries, or simple permanent ascension upgrades named for individual gardens. Both presentations are undecided; no village or building-management feature is added to the first playable scope by this idea.

Enemy roles:

- Enemy 1: basic enemies in packs, killed in one hit.
- Enemy 2: larger epic enemy that stops the Viking for a fight and tests combat upgrades.
- Boss: end-of-zone progression gate.

Enemies reward gold when killed. Defeating a level boss automatically advances to the next level and should be a major moment, even if the first implementation is simple.

The Viking has health, takes damage, and can die. Combat, including the boss, checks damage output and survivability through health and defence. Health regenerates gradually but generously out of combat, and resurrection restores full health. Defensive upgrades come from gear, such as chest gear increasing health and defence. Exact formulas remain to be defined. The boss does not need a separate DPS countdown and returns to full health for each attempt.

Unattended play with the game open continues running, fighting, and earning wealth. Death quickly restarts the same level, retains accumulated gold and purchased upgrades, and resumes movement automatically. There is no manual resurrection step. Upgrades should eventually make previously lethal encounters survivable. Exact respawn timing remains to be tuned.

Epic enemies supply the blocking behavior: the Viking stops and fights until the encounter is resolved. Bosses are larger encounters with progression or content gates.

## Gear and Shop

The opening set has three gear pieces: Viking Axe, Chest, and Helmet. These provide clear choices between damage, survival, and income. The amount of the later wealth-bracket gear ladder included in the first playable build remains to be scoped.

Gear behavior:

- The three essential pieces are introduced early; exact initial availability and unlock order remain open.
- Further pieces become available for purchase at increasing thresholds measured against gold currently held; exact amounts remain open. A paid first level is required.
- All purchased gear bonuses stay active together. Repeated purchases increase the same item's level, with increasing costs for successive levels.
- Bracket entry grants no free level or effect. Buying level 1 grants the item's initial benefit.
- Each gear purchase adds one level.
- Next level cost uses `base_cost * 1.15 ^ current_level`.
- Gear has distinct stat roles rather than every piece granting equal gold and damage.
- Chest increases toughness and health; Viking Axe increases axe-swing damage.
- Helmet increases all gold by a percentage.
- Later wealth-bracket pieces mainly improve gold per metre, all-source gold, coin value, or monster-kill gold (such as Gloves), with repeated effects allowed across items.
- Additional earlier examples include enemy-kill gold (Hunting Axe), coin value (Golden Amulet), and passive generation (shoulder pads). The final roster and balance remain open, as does whether passive generation is distance-based or also time-based.
- Gear milestone upgrades can multiply a gear piece's output.

The previous five-piece table is superseded by the opening trio and later wealth-based progression. New-item brackets should begin around `10x` apart, gradually widen toward `1,000x`, and extend toward approximately `10^30` gold. Starting costs, the exact bracket sequence, later roster, and first-build endpoint still need tuning. See [Gear Progression](../game-design/gear-progression.md).

Later levels provide higher gold rewards, making combat upgrades a route to richer farming. The first build is still scoped to one zone; whether it includes several levels with increasing rewards remains a scope decision.

The broader progression automatically advances after each boss and automatically advances World+ after clearing the current world's full sequence. World+ keeps gold, gear levels, and abilities while presenting the sequence again with higher gold rewards. Within a world level, content also gets a little harder through gentler progression, and higher biome levels provide more gold. Players eventually reach a practical ceiling based on affordable Chest/Axe progression, then ascend and repeat with permanent benefits. Within-world biome advancement triggers and scaling remain open. Optional portals send the player to another random biome to revisit content, resources, or missed unlocks rather than only retrying a stronger final boss. A five-level ascension upgrade provides a biome-start portal chance of 20%, 40%, 60%, 80%, then 100%. Ordinary route encounters, arrival rules, portal eligibility across transitions, and inclusion in the first build remain to be scoped.

The shop should be available through the persistent menu system and should support frequent gear buying.

Required shop entries:

- Viking Axe, Chest, and Helmet, plus later wealth-bracket pieces as those enter scope.
- Ability status showing speed boost as usable once the speed secret route is completed.
- Any required milestone upgrade entries for gear.
- Ascension upgrade tab or entry once ascension is available.

## Abilities and Powerups

The MVP has two special progression rewards:

- Speed boost.
- Magnetism.

The broader special-upgrade direction also includes Francisca throwing axes, fireballs, and sapphire/ruby/emerald coins worth 2g/3g/4g. Special abilities become usable immediately when discovered or earned from bosses. Example attacks include automatic aerial axes and a three-fireball arc on airborne jump input; these mechanics are provisional. Their inclusion in the first playable build, specific reward sources, and detailed tuning remain to be scoped.

The broader biome-resource system supplies potions, balms, and similar consumables. Both potions and balms can increase damage and other stats. Balms give glowing skin; potions can raise hallucinations, enemy counts, and multipliers. The permanent-versus-distance-limited effect lifecycle still needs clarification. Recipes, balance, and inclusion in the first playable build are not yet committed.

Speed boost:

- Granted for immediate use by completing the speed secret route, with no initial gold purchase.
- Lets the player run faster for a short duration.
- Activated manually with a sprint button.

Magnetism:

- Unlocked by completing the magnet secret route.
- Appears from eligible special boxes after unlock.
- Is instantly picked up when the box is hit.
- Pulls coins toward the player for a short duration.

The MVP should include seeded special-box appearance logic for magnetism once it is unlocked. Box frequency can be rough, but it should be data-visible for validation.

## Ascension

The MVP includes ascension.

Ascension resets run-level progress and banks pending points earned through lifetime gold progression. The first optional offer arrives on beating World+1, targeting a few play sessions. How the one-zone prototype demonstrates that milestone remains a scope decision; this does not silently add multiple worlds to the first slice.

All discovered special abilities reset by default. Purchased ascension retention unlocks will keep covered abilities unlocked across ascensions; their exact roster and inclusion alongside the first build's repeatable gold upgrade remain to be scoped.

Each successive point requires a larger gold increment, increasing indefinitely across the account lifetime. Ascension preserves this progress and requirement. Spending gold or points does not restart the curve. Bank pending points once per ascension, preserve previously unspent points, and allow them to be spent whenever desired during later play. The starting increment, growth curve, and eligible gold sources remain to be tuned; the earlier per-run square-root formula is superseded.

The MVP has one repeatable ascension upgrade:

```text
ascension_gold_multiplier = 1 + ascension_cps_upgrade_level * 0.05
```

Each level gives `+5%` global gold/CPS. This is intentionally simple and based on the Idle Slayer idea that ascension adds broad CpS power on top of equipment progression.

Idle Slayer's public strategy guidance describes ascension CpS bonus as roughly `+1% CpS per Slayer Point`, with later upgrades modifying that total. The MVP uses `+5%` per purchased ascension upgrade level because it is easier to understand and tune.

## Backend Scope

The MVP backend should support:

- Guest account or simple login.
- Authoritative player profile.
- Content configuration endpoint.
- Run session start.
- Server-issued map seed.
- Internet-required active play with two-minute routine progress checkpoints for low operating cost. A further 1-2-minute retry allowance after a checkpoint is due is proposed, allowing at most 3-4 minutes of provisional progress between validations.
- Online handshake and delta reconciliation.
- Persistent pending progress and retry-safe checkpoint commits for brief connections between signal outages.
- Deltas generated from the client state store action log.
- Progress report submission.
- Reward validation.
- Gear purchase endpoint.
- Validation and authoritative granting of discovered special abilities through content rewards.
- Secret route completion validation.
- Powerup/drop validation.
- Boss clear validation.
- Ascension endpoint.
- Ascension upgrade purchase endpoint.
- Economy ledger entries for gold and purchases.

The backend does not need perfect anti-cheat, but it should own durable progression.

## Validation Scope

Starting validation should check:

- Run session exists and report order is valid.
- Seed lease is valid for the reported elapsed time.
- Reported tile range is possible from the server seed.
- Gold is within possible bounds.
- Coin pickups are possible for the generated tiles.
- Enemy kills are possible for gear-derived damage.
- Blocker clear times are plausible.
- Secret route entrances appeared before completion is accepted.
- Speed boost ownership is granted only for a valid speed-route completion or an owned ascension retention unlock, if that unlock is included in the build.
- Wealth-bracket item effects begin only after a valid paid first-level purchase.
- Magnet special boxes and activations can only appear after magnet unlock exists.
- Boss clear is plausible for the player's damage.
- Ascension rewards match accepted lifetime earned-gold progress and the increasing point requirements; banking cannot reclaim previously banked points.
- Purchases inside a delta are affordable and ordered plausibly.
- Closed-app rewards grant reduced gold only, validated on return against server-tracked real elapsed time. There is no cap; declining rate bands change at 12, 24, 48, and 168 hours, with percentages still to be tuned.
- A validated return and reward claim resets the away-income schedule to its first band; no minimum active-play period is required.
- Active play stays within the short connection grace window, and pending progress survives a later reconnect.

This can begin as upper-bound validation and become more exact over time. Reports that are too good should be clamped to a practical cap first. Repeated near-perfect or impossible reports should lower trust score, eventually causing shorter seed leases, restricted offline progression, or bans.

## Return Rewards

There are two independent return systems: a daily login bonus with a consecutive-day streak, and an optional rewarded ad to double each banked away-gold payout. The daily reward is separate and requires no ad. Doubling means one additional credit equal to the validated base away reward, for `2x` total, applied at most once per payout; it does not include the daily login bonus or affect the streak.

The base reward and away-rate reset should settle on validated return. An ad is optional and does not gate the normal payout. Daily reward contents, streak/day rules, presentation, ad provider, and the timing of production ad integration remain to be defined.

The separate challenge-failure ad grants another attempt, not away gold or daily rewards. Validate its completion and grant each retry once.

## UI Scope

The MVP needs a basic persistent menu system.

Menu structure:

- Shop tab.
- Gear tab or gear section inside shop.
- Unlocks section for everything found and unlocked through discovery in the world.
- Abilities tab or ability section inside shop.
- Ascension tab.
- Profile or debug tab if useful for development.

The older abilities-tab proposal can be incorporated into the confirmed Unlocks section; final tab placement is not fixed. Include current-world progress badges, with one earned badge for each biome beaten in the current World+ level. Prior-world clear history must not mark an uncleared current-world biome as beaten. Exact badge appearance and placement remain open; the initial one-biome slice can demonstrate its own badge without expanding the biome roster.

The player should be able to open the shop/menu while the run continues or pauses, depending on what feels best during prototype.

The UI should subscribe to the client state store rather than directly owning progression state. Gameplay systems dispatch actions to the store, and UI tabs update when relevant state changes.

The gear menu must use rows with an item icon, effect description, current level, and a right-aligned button to buy the next level. Display the next-level cost on that button. For available gear, the button is green when current gold is sufficient and red otherwise, with the cost visible in either state. Update the level, next price, and affected buttons immediately after a purchase. The default action buys one level; bulk-buy controls are optional future additions.

The first UI can be plain, but it must support the real loop:

- View gold.
- Buy gear.
- Browse discovered world unlocks, including ability and powerup/drop eligibility states.
- See badges for biomes beaten in the current world level.
- See locked/unlocked abilities.
- Use speed boost immediately after earning it.
- See magnet unlock state.
- Ascend when eligible.
- Buy the repeatable ascension upgrade.

## Out of Scope

The MVP does not need:

- Multiple zones.
- Multiple worlds.
- Full world map.
- Twenty gear pieces implemented.
- Rare gear drops.
- Gear affixes.
- Crafting.
- Multiple ascension upgrades.
- Extended offline active play beyond the short connection grace window.
- Closed-app automation of bosses, discoveries, or purchases; these are later upgrade ideas, likely for ascension.
- Full mobile production polish.
- Monetization beyond the optional away-gold doubling and challenge-retry ads described above.
- Analytics beyond basic debug telemetry.

## Completion Definition

The MVP is complete when a player can:

1. Start a run.
2. Run through generated tiles.
3. Jump and collect coins.
4. Kill two enemy types.
5. Earn passive and active gold.
6. Buy gear upgrades.
7. Feel damage affect enemy and blocker clear speed.
8. Enter and complete two secret routes.
9. Earn speed boost and use it immediately.
10. Unlock magnet special boxes.
11. Defeat the zone boss.
12. Submit validated progress to the backend.
13. Ascend.
14. Buy the repeatable `+5%` ascension gold/CPS upgrade.
15. Start again stronger.

# Economy

Gold is the only main currency. Everything else in the game exists to raise how much gold the Viking earns per second, and the plan is to define every value, then simulate and plot how long the journey takes.

## Gold sources

The Viking earns gold from three things he passes while running:

| Source | What pays |
| --- | --- |
| Distance | Gold per metre: the passive income. Every core gear piece adds to it, so it is the Idle Slayer coins-per-second equivalent |
| Coins | Gold per coin; coins sit along the run, in sky-coin lines, in gold rushes and in farm courses |
| Enemies | Gold per kill, by role: basic, elite, boss and dimensional |

Bursty extras sit on top: boss rewards, farm courses, and away gold.

## Gold per second

```latex
\text{gold/sec} = \text{speed} \times M_{\text{all}} \times \left( g_{\text{metre}} + n_{\text{coin}}\, g_{\text{coin}} + \sum_{e} n_{e}\, g_{e} \right)
```

n is how many of each thing the Viking passes per metre, g is what each pays, e runs over every enemy type present, and M-all is every all-gold multiplier combined.

- **Speed multiplies everything**, so it stays small and bounded.
- **Sources add; they do not multiply.** Doubling coin gold only doubles the coin share. Upgrades therefore come in two kinds: tied to one source, or all-gold.
- **Each active dimension adds another enemy term**, which is why stacking ingredients pays.
- **Crits** multiply enemy gold on average by 1 + crit chance × (crit gold multiplier − 1). See [Controls and combat](controls-and-combat.md).

The same formula, as `expected_gold_per_second`, is what the server uses to check synced gold. See the [state store spec](../technical/state-store-spec.md).

### Starting balance (placeholder)

To show the method only; the rates are not decisions (E2).

| Source | Per metre | Gold each | Gold per metre | Share |
| --- | --- | --- | --- | --- |
| Distance | 1 | 1 | 1 | 10% |
| Coins | 0.5 | 6 | 3 | 30% |
| Basic enemy | 0.1 | 25 | 2.5 | 25% |
| Elite enemy | 0.01 | 150 | 1.5 | 15% |
| Boss | 0.001 | 500 | 0.5 | 5% |
| Dimensional enemy | 0.1 | 15 | 1.5 | 15% |

That totals 10 gold per metre, or 50 gold per second at 5 metres per second.

## Scale

- Numbers should climb from a few gold to scientific notation. Early upgrades arrive fast; later ones spread out.
- The top gold number at launch is not chosen (E1). The draft gear ladder implies about 10^31, or 10^46 with set pieces. For reference, Idle Slayer tops out around 10^74, and many idle games cap near 10^308.
- Gold is stored as a 64-bit float, exact to about 15 digits and good to 10^308.

## Spending

- **Gear levels:** the main sink, and the main source: each level adds gold per metre plus the piece's own effect. See [Gear and artefacts](gear-and-artefacts.md) for the unlock ladder and the linear level cost.
- **Artefact levels:** gold, materials or both (P2).
- **Talents:** bought with ascension points, not gold.

## Away gold

While the app is closed the Viking earns gold only, at a reduced rate. Bosses, unlocks and purchases do not happen while away. Later talents may automate more.

- The server measures the time away with its own clock.
- There is no cap, but the rate drops the longer the player is away. Each rate applies only to the time inside its band:

| Time away | Rate (June proposal, E3) |
| --- | --- |
| 0 to 12 hours | 50% of the reference rate |
| 12 to 24 hours | 25% |
| 24 to 48 hours | 10% |
| 48 to 168 hours | 5% |
| 168 hours onward | 1%, with no end |

- A validated return resets the schedule to the first band.
- The reference rate is not defined yet; `expected_gold_per_second` at the moment the player left is the obvious candidate.

## Return rewards and ads

- **Daily login bonus.** A conventional daily reward with a consecutive-day streak. No ad needed. Rewards, cycle length and missed-day rules are open.
- **Double away gold.** Each away-gold payout offers one optional rewarded ad that doubles it. Declining keeps the normal payout. It does not affect the daily streak.
- **Course retry.** Failing an assault course offers an ad for another attempt. See [Courses and unlocks](courses-and-unlocks.md).
- Each ad reward is granted once, for its own purpose. There is no server-side ad verification (decided 8 Oct).

## Open

- E1 top gold number, E2 starting split, E3 away rates, P3 how same-source boosts stack, P5 gem coins (sapphire 2g, ruby 3g, emerald 4g in June).

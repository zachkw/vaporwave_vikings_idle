## The empty player: what a brand-new save looks like. Slices not yet built
## exist as empty dictionaries so adding them later does not change the format.
## See "State tree" in docs/technical/state-store-spec.md.
class_name InitialState
extends RefCounted

const SAVE_FORMAT := 1


static func make() -> Dictionary:
	var gear := {}
	for item in Content.load_json("res://content/gear.json"):
		gear[item["id"]] = {"unlocked": float(item["bracket"]) <= 0.0, "level": 0}
	var viking: Dictionary = Content.load_json("res://content/viking.json")
	return {
		"meta": {
			"save_format": SAVE_FORMAT,
			"player_id": "",
			"device_id": "",
			"content_version": "",
		},
		"wallet": {"gold": 0.0, "lifetime_gold": 0.0},
		"gear": gear,
		"artefacts": {},
		"loadout": {"wand": "", "ranged": ""},
		"unlocks": {"ingredients": [], "pickups": [], "courses": []},
		"inventory": {},
		"effects": [],
		"run": {
			"world_level": 1,
			"biome": "dark_forest",
			"level_index": 0,
			"level_seed": 0,
			"distance_m": 0.0,
			"health": float(viking["health"]),
			"sprint_cooldown_s": 0.0,
			"play_seconds": 0.0,
		},
		"progress": {"badges": [], "bosses_beaten": 0},
		"stats": {
			"lifetime": {"kills": {}, "coins": 0, "metres": 0.0, "deaths": 0, "pit_falls": 0, "eats": {}},
			"run": {"kills": {}, "coins": 0, "metres": 0.0, "deaths": 0, "pit_falls": 0},
		},
		"ascension": {"level": 0, "points_unspent": 0, "talents": {}},
		"village": {},
		"sync": {"rev": 0, "baseline": {}, "queued_batches": [], "last_sync_at": ""},
	}

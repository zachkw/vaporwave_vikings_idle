## Derived values the UI and gameplay read. Selectors read state and content
## and store nothing. See docs/technical/state-store-spec.md.
class_name Selectors
extends RefCounted

static var _gear_by_id: Dictionary = {}
static var _gear_sorted: Array = []


static func gear_table() -> Array:
	if _gear_sorted.is_empty():
		_gear_sorted = Content.load_json("res://content/gear.json").duplicate()
		_gear_sorted.sort_custom(func(a, b): return int(a["order"]) < int(b["order"]))
		for item in _gear_sorted:
			_gear_by_id[item["id"]] = item
	return _gear_sorted


static func gear_item(slot: String) -> Dictionary:
	gear_table()
	return _gear_by_id.get(slot, {})


static func gear_level(state: Dictionary, slot: String) -> int:
	return int(state["gear"].get(slot, {}).get("level", 0))


static func is_unlocked(state: Dictionary, slot: String) -> bool:
	return bool(state["gear"].get(slot, {}).get("unlocked", false))


## Sum of one per_level stat across all gear, times level.
static func gear_stat(state: Dictionary, key: String) -> float:
	var total := 0.0
	for item in gear_table():
		total += float(item["per_level"].get(key, 0.0)) * gear_level(state, item["id"])
	return total


static func gold_per_metre(state: Dictionary) -> float:
	var base := float(Content.load_json("res://content/economy.json")["gold_per_metre"])
	return (base + gear_stat(state, "gold_per_metre")) * (1.0 + gear_stat(state, "gold_all_pct") / 100.0)


static func coin_value(state: Dictionary, _kind: String = "gold") -> float:
	var base := float(Content.load_json("res://content/economy.json")["coin_value"])
	return base * (1.0 + gear_stat(state, "gold_coin_pct") / 100.0) * (1.0 + gear_stat(state, "gold_all_pct") / 100.0)


## Gold for a kill: base gold with the role's percentage boost, all-gold boost, and crit.
static func enemy_gold(state: Dictionary, enemy: Dictionary, crit: bool = false) -> float:
	var role_key := "gold_%s_pct" % enemy["role"]
	if enemy.get("dimension", "") != "":
		role_key = "gold_dimensional_pct"
	var g := float(enemy["gold"]) * (1.0 + gear_stat(state, role_key) / 100.0) * (1.0 + gear_stat(state, "gold_all_pct") / 100.0)
	if crit:
		g *= float(Content.load_json("res://content/viking.json")["crit"]["base_gold_mult"])
	return g


static func damage(state: Dictionary) -> float:
	var viking: Dictionary = Content.load_json("res://content/viking.json")
	return float(viking["sword_damage"]) + gear_stat(state, "damage")


static func defence(state: Dictionary) -> float:
	return gear_stat(state, "defence")


static func max_health(state: Dictionary) -> float:
	var viking: Dictionary = Content.load_json("res://content/viking.json")
	return float(viking["health"]) + gear_stat(state, "health")


static func has_sprint(state: Dictionary) -> bool:
	for item in gear_table():
		if item.get("grants", []).has("sprint") and gear_level(state, item["id"]) >= 1:
			return true
	return false


static func run_speed_mult(state: Dictionary) -> float:
	return 1.0 + gear_stat(state, "run_speed_pct") / 100.0


## Linear cost: base + step x level. See docs/game-systems/gear-shop.md.
static func next_level_cost(state: Dictionary, slot: String) -> float:
	var item := gear_item(slot)
	if item.is_empty():
		return INF
	return float(item["base_cost"]) + float(item["step"]) * gear_level(state, slot)


static func can_afford(state: Dictionary, slot: String) -> bool:
	return is_unlocked(state, slot) and float(state["wallet"]["gold"]) >= next_level_cost(state, slot)


## The first locked slot in order, or {} when every slot is unlocked.
static func next_slot_unlock(state: Dictionary) -> Dictionary:
	for item in gear_table():
		if not is_unlocked(state, item["id"]):
			return item
	return {}


static func gold(state: Dictionary) -> float:
	return float(state["wallet"]["gold"])


static func ingredient(id: String) -> Dictionary:
	for ing in Content.load_json("res://content/ingredients.json"):
		if ing["id"] == id:
			return ing
	return {}


static func course(id: String) -> Dictionary:
	for c in Content.load_json("res://content/courses.json"):
		if c["id"] == id:
			return c
	return {}


static func active_effects(state: Dictionary) -> Array:
	return state.get("effects", [])


static func is_effect_active(state: Dictionary, ingredient_id: String) -> bool:
	for e in active_effects(state):
		if e["id"] == ingredient_id:
			return true
	return false


static func is_ingredient_unlocked(state: Dictionary, ingredient_id: String) -> bool:
	return state["unlocks"]["ingredients"].has(ingredient_id)


static func is_course_completed(state: Dictionary, course_id: String) -> bool:
	return state["unlocks"]["courses"].has(course_id)


## Blend of every active dimension's colour shift, white when none.
static func colour_shift(state: Dictionary) -> Color:
	var c := Color(1, 1, 1)
	for e in active_effects(state):
		var ing := ingredient(e["id"])
		if ing.is_empty():
			continue
		var shift: Array = ing["colour_shift"]
		c = c * Color(shift[0], shift[1], shift[2])
	return c

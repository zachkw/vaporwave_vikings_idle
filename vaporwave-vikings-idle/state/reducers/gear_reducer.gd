## gear slice: per-slot unlocked flag and level.
class_name GearReducer
extends RefCounted


## Runs before the wallet reducer: decides whether the purchase is valid and
## stamps the action with the cost so the wallet can deduct it.
static func reduce(state: Dictionary, action: Dictionary) -> void:
	if action["type"] != Actions.GEAR_LEVEL_BOUGHT:
		return
	var slot: String = action["slot"]
	if not Selectors.is_unlocked(state, slot):
		return
	var count := int(action.get("count", 1))
	var total := 0.0
	var level := Selectors.gear_level(state, slot)
	var item := Selectors.gear_item(slot)
	for i in count:
		total += float(item["base_cost"]) + float(item["step"]) * (level + i)
	if float(state["wallet"]["gold"]) < total:
		return
	state["gear"][slot]["level"] = level + count
	action["_applied"] = true
	action["_cost"] = total

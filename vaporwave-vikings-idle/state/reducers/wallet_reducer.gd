## wallet slice: gold now and lifetime gold. Also unlocks gear slots whose
## bracket the wallet reaches, since that follows from gold, not an action.
class_name WalletReducer
extends RefCounted


static func reduce(state: Dictionary, action: Dictionary) -> void:
	var wallet: Dictionary = state["wallet"]
	match action["type"]:
		Actions.DISTANCE_TRAVELLED:
			_earn(state, Selectors.gold_per_metre(state) * float(action["metres"]))
		Actions.COIN_COLLECTED:
			_earn(state, Selectors.coin_value(state, action["kind"]) * int(action["count"]))
		Actions.ENEMY_KILLED:
			var data := Spawner.enemy_data(action["enemy_id"])
			if not data.is_empty():
				_earn(state, Selectors.enemy_gold(state, data, bool(action.get("crit", false))))
		Actions.GEAR_LEVEL_BOUGHT:
			# Cost check happens in the gear reducer; it marks the action as applied.
			if action.get("_applied", false):
				wallet["gold"] = max(0.0, float(wallet["gold"]) - float(action["_cost"]))


static func _earn(state: Dictionary, amount: float) -> void:
	if amount <= 0.0:
		return
	var wallet: Dictionary = state["wallet"]
	wallet["gold"] = float(wallet["gold"]) + amount
	wallet["lifetime_gold"] = float(wallet["lifetime_gold"]) + amount
	# A slot unlocks the first time the wallet holds its bracket, and stays unlocked.
	for item in Selectors.gear_table():
		var slot: Dictionary = state["gear"][item["id"]]
		if not slot["unlocked"] and float(wallet["gold"]) >= float(item["bracket"]):
			slot["unlocked"] = true

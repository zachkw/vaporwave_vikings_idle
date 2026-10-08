## wallet slice: gold now and lifetime gold. Also unlocks gear slots whose
## bracket the wallet reaches, since that follows from gold, not an action.
class_name WalletReducer
extends RefCounted


static func reduce(state: Dictionary, action: Dictionary) -> void:
	var wallet: Dictionary = state["wallet"]
	match action["type"]:
		Actions.DISTANCE_TRAVELLED:
			_earn(state, Selectors.gold_per_metre(state) * float(action["metres"]), "distance")
		Actions.COIN_COLLECTED:
			_earn(state, Selectors.coin_value(state, action["kind"]) * int(action["count"]), "coins")
		Actions.ENEMY_KILLED:
			var data := Spawner.enemy_data(action["enemy_id"])
			if not data.is_empty():
				var source: String = "dimensional" if action.get("dimension", "") != "" else String(action["role"])
				_earn(state, Selectors.enemy_gold(state, data, bool(action.get("crit", false))), source)
		Actions.GEAR_LEVEL_BOUGHT:
			# Cost check happens in the gear reducer; it marks the action as applied.
			if action.get("_applied", false):
				wallet["gold"] = max(0.0, float(wallet["gold"]) - float(action["_cost"]))
				SyncReducer.note_spent(state, float(action["_cost"]))
		Actions.SYNC_TRIMMED:
			# The server found more gold than was possible; take the excess back, never below zero (T5).
			var removed := 0.0
			for t in action.get("trims", []):
				removed += float(t["gold_removed"])
			wallet["gold"] = max(0.0, float(wallet["gold"]) - removed)


static func _earn(state: Dictionary, amount: float, source: String) -> void:
	if amount <= 0.0:
		return
	SyncReducer.note_earned(state, source, amount)
	var wallet: Dictionary = state["wallet"]
	wallet["gold"] = float(wallet["gold"]) + amount
	wallet["lifetime_gold"] = float(wallet["lifetime_gold"]) + amount
	# A slot unlocks the first time the wallet holds its bracket, and stays unlocked.
	for item in Selectors.gear_table():
		var slot: Dictionary = state["gear"][item["id"]]
		if not slot["unlocked"] and float(wallet["gold"]) >= float(item["bracket"]):
			slot["unlocked"] = true

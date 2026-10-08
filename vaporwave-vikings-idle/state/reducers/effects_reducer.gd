## effects and unlocks slices: dimension effects, course and ingredient unlocks.
class_name EffectsReducer
extends RefCounted


static func reduce(state: Dictionary, action: Dictionary) -> void:
	match action["type"]:
		Actions.INGREDIENT_EATEN:
			var ing := Selectors.ingredient(action["ingredient_id"])
			if ing.is_empty():
				return
			var effects: Array = state["effects"]
			# Eating the same ingredient again refreshes its timer (proposed).
			for e in effects:
				if e["id"] == action["ingredient_id"]:
					e["form"] = action["form"]
					e["remaining_s"] = float(ing["raw_timer_s"]) if action["form"] == "raw" else -1.0
					_count_eat(state, action["ingredient_id"])
					return
			effects.append({
				"id": action["ingredient_id"],
				"form": action["form"],
				"remaining_s": float(ing["raw_timer_s"]) if action["form"] == "raw" else -1.0,
			})
			_count_eat(state, action["ingredient_id"])
		Actions.TIME_ADVANCED:
			var dt := float(action["seconds"])
			var effects: Array = state["effects"]
			for i in range(effects.size() - 1, -1, -1):
				var e: Dictionary = effects[i]
				if float(e["remaining_s"]) < 0.0:
					continue  # mixed form: lasts the whole level
				e["remaining_s"] = float(e["remaining_s"]) - dt
				if float(e["remaining_s"]) <= 0.0:
					effects.remove_at(i)
		Actions.LEVEL_STARTED:
			# Mixed-form effects end with the level; raw ones keep their timer.
			var effects: Array = state["effects"]
			for i in range(effects.size() - 1, -1, -1):
				if float(effects[i]["remaining_s"]) < 0.0:
					effects.remove_at(i)
		Actions.COURSE_COMPLETED:
			var courses: Array = state["unlocks"]["courses"]
			if not courses.has(action["course_id"]):
				courses.append(action["course_id"])
			var reward: Dictionary = action["reward"]
			match reward.get("type", ""):
				"ingredient":
					var list: Array = state["unlocks"]["ingredients"]
					if not list.has(reward["id"]):
						list.append(reward["id"])
				"pickup":
					var list: Array = state["unlocks"]["pickups"]
					if not list.has(reward["id"]):
						list.append(reward["id"])


static func _count_eat(state: Dictionary, id: String) -> void:
	var eats: Dictionary = state["stats"]["lifetime"]["eats"]
	eats[id] = int(eats.get(id, 0)) + 1

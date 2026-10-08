## run slice: where the Viking is and how he is doing. Also run stats.
class_name RunReducer
extends RefCounted


static func reduce(state: Dictionary, action: Dictionary) -> void:
	var run: Dictionary = state["run"]
	var stats: Dictionary = state["stats"]
	match action["type"]:
		Actions.TIME_ADVANCED:
			var dt := float(action["seconds"])
			run["play_seconds"] = float(run["play_seconds"]) + dt
			run["sprint_cooldown_s"] = max(0.0, float(run["sprint_cooldown_s"]) - dt)
		Actions.DISTANCE_TRAVELLED:
			var m := float(action["metres"])
			run["distance_m"] = float(run["distance_m"]) + m
			stats["lifetime"]["metres"] = float(stats["lifetime"]["metres"]) + m
			stats["run"]["metres"] = float(stats["run"]["metres"]) + m
		Actions.COIN_COLLECTED:
			stats["lifetime"]["coins"] = int(stats["lifetime"]["coins"]) + int(action["count"])
			stats["run"]["coins"] = int(stats["run"]["coins"]) + int(action["count"])
		Actions.ENEMY_KILLED:
			var role: String = action["role"]
			for scope in ["lifetime", "run"]:
				var kills: Dictionary = stats[scope]["kills"]
				kills[role] = int(kills.get(role, 0)) + 1
		Actions.PLAYER_DAMAGED:
			var hp := float(run["health"]) - float(action["amount"])
			# Basic enemies can never kill the Viking (decided 8 Oct).
			if action.get("source_role", "") == "basic":
				hp = max(1.0, hp)
			run["health"] = max(0.0, hp)
		Actions.PLAYER_DIED:
			stats["lifetime"]["deaths"] = int(stats["lifetime"]["deaths"]) + 1
			stats["run"]["deaths"] = int(stats["run"]["deaths"]) + 1
			run["health"] = Selectors.max_health(state)
		Actions.PIT_FALLEN:
			stats["lifetime"]["pit_falls"] = int(stats["lifetime"]["pit_falls"]) + 1
			stats["run"]["pit_falls"] = int(stats["run"]["pit_falls"]) + 1
		Actions.SPRINT_USED:
			var sprint: Dictionary = Content.load_json("res://content/viking.json")["sprint"]
			run["sprint_cooldown_s"] = float(sprint["cooldown_s"])
		Actions.BOSS_DEFEATED:
			state["progress"]["bosses_beaten"] = int(state["progress"]["bosses_beaten"]) + 1
		Actions.LEVEL_STARTED:
			run["biome"] = action["biome"]
			run["level_index"] = int(action["level_index"])
			run["level_seed"] = int(action["level_seed"])

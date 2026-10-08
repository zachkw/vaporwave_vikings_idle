## Action types and constructors. An action says what happened, never what to
## change. See docs/technical/state-store-spec.md.
class_name Actions
extends RefCounted

# Run
const TIME_ADVANCED := "TIME_ADVANCED"
const DISTANCE_TRAVELLED := "DISTANCE_TRAVELLED"
const COIN_COLLECTED := "COIN_COLLECTED"
const ENEMY_KILLED := "ENEMY_KILLED"
const PLAYER_DAMAGED := "PLAYER_DAMAGED"
const PLAYER_DIED := "PLAYER_DIED"
const PIT_FALLEN := "PIT_FALLEN"
const SPRINT_USED := "SPRINT_USED"
const BOSS_DEFEATED := "BOSS_DEFEATED"
const LEVEL_STARTED := "LEVEL_STARTED"
# Discovery and effects
const COURSE_ENTERED := "COURSE_ENTERED"
const COURSE_FAILED := "COURSE_FAILED"
const COURSE_COMPLETED := "COURSE_COMPLETED"
const INGREDIENT_EATEN := "INGREDIENT_EATEN"
# Shop
const GEAR_LEVEL_BOUGHT := "GEAR_LEVEL_BOUGHT"
# System
const STATE_LOADED := "STATE_LOADED"
const CHECKPOINT_REACHED := "CHECKPOINT_REACHED"
const SYNC_ACCEPTED := "SYNC_ACCEPTED"
const SYNC_TRIMMED := "SYNC_TRIMMED"
const SYNC_REJECTED := "SYNC_REJECTED"


static func time_advanced(seconds: float) -> Dictionary:
	return {"type": TIME_ADVANCED, "seconds": seconds}


static func distance_travelled(metres: float) -> Dictionary:
	return {"type": DISTANCE_TRAVELLED, "metres": metres}


static func coin_collected(kind: String = "gold", count: int = 1, from_sky: bool = false) -> Dictionary:
	return {"type": COIN_COLLECTED, "kind": kind, "count": count, "from_sky": from_sky}


static func enemy_killed(enemy_id: String, role: String, dimension: String = "", crit: bool = false) -> Dictionary:
	return {"type": ENEMY_KILLED, "enemy_id": enemy_id, "role": role, "dimension": dimension, "crit": crit}


static func player_damaged(amount: float, source_role: String) -> Dictionary:
	return {"type": PLAYER_DAMAGED, "amount": amount, "source_role": source_role}


static func player_died(cause: String) -> Dictionary:
	return {"type": PLAYER_DIED, "cause": cause}


static func pit_fallen() -> Dictionary:
	return {"type": PIT_FALLEN}


static func sprint_used() -> Dictionary:
	return {"type": SPRINT_USED}


static func boss_defeated(boss_id: String) -> Dictionary:
	return {"type": BOSS_DEFEATED, "boss_id": boss_id}


static func level_started(biome: String, level_index: int, level_seed: int) -> Dictionary:
	return {"type": LEVEL_STARTED, "biome": biome, "level_index": level_index, "level_seed": level_seed}


static func course_entered(course_id: String) -> Dictionary:
	return {"type": COURSE_ENTERED, "course_id": course_id}


static func course_failed(course_id: String) -> Dictionary:
	return {"type": COURSE_FAILED, "course_id": course_id}


static func course_completed(course_id: String, reward: Dictionary) -> Dictionary:
	return {"type": COURSE_COMPLETED, "course_id": course_id, "reward": reward}


static func ingredient_eaten(ingredient_id: String, form: String = "raw", source: String = "box") -> Dictionary:
	return {"type": INGREDIENT_EATEN, "ingredient_id": ingredient_id, "form": form, "source": source}


static func gear_level_bought(slot: String, count: int = 1) -> Dictionary:
	return {"type": GEAR_LEVEL_BOUGHT, "slot": slot, "count": count}


static func state_loaded(state: Dictionary) -> Dictionary:
	return {"type": STATE_LOADED, "state": state}


static func checkpoint_reached(reason: String) -> Dictionary:
	return {"type": CHECKPOINT_REACHED, "reason": reason}


static func sync_accepted(rev: int, up_to_seq: int, server_time: String = "") -> Dictionary:
	return {"type": SYNC_ACCEPTED, "rev": rev, "up_to_seq": up_to_seq, "server_time": server_time}


## trims: [{ "seq": int, "gold_removed": float }]
static func sync_trimmed(rev: int, up_to_seq: int, trims: Array, server_time: String = "") -> Dictionary:
	return {"type": SYNC_TRIMMED, "rev": rev, "up_to_seq": up_to_seq, "trims": trims, "server_time": server_time}


## The server's copy replaces the device state (after migration, like a load).
static func sync_rejected(server_state: Dictionary, rev: int, code: String = "") -> Dictionary:
	return {"type": SYNC_REJECTED, "state": server_state, "rev": rev, "code": code}

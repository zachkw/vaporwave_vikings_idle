## The single place player state lives. Systems dispatch actions; reducers
## change state; UI reads through Selectors and listens to `changed`.
## See docs/technical/state-store-spec.md.
extends Node

signal changed(action: Dictionary)
signal checkpoint(reason: String)

var state: Dictionary = {}
## Actions since the last checkpoint, for the batch builder later.
var action_log: Array = []



func _ready() -> void:
	if state.is_empty():
		reset()


func reset() -> void:
	state = InitialState.make()
	action_log.clear()
	changed.emit({"type": "RESET"})


func dispatch(action: Dictionary) -> void:
	assert(action.has("type"), "action needs a type")
	if action["type"] == Actions.STATE_LOADED:
		state = action["state"]
		action_log.clear()
		changed.emit(action)
		return
	# Order matters: the gear reducer validates a purchase and stamps its cost,
	# then the wallet reducer deducts it.
	GearReducer.reduce(state, action)
	WalletReducer.reduce(state, action)
	RunReducer.reduce(state, action)
	EffectsReducer.reduce(state, action)
	if action["type"] != Actions.TIME_ADVANCED and action["type"] != Actions.DISTANCE_TRAVELLED:
		action_log.append(action)
	changed.emit(action)
	if action["type"] == Actions.CHECKPOINT_REACHED:
		action_log.clear()
		checkpoint.emit(action["reason"])


## Convenience selectors so callers can write Store.gold() etc.
func gold() -> float: return Selectors.gold(state)
func gold_per_metre() -> float: return Selectors.gold_per_metre(state)
func next_level_cost(slot: String) -> float: return Selectors.next_level_cost(state, slot)
func can_afford(slot: String) -> bool: return Selectors.can_afford(state, slot)
func gear_level(slot: String) -> int: return Selectors.gear_level(state, slot)
func is_unlocked(slot: String) -> bool: return Selectors.is_unlocked(state, slot)
func next_slot_unlock() -> Dictionary: return Selectors.next_slot_unlock(state)
func has_sprint() -> bool: return Selectors.has_sprint(state)
func run_speed_mult() -> float: return Selectors.run_speed_mult(state)
func health() -> float: return float(state["run"]["health"])
func max_health() -> float: return Selectors.max_health(state)
func damage() -> float: return Selectors.damage(state)
func defence() -> float: return Selectors.defence(state)
func sprint_cooldown() -> float: return float(state["run"]["sprint_cooldown_s"])

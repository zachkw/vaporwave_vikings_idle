## The single place player state lives. Systems dispatch actions; reducers
## change state; UI reads through Selectors and listens to `changed`.
## See docs/technical/state-store-spec.md.
extends Node

signal changed(action: Dictionary)
signal checkpoint(reason: String)

var state: Dictionary = {}
## Set to print every closed batch to the console (first-build step 5).
var log_batches := false
## A burst of purchases closes a batch a few seconds after the last tap.
const PURCHASE_CHECKPOINT_DELAY_S := 3.0
var _purchase_timer: Timer



func _ready() -> void:
	_purchase_timer = Timer.new()
	_purchase_timer.one_shot = true
	_purchase_timer.wait_time = PURCHASE_CHECKPOINT_DELAY_S
	_purchase_timer.timeout.connect(func() -> void: dispatch(Actions.checkpoint_reached("purchases")))
	add_child(_purchase_timer)
	if state.is_empty():
		reset()


func reset() -> void:
	state = InitialState.make()
	state["meta"]["device_id"] = device_id()
	changed.emit({"type": "RESET"})


func dispatch(action: Dictionary) -> void:
	assert(action.has("type"), "action needs a type")
	if action["type"] == Actions.STATE_LOADED or action["type"] == Actions.SYNC_REJECTED:
		state = action["state"]
		state["meta"]["device_id"] = device_id()
		if action["type"] == Actions.SYNC_REJECTED:
			# The server copy is now the truth: nothing queued is valid any more.
			state["sync"]["rev"] = int(action["rev"])
			state["sync"]["queued_batches"] = []
			state["sync"]["open"] = SyncReducer.empty_batch()
			state["sync"]["baseline"] = SyncReducer.snapshot(state)
		changed.emit(action)
		return
	# Order matters: the gear reducer validates a purchase and stamps its cost,
	# then the wallet reducer deducts it.
	GearReducer.reduce(state, action)
	WalletReducer.reduce(state, action)
	RunReducer.reduce(state, action)
	EffectsReducer.reduce(state, action)
	var queued_before: int = state["sync"]["queued_batches"].size()
	SyncReducer.reduce(state, action)
	if action["type"] == Actions.GEAR_LEVEL_BOUGHT and action.get("_applied", false):
		_purchase_timer.start()
	changed.emit(action)
	if action["type"] == Actions.CHECKPOINT_REACHED:
		if log_batches and state["sync"]["queued_batches"].size() > queued_before:
			print("[batch] %s %s" % [action["reason"], JSON.stringify(state["sync"]["queued_batches"][-1])])
		checkpoint.emit(action["reason"])


## A stable id for this device, kept in its own file so it survives a deleted save.
func device_id() -> String:
	const PATH := "user://device_id"
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		var id := f.get_as_text().strip_edges()
		if id != "":
			return id
	var fresh := "dev-" + ("%08x%08x" % [randi(), randi()])
	var out := FileAccess.open(PATH, FileAccess.WRITE)
	if out != null:
		out.store_string(fresh)
	return fresh


func queued_batches() -> Array: return state["sync"]["queued_batches"]
func open_batch() -> Dictionary: return state["sync"]["open"]


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

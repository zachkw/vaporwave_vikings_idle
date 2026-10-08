## sync slice: the batch builder and queue. Between two checkpoints the open
## batch collects the *difference* (gold by source, spend, counts, play time);
## a checkpoint closes it against the baseline snapshot and queues it. The
## server answers move the revision on. See docs/technical/state-store-spec.md
## ("What gets sent") and docs/technical/validation.md.
class_name SyncReducer
extends RefCounted

const GOLD_SOURCES := ["distance", "coins", "basic", "elite", "boss", "dimensional", "course"]
## Queued batches older than this many are merged into blocks of up to an
## hour of play, so a long offline spell does not grow the queue without end.
const MERGE_AFTER := 24
const MERGE_BLOCK_S := 3600.0


static func empty_batch() -> Dictionary:
	var earned := {}
	for s in GOLD_SOURCES:
		earned[s] = 0.0
	return {
		"seq": 0,
		"play_seconds": 0.0,
		"away_seconds": 0.0,
		"gold_earned": earned,
		"gold_spent": 0.0,
		"counts": {"metres": 0, "coins": 0, "kills_basic": 0, "kills_elite": 0, "kills_boss": 0,
			"kills_dimensional": 0, "deaths": 0, "pit_falls": 0},
		"changes": {"gear": {}, "unlocks": {"gear_slots": [], "ingredients": []}, "progress": {},
			"courses_completed": [], "effects_started": []},
	}


## What the batch's changes are measured against: the compact parts of the
## state that purchases and progress move.
static func snapshot(state: Dictionary) -> Dictionary:
	var gear := {}
	var slots: Array = []
	for slot in state["gear"]:
		gear[slot] = int(state["gear"][slot]["level"])
		if state["gear"][slot]["unlocked"]:
			slots.append(slot)
	return {
		"gear": gear,
		"gear_slots": slots,
		"level": int(state["run"]["level_index"]),
		"courses": state["unlocks"]["courses"].duplicate(),
		"ingredients": state["unlocks"]["ingredients"].duplicate(),
	}


static func fresh_slice(state: Dictionary) -> Dictionary:
	return {
		"rev": 0,
		"last_seq": 0,
		"baseline": snapshot(state),
		"open": empty_batch(),
		"queued_batches": [],
		"last_sync_at": "",
	}


## Called by the wallet reducer as it pays or takes gold.
static func note_earned(state: Dictionary, source: String, amount: float) -> void:
	var earned: Dictionary = state["sync"]["open"]["gold_earned"]
	earned[source] = float(earned.get(source, 0.0)) + amount


static func note_spent(state: Dictionary, amount: float) -> void:
	var open: Dictionary = state["sync"]["open"]
	open["gold_spent"] = float(open["gold_spent"]) + amount


static func reduce(state: Dictionary, action: Dictionary) -> void:
	var sync: Dictionary = state["sync"]
	var open: Dictionary = sync["open"]
	var counts: Dictionary = open["counts"]
	match action["type"]:
		Actions.TIME_ADVANCED:
			open["play_seconds"] = float(open["play_seconds"]) + float(action["seconds"])
		Actions.DISTANCE_TRAVELLED:
			counts["metres"] = int(counts["metres"]) + int(action["metres"])
		Actions.COIN_COLLECTED:
			counts["coins"] = int(counts["coins"]) + int(action["count"])
		Actions.ENEMY_KILLED:
			var key := "kills_dimensional" if action.get("dimension", "") != "" else "kills_%s" % action["role"]
			counts[key] = int(counts.get(key, 0)) + 1
		Actions.PLAYER_DIED:
			counts["deaths"] = int(counts["deaths"]) + 1
		Actions.PIT_FALLEN:
			counts["pit_falls"] = int(counts["pit_falls"]) + 1
		Actions.INGREDIENT_EATEN:
			open["changes"]["effects_started"].append({"ingredient": action["ingredient_id"], "form": action["form"]})
		Actions.CHECKPOINT_REACHED:
			_close(state)
		Actions.SYNC_ACCEPTED, Actions.SYNC_TRIMMED:
			_drop_through(sync, int(action["up_to_seq"]))
			sync["rev"] = int(action["rev"])
			sync["last_sync_at"] = String(action.get("server_time", ""))


## Close the open batch against the baseline and queue it. An empty batch
## (no play, no purchases, no changes) is skipped so idle checkpoints cost nothing.
static func _close(state: Dictionary) -> void:
	var sync: Dictionary = state["sync"]
	var open: Dictionary = sync["open"]
	var now := snapshot(state)
	var base: Dictionary = sync["baseline"] if not sync["baseline"].is_empty() else now
	var changes: Dictionary = open["changes"]
	for slot in now["gear"]:
		var from := int(base["gear"].get(slot, 0))
		var to := int(now["gear"][slot])
		if from != to:
			changes["gear"][slot] = [from, to]
	for slot in now["gear_slots"]:
		if not base["gear_slots"].has(slot):
			changes["unlocks"]["gear_slots"].append(slot)
	for ing in now["ingredients"]:
		if not base["ingredients"].has(ing):
			changes["unlocks"]["ingredients"].append(ing)
	for c in now["courses"]:
		if not base["courses"].has(c):
			changes["courses_completed"].append(c)
	if int(base["level"]) != int(now["level"]):
		changes["progress"]["level"] = [int(base["level"]), int(now["level"])]
	sync["baseline"] = now
	if is_empty_batch(open):
		sync["open"] = empty_batch()
		return
	sync["last_seq"] = int(sync["last_seq"]) + 1
	open["seq"] = sync["last_seq"]
	sync["queued_batches"].append(open)
	sync["open"] = empty_batch()
	_merge_old(sync["queued_batches"])


static func is_empty_batch(b: Dictionary) -> bool:
	if float(b["play_seconds"]) > 0.0 or float(b["away_seconds"]) > 0.0 or float(b["gold_spent"]) > 0.0:
		return false
	for s in b["gold_earned"]:
		if float(b["gold_earned"][s]) > 0.0:
			return false
	var ch: Dictionary = b["changes"]
	return ch["gear"].is_empty() and ch["unlocks"]["gear_slots"].is_empty() and ch["unlocks"]["ingredients"].is_empty() \
		and ch["progress"].is_empty() and ch["courses_completed"].is_empty() and ch["effects_started"].is_empty()


## Merge the oldest batches into blocks of up to an hour while the queue is long.
## A merged batch keeps the last member's `seq` and records `seq_from`, so the
## server still sees an unbroken sequence.
static func _merge_old(queue: Array) -> void:
	while queue.size() > MERGE_AFTER:
		var a: Dictionary = queue[0]
		var b: Dictionary = queue[1]
		if float(a["play_seconds"]) + float(b["play_seconds"]) > MERGE_BLOCK_S:
			# The oldest block is full; try the next pair instead, else stop.
			var merged_any := false
			for i in range(1, queue.size() - 1):
				if float(queue[i]["play_seconds"]) + float(queue[i + 1]["play_seconds"]) <= MERGE_BLOCK_S:
					queue[i] = merge(queue[i], queue[i + 1])
					queue.remove_at(i + 1)
					merged_any = true
					break
			if not merged_any:
				return
		else:
			queue[0] = merge(a, b)
			queue.remove_at(1)


static func merge(a: Dictionary, b: Dictionary) -> Dictionary:
	var m := empty_batch()
	m["seq"] = int(b["seq"])
	m["seq_from"] = int(a.get("seq_from", a["seq"]))
	m["play_seconds"] = float(a["play_seconds"]) + float(b["play_seconds"])
	m["away_seconds"] = float(a["away_seconds"]) + float(b["away_seconds"])
	m["gold_spent"] = float(a["gold_spent"]) + float(b["gold_spent"])
	for s in m["gold_earned"]:
		m["gold_earned"][s] = float(a["gold_earned"].get(s, 0.0)) + float(b["gold_earned"].get(s, 0.0))
	for k in m["counts"]:
		m["counts"][k] = int(a["counts"].get(k, 0)) + int(b["counts"].get(k, 0))
	var ch: Dictionary = m["changes"]
	for slot in a["changes"]["gear"]:
		ch["gear"][slot] = a["changes"]["gear"][slot].duplicate()
	for slot in b["changes"]["gear"]:
		if ch["gear"].has(slot):
			ch["gear"][slot][1] = b["changes"]["gear"][slot][1]
		else:
			ch["gear"][slot] = b["changes"]["gear"][slot].duplicate()
	for key in ["gear_slots", "ingredients"]:
		ch["unlocks"][key] = a["changes"]["unlocks"][key] + b["changes"]["unlocks"][key]
	if a["changes"]["progress"].has("level") or b["changes"]["progress"].has("level"):
		var from: int = a["changes"]["progress"].get("level", b["changes"]["progress"].get("level"))[0]
		var to: int = b["changes"]["progress"].get("level", a["changes"]["progress"].get("level"))[1]
		ch["progress"]["level"] = [from, to]
	ch["courses_completed"] = a["changes"]["courses_completed"] + b["changes"]["courses_completed"]
	ch["effects_started"] = a["changes"]["effects_started"] + b["changes"]["effects_started"]
	return m


static func _drop_through(sync: Dictionary, up_to_seq: int) -> void:
	var kept: Array = []
	for b in sync["queued_batches"]:
		if int(b["seq"]) > up_to_seq:
			kept.append(b)
	sync["queued_batches"] = kept


## The request body for POST /api/v1/sync: everything queued, in order.
static func build_request(state: Dictionary, request_id: String) -> Dictionary:
	return {
		"request_id": request_id,
		"device_id": String(state["meta"]["device_id"]),
		"base_rev": int(state["sync"]["rev"]),
		"content_version": String(state["meta"]["content_version"]),
		"batches": state["sync"]["queued_batches"].duplicate(true),
	}

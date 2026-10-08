## Chains hand-made segments into surface levels.
## Pure logic: no scene access, deterministic for a given seed.
## See docs/game-systems/level-builder.md.
class_name LevelBuilder
extends RefCounted

## Seam rule: the next entry row may be up to 1 row higher or 3 rows lower
## than the current exit row (proposal L3).
const MAX_STEP_UP := 1
const MAX_STEP_DOWN := 3
const MIN_ROW := 2
const MAX_ROW := 10
const MAX_REBUILD_TRIES := 5

var library: Array = []
var _by_id: Dictionary = {}


func _init(segment_library: Array = []) -> void:
	set_library(segment_library)


func set_library(segment_library: Array) -> void:
	library = segment_library
	_by_id.clear()
	for seg in library:
		_by_id[seg["id"]] = seg


func get_segment(id: String) -> Dictionary:
	return _by_id.get(id, {})


static func load_library(path: String) -> Array:
	var data: Variant = Content.load_json(path)
	return data if data is Array else []


static func seam_ok(exit_row: int, entry_row: int) -> bool:
	var diff := entry_row - exit_row
	return diff <= MAX_STEP_UP and diff >= -MAX_STEP_DOWN


static func derive_seed(a: int, b: int) -> int:
	return hash([a, b])


## Builds a whole level. Returns { ids, length, tries, fallback }.
func build_level(level_seed: int, target_blocks: int, start_row: int = 2) -> Dictionary:
	for attempt in MAX_REBUILD_TRIES:
		var seed := level_seed if attempt == 0 else derive_seed(level_seed, attempt)
		var ids := _chain(seed, target_blocks, start_row, [], true)
		if check(ids, target_blocks, true):
			return {"ids": ids, "length": length_of(ids), "tries": attempt + 1, "fallback": false}
	var safe := _fallback(target_blocks, start_row)
	return {"ids": safe, "length": length_of(safe), "tries": MAX_REBUILD_TRIES, "fallback": true}


## Extends a level after a pit fall: keeps `kept` ids, then plans a full
## level's length from the last kept segment, as if the level restarted.
func extend_level(kept: Array, extension_seed: int, target_blocks: int) -> Dictionary:
	var start_row := MIN_ROW
	if not kept.is_empty():
		start_row = int(get_segment(kept[-1])["exit_row"])
	for attempt in MAX_REBUILD_TRIES:
		var seed := extension_seed if attempt == 0 else derive_seed(extension_seed, attempt)
		var tail := _chain(seed, target_blocks, start_row, kept, false)
		if check(tail, target_blocks, false) and _join_ok(kept, tail):
			return {"ids": kept + tail, "added": tail, "tries": attempt + 1, "fallback": false}
	var safe := _fallback(target_blocks, start_row, false)
	return {"ids": kept + safe, "added": safe, "tries": MAX_REBUILD_TRIES, "fallback": true}


func length_of(ids: Array) -> int:
	var total := 0
	for id in ids:
		total += int(get_segment(id)["width"])
	return total


## Pass 3: checks a planned list of ids.
func check(ids: Array, target_blocks: int, needs_start: bool) -> bool:
	if ids.is_empty():
		return false
	var length := length_of(ids)
	if length < target_blocks * 0.9 or length > target_blocks * 1.1:
		return false
	if needs_start and not get_segment(ids[0])["roles"].has("start"):
		return false
	for i in range(1, ids.size()):
		if not seam_ok(int(get_segment(ids[i - 1])["exit_row"]), int(get_segment(ids[i])["entry_row"])):
			return false
	for id in ids:
		var seg := get_segment(id)
		if int(seg["entry_row"]) < MIN_ROW or int(seg["exit_row"]) > MAX_ROW:
			return false
	return true


## Pass 2: chain segments by weight, seam rule and cooldown.
func _chain(seed: int, target_blocks: int, start_row: int, history: Array, needs_start: bool) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var ids: Array = []
	var recent: Array = history.duplicate()
	var row := start_row
	var length := 0
	while length < target_blocks:
		var need_role := "start" if needs_start and ids.is_empty() else ""
		var candidates := _candidates(row, recent, need_role)
		if candidates.is_empty():
			candidates = _candidates(row, [], need_role)  # relax cooldown before giving up
		if candidates.is_empty():
			push_warning("LevelBuilder: no segment fits after row %d" % row)
			break
		var pick: Dictionary = _weighted_pick(rng, candidates)
		ids.append(pick["id"])
		recent.append(pick["id"])
		row = int(pick["exit_row"])
		length += int(pick["width"])
	return ids


func _candidates(row: int, recent: Array, role: String) -> Array:
	var out: Array = []
	for seg in library:
		if not seam_ok(row, int(seg["entry_row"])):
			continue
		if role != "" and not seg["roles"].has(role):
			continue
		var cooldown := int(seg.get("cooldown", 0))
		if cooldown > 0 and recent.slice(max(0, recent.size() - cooldown)).has(seg["id"]):
			continue
		var exit_row := int(seg["exit_row"])
		if exit_row < MIN_ROW or exit_row > MAX_ROW:
			continue
		out.append(seg)
	return out


func _weighted_pick(rng: RandomNumberGenerator, candidates: Array) -> Dictionary:
	var total := 0.0
	for seg in candidates:
		total += float(seg.get("weight", 1.0))
	var roll := rng.randf() * total
	for seg in candidates:
		roll -= float(seg.get("weight", 1.0))
		if roll <= 0.0:
			return seg
	return candidates[-1]


func _join_ok(kept: Array, tail: Array) -> bool:
	if kept.is_empty() or tail.is_empty():
		return true
	return seam_ok(int(get_segment(kept[-1])["exit_row"]), int(get_segment(tail[0])["entry_row"]))


## Safe fixed sequence: repeat the first plain run segment that fits.
func _fallback(target_blocks: int, start_row: int, needs_start: bool = true) -> Array:
	push_warning("LevelBuilder: using fallback sequence")
	var ids: Array = []
	var length := 0
	for seg in library:
		var roles: Array = seg["roles"]
		if (roles.has("run") or roles.has("start")) and seam_ok(start_row, int(seg["entry_row"])) and int(seg["exit_row"]) == int(seg["entry_row"]):
			while length < target_blocks:
				ids.append(seg["id"])
				length += int(seg["width"])
			break
	return ids

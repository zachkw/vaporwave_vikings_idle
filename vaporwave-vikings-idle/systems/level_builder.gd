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


## Builds a whole level: start, body, optional cave entrance in the middle
## half, then boss approach and boss arena. Returns { ids, length, tries, fallback }.
func build_level(level_seed: int, target_blocks: int, start_row: int = 2, cave_due: bool = false) -> Dictionary:
	for attempt in MAX_REBUILD_TRIES:
		var seed := level_seed if attempt == 0 else derive_seed(level_seed, attempt)
		var ids := _chain(seed, target_blocks, start_row, [], true, cave_due, true)
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
		var tail := _chain(seed, target_blocks, start_row, kept, false, false, true)
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
	if ids.size() >= 2 and has_role("boss_arena"):
		if not get_segment(ids[-1])["roles"].has("boss_arena") or not get_segment(ids[-2])["roles"].has("boss_approach"):
			return false
	for i in range(1, ids.size()):
		if not seam_ok(int(get_segment(ids[i - 1])["exit_row"]), int(get_segment(ids[i])["entry_row"])):
			return false
	for id in ids:
		var seg := get_segment(id)
		if int(seg["entry_row"]) < MIN_ROW or int(seg["exit_row"]) > MAX_ROW:
			return false
	return true


func has_role(role: String) -> bool:
	for seg in library:
		if seg["roles"].has(role):
			return true
	return false


## Pass 2: chain segments by weight, seam rule and cooldown. Special roles
## (start, cave_entrance, boss_approach, boss_arena) are placed by rule and
## never picked at random.
func _chain(seed: int, target_blocks: int, start_row: int, history: Array, needs_start: bool, cave_due: bool = false, boss: bool = true) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var ids: Array = []
	var recent: Array = history.duplicate()
	var row := start_row
	var length := 0
	var tail_blocks := 0
	if boss and has_role("boss_arena"):
		tail_blocks = _role_width("boss_approach") + _role_width("boss_arena")
	var cave_at := -1
	if cave_due and has_role("cave_entrance"):
		cave_at = int(rng.randf_range(0.3, 0.6) * (target_blocks - tail_blocks))
	var cave_placed := false
	while length < target_blocks - tail_blocks:
		var need_role := ""
		if needs_start and ids.is_empty():
			need_role = "start"
		elif cave_at >= 0 and not cave_placed and length >= cave_at:
			need_role = "cave_entrance"
			cave_placed = true
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
	if tail_blocks > 0:
		for role in ["boss_approach", "boss_arena"]:
			var tail_candidates := _candidates(row, [], role)
			if tail_candidates.is_empty():
				push_warning("LevelBuilder: no %s fits after row %d" % [role, row])
				break
			var pick: Dictionary = _weighted_pick(rng, tail_candidates)
			ids.append(pick["id"])
			row = int(pick["exit_row"])
	return ids


func _role_width(role: String) -> int:
	for seg in library:
		if seg["roles"].has(role):
			return int(seg["width"])
	return 0


const SPECIAL_ROLES := ["start", "cave_entrance", "boss_approach", "boss_arena"]


func _candidates(row: int, recent: Array, role: String) -> Array:
	var out: Array = []
	for seg in library:
		if not seam_ok(row, int(seg["entry_row"])):
			continue
		if role != "" and not seg["roles"].has(role):
			continue
		if role == "":
			# Segments that only have special roles are placed by rule, never at random.
			var only_special := true
			for r in seg["roles"]:
				if not SPECIAL_ROLES.has(r):
					only_special = false
			if only_special:
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
	var tail_blocks := _role_width("boss_approach") + _role_width("boss_arena") if has_role("boss_arena") else 0
	for seg in library:
		var roles: Array = seg["roles"]
		if (roles.has("run") or roles.has("start")) and seam_ok(start_row, int(seg["entry_row"])) and int(seg["exit_row"]) == int(seg["entry_row"]):
			while length < target_blocks - tail_blocks:
				ids.append(seg["id"])
				length += int(seg["width"])
			break
	if tail_blocks > 0:
		for role in ["boss_approach", "boss_arena"]:
			for seg in library:
				if seg["roles"].has(role):
					ids.append(seg["id"])
					break
	return ids

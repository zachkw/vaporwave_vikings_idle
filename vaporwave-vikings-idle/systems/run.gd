## The surface run: builds levels with LevelBuilder, streams segments in and
## out around the Viking, handles drop-ins and level extension after pit falls,
## and starts the next level at the end. See docs/game-systems/level-flow.md.
extends Node2D

const LIBRARY_PATH := "res://content/segments/proof.json"
const STREAM_AHEAD_PX := 2400.0
const STREAM_BEHIND_PX := 1200.0
const CAMERA_LEAD_PX := 300.0

@export var base_seed := 12345

var builder: LevelBuilder
var block_px := 32.0
var level_length_blocks := 1500

## The track: every planned segment in world order.
## Each entry: { id, x, level, node (or null) }
var track: Array = []
var level_index := 0
var level_seed := 0
var level_start := 0          # index in track where the current level begins
var level_end_x := 0.0
var extension_counter := 0
var pit_falls := 0
var levels_completed := 0

@onready var viking: Viking = $Viking
@onready var camera: Camera2D = $Camera
@onready var segments_root: Node2D = $Segments
@onready var hud_label: Label = $HUD/Info


func _ready() -> void:
	var physics: Dictionary = Content.load_json("res://content/viking.json")["physics"]
	block_px = float(physics["block_px"])
	level_length_blocks = int(Content.load_json("res://content/economy.json")["level_length_m"])
	builder = LevelBuilder.new(LevelBuilder.load_library(LIBRARY_PATH))
	_start_level(0, 0.0)
	viking.global_position = Vector2(4.0 * block_px, -2.0 * block_px)
	viking.pit_fallen.connect(_on_pit_fallen)
	_update_stream()


func _physics_process(_delta: float) -> void:
	camera.global_position = Vector2(viking.global_position.x + CAMERA_LEAD_PX, -7.5 * block_px)
	if viking.global_position.x > level_end_x:
		levels_completed += 1
		_start_level(level_index + 1, level_end_x)
	_update_stream()
	_update_hud()


func _start_level(index: int, start_x: float) -> void:
	level_index = index
	level_seed = LevelBuilder.derive_seed(base_seed, index)
	extension_counter = 0
	var result := builder.build_level(level_seed, level_length_blocks)
	# Forget earlier levels' segments that are no longer on screen.
	var still_loaded: Array = []
	for entry in track:
		if entry["node"] != null:
			still_loaded.append(entry)
	track = still_loaded
	level_start = track.size()
	var x := start_x
	for id in result["ids"]:
		track.append({"id": id, "x": x, "level": index, "node": null})
		x += float(builder.get_segment(id)["width"]) * block_px
	level_end_x = x


func _on_pit_fallen(world_x: float) -> void:
	pit_falls += 1
	var landing_x := _pit_exit_x(world_x) + block_px
	var top_y := -float(Content.load_json("res://content/viking.json")["physics"]["drop_in_height_row"]) * block_px
	viking.drop_in(landing_x, top_y)
	_extend_level()


## World x just past the pit the Viking fell into.
func _pit_exit_x(world_x: float) -> float:
	for entry in track:
		var seg := builder.get_segment(entry["id"])
		var x0: float = entry["x"]
		var x1 := x0 + float(seg["width"]) * block_px
		if world_x < x0 - block_px or world_x > x1 + block_px:
			continue
		var best := world_x
		for pit in seg.get("pits", []):
			var pit_start := x0 + float(pit[0]) * block_px
			var pit_end := x0 + float(pit[1]) * block_px
			if world_x >= pit_start - block_px and world_x <= pit_end + block_px:
				return pit_end
			if pit_end > best:
				best = pit_end
		return best
	return world_x


## After a pit fall: keep what is already streamed in, re-plan a full level ahead.
func _extend_level() -> void:
	extension_counter += 1
	var kept_end := level_start
	for i in range(level_start, track.size()):
		if track[i]["node"] != null:
			kept_end = i + 1
	var kept_ids: Array = []
	for i in range(level_start, kept_end):
		kept_ids.append(track[i]["id"])
	# Drop the unstreamed tail of the current level.
	track.resize(kept_end)
	var seed := LevelBuilder.derive_seed(level_seed, extension_counter)
	var result := builder.extend_level(kept_ids, seed, level_length_blocks)
	var x := level_end_from_track()
	for id in result["added"]:
		track.append({"id": id, "x": x, "level": level_index, "node": null})
		x += float(builder.get_segment(id)["width"]) * block_px
	level_end_x = x


func level_end_from_track() -> float:
	if track.is_empty():
		return 0.0
	var last: Dictionary = track[-1]
	return float(last["x"]) + float(builder.get_segment(last["id"])["width"]) * block_px


func _update_stream() -> void:
	var vx := viking.global_position.x
	for entry in track:
		var seg := builder.get_segment(entry["id"])
		var x0: float = entry["x"]
		var x1 := x0 + float(seg["width"]) * block_px
		var wanted := x1 > vx - STREAM_BEHIND_PX and x0 < vx + STREAM_AHEAD_PX
		if wanted and entry["node"] == null:
			var node: Node2D = load(seg["scene"]).instantiate()
			node.position = Vector2(x0, 0)
			segments_root.add_child(node)
			entry["node"] = node
		elif not wanted and entry["node"] != null:
			entry["node"].queue_free()
			entry["node"] = null


func distance_to_level_end_m() -> float:
	return max(0.0, (level_end_x - viking.global_position.x) / block_px)


func current_segment_id() -> String:
	var vx := viking.global_position.x
	for entry in track:
		var w := float(builder.get_segment(entry["id"])["width"]) * block_px
		if vx >= entry["x"] and vx < entry["x"] + w:
			return entry["id"]
	return "-"


func _update_hud() -> void:
	hud_label.text = "Level %d   segment %s\nTo level end: %d m   Pit falls: %d   Auto-jumps: %d\nTap or Space to jump. Jump early before a pit to fall in." % [
		level_index + 1, current_segment_id(), int(distance_to_level_end_m()), pit_falls, viking.auto_jumps]

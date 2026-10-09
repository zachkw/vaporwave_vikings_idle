## The surface run: builds levels, streams and fills segments, handles the
## boss, drop-ins, death, the level extension after pit falls, courses and
## the next level. See docs/game-systems/level-flow.md.
extends Node2D

const STREAM_AHEAD_PX := 2400.0
const STREAM_BEHIND_PX := 1200.0
const SEGMENT_HEIGHT_BLOCKS := 15.0
## Keep the world 48 screen pixels higher while the CanvasLayer UI stays fixed.
const WORLD_RAISE_PX := 48.0
## The Viking sits at the far left of the game view, one Viking width from the
## edge, so the player sees as much ground ahead as possible. The sprite is
## about 56 px wide, centred on the body.
const VIKING_WIDTH_PX := 56.0
const COURSE_Y_OFFSET := 6000.0

@export var base_seed := 12345
@export var biome_id := "dark_forest"

var builder: LevelBuilder
var block_px := 32.0
var level_length_blocks := 1500
var biome: Dictionary = {}

## The track: every planned segment in world order. { id, x, level, node }
var track: Array = []
var level_index := 0
var level_seed := 0
var level_start := 0
var level_end_x := 0.0
var extension_counter := 0
var drop_in_counter := 0
var visit_counter := 0
var pit_falls := 0
var levels_completed := 0
var boss: Enemy = null
var boss_beaten := false

## Course state
var course_id := ""
var course_node: Node2D = null
var course_return_x := 0.0

@onready var viking: Viking = $Viking
@onready var camera: Camera2D = $Camera
@onready var segments_root: Node2D = $Segments
@onready var hud: Control = $HUD/Hud
@onready var layout: Layout = $Layout
@onready var menu_panel: Control = $UI/MenuPanel
@onready var sprint_button: Button = $HUD/AbilityStrip/Sprint
@onready var tint: CanvasModulate = $Tint
@onready var course_overlay: Control = $UI/CourseOverlay

var _game_rect := Rect2()
var _metres_accum := 0.0
var _dying := false
var _toast_left := 0.0


func _ready() -> void:
	process_physics_priority = 1
	Store.log_batches = OS.is_debug_build()
	var physics: Dictionary = Content.load_json("res://content/viking.json")["physics"]
	block_px = float(physics["block_px"])
	level_length_blocks = int(Content.load_json("res://content/economy.json")["level_length_m"])
	biome = Spawner.biome_data(biome_id)
	builder = LevelBuilder.new(LevelBuilder.load_library(biome["segment_library"]))
	_start_level(0, 0.0)
	viking.global_position = Vector2(4.0 * block_px, -2.0 * block_px)
	viking.pit_fallen.connect(_on_pit_fallen)
	viking.died.connect(_on_viking_died)
	_update_stream()
	layout.game_rect_changed.connect(_on_game_rect_changed)
	layout.setup($UI, menu_panel, $UI/Dock, $UI/Drawer, $UI/Dim, $HUD/MenuButton)
	menu_panel.close_requested.connect(layout.close_drawer)
	sprint_button.pressed.connect(viking.request_sprint)
	Store.changed.connect(_on_store_changed)
	course_overlay.get_node("%Retry").pressed.connect(_retry_course)
	course_overlay.get_node("%Return").pressed.connect(_leave_course.bind(false))
	course_overlay.visible = false
	_on_store_changed({"type": "INIT"})


func _on_game_rect_changed(rect: Rect2) -> void:
	_game_rect = rect
	var view := layout.view_size()
	var world_h := SEGMENT_HEIGHT_BLOCKS * block_px
	var zoom := rect.size.y / world_h
	camera.zoom = Vector2(zoom, zoom)
	camera.offset = Vector2(0, (view.y * 0.5 - (rect.position.y + rect.size.y * 0.5)) / zoom)
	$HUD/AbilityStrip.position = Vector2(16, rect.size.y - 72)
	$HUD/MenuButton.position = Vector2(view.x - 120, view.y - 56)
	hud.size = Vector2(view.x, rect.size.y)


func _physics_process(delta: float) -> void:
	var half_view_world := layout.view_size().x * 0.5 / camera.zoom.x
	var cam_y := -SEGMENT_HEIGHT_BLOCKS * 0.5 * block_px + WORLD_RAISE_PX / camera.zoom.y + (COURSE_Y_OFFSET if course_node != null else 0.0)
	camera.global_position = Vector2(viking.global_position.x + half_view_world - 1.5 * VIKING_WIDTH_PX, cam_y)
	Store.dispatch(Actions.time_advanced(delta))
	if course_node != null:
		_update_course()
		_update_hud()
		return
	if viking.velocity.x > 0.0:
		_metres_accum += viking.velocity.x * delta / block_px
		if _metres_accum >= 1.0:
			var whole := floorf(_metres_accum)
			Store.dispatch(Actions.distance_travelled(whole))
			_metres_accum -= whole
	_watch_for_blocker()
	if boss_beaten and viking.global_position.x > level_end_x:
		levels_completed += 1
		_start_level(level_index + 1, level_end_x)
		Store.dispatch(Actions.checkpoint_reached("level_end"))
	_update_stream()
	_update_hud()


# ---------------------------------------------------------------- levels

func _start_level(index: int, start_x: float) -> void:
	level_index = index
	level_seed = LevelBuilder.derive_seed(LevelBuilder.derive_seed(base_seed, index), visit_counter)
	extension_counter = 0
	boss = null
	boss_beaten = false
	var cave_due := _course_due() != ""
	var result := builder.build_level(level_seed, level_length_blocks, 2, cave_due)
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
	Store.dispatch(Actions.level_started(biome_id, index, level_seed))


## A brand-new level for the same level number, after dying to the boss.
func _rebuild_level() -> void:
	visit_counter += 1
	for entry in track:
		if entry["node"] != null:
			entry["node"].queue_free()
	track.clear()
	var start_x := viking.global_position.x + 10.0 * block_px
	_start_level(level_index, start_x)
	_update_stream()
	viking.drop_in(start_x + 4.0 * block_px, _drop_in_top_y())
	Store.dispatch(Actions.checkpoint_reached("boss_death"))


## The first uncompleted course for this biome, or "" when none is due.
func _course_due() -> String:
	for c in Content.load_json("res://content/courses.json"):
		if c["biome"] == biome_id and not Selectors.is_course_completed(Store.state, c["id"]):
			return c["id"]
	return ""


# ---------------------------------------------------------- drop-ins

func _drop_in_top_y() -> float:
	return -float(Content.load_json("res://content/viking.json")["physics"]["drop_in_height_row"]) * block_px


func _drop_in_at(world_x: float) -> void:
	drop_in_counter += 1
	var top := _drop_in_top_y()
	Spawner.drop_in_column(segments_root, world_x, top, -2.0 * block_px, biome_id, LevelBuilder.derive_seed(level_seed, 1000 + drop_in_counter), block_px)
	viking.drop_in(world_x, top)


func _on_pit_fallen(world_x: float) -> void:
	if course_node != null:
		_fail_course()
		return
	var entry := _entry_at(world_x)
	if not entry.is_empty() and builder.get_segment(entry["id"]).get("cave_pit") != null:
		var due := _course_due()
		if due != "":
			_enter_course(due, entry)
			return
	pit_falls += 1
	Store.dispatch(Actions.pit_fallen())
	_drop_in_at(_pit_exit_x(world_x) + block_px)
	_extend_level()


func _on_viking_died(cause: String) -> void:
	if _dying:
		return
	_dying = true
	var pause := float(Content.load_json("res://content/viking.json")["death_pause_s"])
	await get_tree().create_timer(pause).timeout
	Store.dispatch(Actions.player_died(cause))
	_dying = false
	if course_node != null:
		_fail_course()
		return
	if cause == "boss":
		_rebuild_level()
		return
	# Death to an elite: drop back in a block ahead and extend the level, like a pit fall.
	_drop_in_at(viking.global_position.x + block_px)
	_extend_level()


func _entry_at(world_x: float) -> Dictionary:
	for entry in track:
		var w := float(builder.get_segment(entry["id"])["width"]) * block_px
		if world_x >= entry["x"] - block_px and world_x <= entry["x"] + w + block_px:
			return entry
	return {}


func _pit_exit_x(world_x: float) -> float:
	var entry := _entry_at(world_x)
	if entry.is_empty():
		return world_x
	var seg := builder.get_segment(entry["id"])
	var x0: float = entry["x"]
	for pit in seg.get("pits", []):
		var pit_start := x0 + float(pit[0]) * block_px
		var pit_end := x0 + float(pit[1]) * block_px
		if world_x >= pit_start - block_px and world_x <= pit_end + block_px:
			return pit_end
	return world_x


func _extend_level() -> void:
	extension_counter += 1
	var kept_end := level_start
	for i in range(level_start, track.size()):
		if track[i]["node"] != null:
			kept_end = i + 1
	var kept_ids: Array = []
	for i in range(level_start, kept_end):
		kept_ids.append(track[i]["id"])
	# Anything already streamed that was the boss tail is discarded too.
	track.resize(kept_end)
	boss = null
	boss_beaten = false
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


# ---------------------------------------------------------- streaming

func _update_stream() -> void:
	var vx := viking.global_position.x
	for i in track.size():
		var entry: Dictionary = track[i]
		var seg := builder.get_segment(entry["id"])
		var x0: float = entry["x"]
		var x1 := x0 + float(seg["width"]) * block_px
		var wanted := x1 > vx - STREAM_BEHIND_PX and x0 < vx + STREAM_AHEAD_PX
		if wanted and entry["node"] == null:
			var node: Node2D = load(seg["scene"]).instantiate()
			node.position = Vector2(x0, 0)
			segments_root.add_child(node)
			entry["node"] = node
			Spawner.fill(node, seg, biome_id, level_seed, i + 100 * extension_counter, block_px)
			if seg.get("flags", []).has("boss_arena"):
				_bind_boss(node)
		elif not wanted and entry["node"] != null:
			entry["node"].queue_free()
			entry["node"] = null


func _bind_boss(arena: Node2D) -> void:
	for child in arena.get_node("Spawned").get_children():
		if child is Enemy and child.role == "boss":
			boss = child
			boss.died.connect(func(_e: Enemy) -> void:
				boss_beaten = true
				Store.dispatch(Actions.boss_defeated(boss.data["id"])))


## Elites and bosses stop the Viking when he reaches their stop line.
func _watch_for_blocker() -> void:
	if viking.blocker != null and is_instance_valid(viking.blocker):
		if viking.blocker.role == "boss" and viking.global_position.x >= viking.blocker.stop_line_x() - 2.0 * block_px:
			_check_signature(viking.blocker)
		return
	var vx := viking.global_position.x
	var nearest: Enemy = null
	var best := INF
	for entry in track:
		if entry["node"] == null:
			continue
		var spawned: Node = entry["node"].get_node_or_null("Spawned")
		if spawned == null:
			continue
		for child in spawned.get_children():
			if child is Enemy and (child.role == "elite" or child.role == "boss") and child.health > 0.0:
				var d: float = child.stop_line_x() - vx
				if d > -block_px and d < best:
					best = d
					nearest = child
	if nearest != null:
		viking.blocker = nearest


## If the Viking is far too weak the boss kills him at once with its signature move.
func _check_signature(the_boss: Enemy) -> void:
	if the_boss.get_meta("signature_checked", false):
		return
	the_boss.set_meta("signature_checked", true)
	var dps := Store.damage() * viking.attacks_per_second
	var time_to_kill: float = the_boss.health / max(dps, 0.001)
	var taken := float(the_boss.data["attack"]) * 100.0 / (100.0 + Store.defence())
	var time_to_die: float = Store.health() / max(taken / float(the_boss.data["attack_interval_s"]), 0.001)
	if time_to_kill > float(the_boss.data.get("instant_kill_ratio", 3.0)) * time_to_die:
		Store.dispatch(Actions.player_damaged(Store.health() + 1.0, "boss"))


# ------------------------------------------------------------ courses

func _enter_course(id: String, entrance: Dictionary) -> void:
	course_id = id
	var c := Selectors.course(id)
	course_return_x = float(entrance["x"]) + float(builder.get_segment(entrance["id"])["width"]) * block_px + block_px
	course_node = load(c["scene"]).instantiate()
	course_node.position = Vector2(viking.global_position.x, COURSE_Y_OFFSET)
	add_child(course_node)
	move_child(course_node, segments_root.get_index() + 1)  # draw under the Viking
	segments_root.visible = false
	viking.in_course = true
	viking.set_fall_kill_y(COURSE_Y_OFFSET + 3.0 * block_px)
	var start: Marker2D = course_node.get_node("Start")
	viking.drop_in(course_node.global_position.x + start.position.x, course_node.global_position.y + start.position.y - block_px)
	Store.dispatch(Actions.course_entered(id))
	_toast("%s: don't fall!" % c["name"])


func _update_course() -> void:
	var end: Marker2D = course_node.get_node("End")
	if viking.global_position.x >= course_node.global_position.x + end.position.x:
		var c := Selectors.course(course_id)
		Store.dispatch(Actions.course_completed(course_id, c["reward"]))
		_toast("Unlocked: %s" % Selectors.ingredient(c["reward"]["id"]).get("name", c["reward"]["id"]))
		_leave_course(true)


func _fail_course() -> void:
	viking.dead = true
	viking.velocity = Vector2.ZERO
	Store.dispatch(Actions.course_failed(course_id))
	course_overlay.visible = true


func _retry_course() -> void:
	course_overlay.visible = false
	var start: Marker2D = course_node.get_node("Start")
	viking.drop_in(course_node.global_position.x + start.position.x, course_node.global_position.y + start.position.y - block_px)


func _leave_course(completed: bool) -> void:
	course_overlay.visible = false
	if course_node != null:
		course_node.queue_free()
		course_node = null
	segments_root.visible = true
	viking.in_course = false
	viking.set_fall_kill_y(3.0 * block_px)
	viking.drop_in(course_return_x, _drop_in_top_y())
	if not completed:
		_toast("Back to the surface")
	Store.dispatch(Actions.checkpoint_reached("course_end"))
	_update_stream()


# ---------------------------------------------------------------- HUD

func _on_store_changed(_action: Dictionary) -> void:
	sprint_button.visible = Store.has_sprint()
	tint.color = Selectors.colour_shift(Store.state)


func distance_to_level_end_m() -> float:
	return max(0.0, (level_end_x - viking.global_position.x) / block_px)


func _toast(text: String, seconds: float = 3.0) -> void:
	hud.get_node("%Toast").text = text
	_toast_left = seconds


func _update_hud() -> void:
	if _toast_left > 0.0:
		_toast_left -= get_physics_process_delta_time()
		if _toast_left <= 0.0:
			hud.get_node("%Toast").text = ""
	hud.get_node("%Gold").text = "%s gold   (%.1f/m)" % [_short(Store.gold()), Store.gold_per_metre()]
	hud.get_node("%Level").text = "%s %d" % [biome.get("name", biome_id), level_index + 1]
	hud.get_node("%Boss").text = "Course" if course_node != null else ("Boss: %d m" % int(distance_to_level_end_m()))
	var hp: ProgressBar = hud.get_node("%Health")
	hp.max_value = Store.max_health()
	hp.value = Store.health()
	var effects := ""
	for e in Selectors.active_effects(Store.state):
		var left := float(e["remaining_s"])
		effects += "%s %s  " % [Selectors.ingredient(e["id"]).get("name", e["id"]), ("%ds" % int(left)) if left >= 0.0 else "level"]
	hud.get_node("%Effects").text = effects
	var nxt := Store.next_slot_unlock()
	hud.get_node("%NextUnlock").text = "" if nxt.is_empty() else "%s at %s gold" % [nxt["name"], _short(float(nxt["bracket"]))]
	sprint_button.disabled = Store.sprint_cooldown() > 0.0 or viking.is_sprinting()
	sprint_button.text = "Sprint" if Store.sprint_cooldown() <= 0.0 else "%ds" % ceili(Store.sprint_cooldown())


static func _short(v: float) -> String:
	if v < 1000.0:
		return str(int(v))
	var units := ["K", "M", "B", "T"]
	var i := -1
	while v >= 1000.0 and i < units.size() - 1:
		v /= 1000.0
		i += 1
	return "%.1f%s" % [v, units[i]]

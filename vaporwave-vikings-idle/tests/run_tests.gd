## Headless tests for the proof: level builder, runner, layout, Store and save.
## Run:  godot --headless --path . res://tests/run_tests.tscn
## (A scene, not --script, so the Store and Save autoloads exist.)
extends Node

var failures := 0
var passes := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var library := LevelBuilder.load_library("res://content/segments/proof.json")
	var builder := LevelBuilder.new(library)
	var target := int(Content.load_json("res://content/economy.json")["level_length_m"])

	print("== Library ==")
	expect(library.size() == 5, "library has 5 segments")
	for seg in library:
		expect(int(seg["width"]) == 48, "%s is 48 blocks wide" % seg["id"])
		expect(int(seg["entry_row"]) == 2 and int(seg["exit_row"]) == 2, "%s enters and exits on row 2" % seg["id"])
		expect(ResourceLoader.exists(seg["scene"]), "%s scene exists" % seg["id"])
		var node: Node = load(seg["scene"]).instantiate()
		expect(node is Segment and node.segment_id == seg["id"], "%s scene matches its metadata" % seg["id"])
		node.free()
	var lint := SegmentLinter.lint(library)
	expect(lint.is_empty(), "linter passes" + ("" if lint.is_empty() else ": " + str(lint)))

	print("== Seam rule ==")
	expect(LevelBuilder.seam_ok(2, 2), "same row joins")
	expect(LevelBuilder.seam_ok(2, 3), "one row up joins")
	expect(not LevelBuilder.seam_ok(2, 4), "two rows up does not join")
	expect(LevelBuilder.seam_ok(5, 2), "three rows down joins")
	expect(not LevelBuilder.seam_ok(6, 2), "four rows down does not join")

	print("== Determinism ==")
	var a := builder.build_level(42, target)
	var b := builder.build_level(42, target)
	var c := builder.build_level(43, target)
	expect(a["ids"] == b["ids"], "same seed gives the same level")
	expect(a["ids"] != c["ids"], "different seed gives a different level")
	expect(builder.get_segment(a["ids"][0])["roles"].has("start"), "level starts with a start segment")

	print("== Monte Carlo: 10,000 levels ==")
	var usage := {}
	var fallbacks := 0
	var bad := 0
	var repeats := 0
	var min_len := 1 << 30
	var max_len := 0
	for i in 10000:
		var r := builder.build_level(LevelBuilder.derive_seed(7, i), target)
		if r["fallback"]:
			fallbacks += 1
		if not builder.check(r["ids"], target, true):
			bad += 1
		min_len = min(min_len, int(r["length"]))
		max_len = max(max_len, int(r["length"]))
		for j in r["ids"].size():
			usage[r["ids"][j]] = int(usage.get(r["ids"][j], 0)) + 1
			if j > 0 and r["ids"][j] == r["ids"][j - 1]:
				repeats += 1
	expect(fallbacks == 0, "no fallbacks (got %d)" % fallbacks)
	expect(bad == 0, "every level passes the check (failures: %d)" % bad)
	expect(repeats == 0, "no segment repeats back to back (got %d)" % repeats)
	expect(usage.size() == 5, "all 5 segments get used")
	print("   length range: %d to %d m (target %d)" % [min_len, max_len, target])
	print("   usage: %s" % str(usage))

	print("== Extension after a pit fall ==")
	var level: Array = a["ids"]
	var kept := level.slice(0, 10)
	var ext := builder.extend_level(kept, LevelBuilder.derive_seed(42, 1), target)
	var ext2 := builder.extend_level(kept, LevelBuilder.derive_seed(42, 1), target)
	expect(ext["ids"].slice(0, 10) == kept, "kept segments are unchanged")
	expect(builder.length_of(ext["added"]) >= target * 0.9, "a full level's length is added (%d m)" % builder.length_of(ext["added"]))
	expect(ext["ids"] == ext2["ids"], "extension is deterministic")
	expect(not ext["fallback"], "extension needed no fallback")

	await _simulation_tests()

	print("\n%d passed, %d failed" % [passes, failures])
	get_tree().quit(1 if failures > 0 else 0)


func _simulation_tests() -> void:
	print("== Simulation: idle Viking for 60 s ==")
	Store.reset()
	Save.enabled = false
	var run: Node = load("res://scenes/run/run.tscn").instantiate()
	get_tree().root.add_child(run)
	await get_tree().process_frame
	var viking: Viking = run.get_node("Viking")
	var start_x := viking.global_position.x
	for i in 60 * 60:
		await get_tree().physics_frame
	var metres := (viking.global_position.x - start_x) / 32.0
	expect(run.pit_falls == 0, "idle Viking never falls into a pit (falls: %d)" % run.pit_falls)
	expect(metres > 250.0, "idle Viking keeps running (%d m in 60 s)" % int(metres))
	expect(viking.auto_jumps > 0, "auto-jump fired at pits (%d)" % viking.auto_jumps)
	expect(Store.gold() > 200.0, "running paid gold into the Store (%d)" % int(Store.gold()))
	expect(is_equal_approx(float(Store.state["run"]["distance_m"]), floorf(metres)) or absf(float(Store.state["run"]["distance_m"]) - metres) < 2.0, "Store distance matches the Viking (%d m)" % int(Store.state["run"]["distance_m"]))

	print("== Simulation: jumping early drops into a pit and extends the level ==")
	viking.auto_jump_enabled = false
	var frames := 0
	while run.pit_falls == 0 and frames < 60 * 60:
		await get_tree().physics_frame
		frames += 1
	expect(run.pit_falls == 1, "Viking fell into a pit with auto-jump off")
	await get_tree().physics_frame
	viking.auto_jump_enabled = true
	expect(run.distance_to_level_end_m() >= run.level_length_blocks * 0.9, "level end pushed back a full level (%d m to go)" % int(run.distance_to_level_end_m()))
	for i in 120:
		await get_tree().physics_frame
	expect(viking.is_on_floor() and viking.global_position.y < 0.0, "Viking dropped in and landed on the floor")

	print("== Simulation: tapping early before a pit drops the Viking in ==")
	var falls_before: int = run.pit_falls
	var pit_x := _next_pit_start(run, viking.global_position.x + 64.0)
	expect(pit_x > 0.0, "found a pit ahead")
	var waited := 0
	while viking.global_position.x < pit_x - 3.0 * 32.0 and waited < 60 * 120:
		await get_tree().physics_frame
		waited += 1
	viking.request_jump()
	for i in 180:
		await get_tree().physics_frame
	expect(run.pit_falls == falls_before + 1, "an early tap lands the Viking in the pit")
	await _layout_tests(run)
	run.queue_free()


func _layout_tests(run: Node) -> void:
	print("== Layout: landscape drawer, then portrait dock ==")
	var layout: Layout = run.layout
	var panel: Control = run.menu_panel
	var cam: Camera2D = run.camera

	var land := Vector2(960, 480)
	layout.set_override_size(land)
	await get_tree().process_frame
	expect(not layout.is_portrait, "960x480 is landscape")
	expect(panel.get_parent().name == "Drawer", "panel lives in the drawer in landscape")
	expect(not layout.drawer_open, "drawer starts closed")
	expect(layout.game_rect().size == land, "game view fills the screen in landscape")
	expect(is_equal_approx(cam.zoom.y, 480.0 / 480.0), "camera fits 15 blocks to 480 px (zoom %.3f)" % cam.zoom.y)
	layout.open_drawer()
	for i in 20:
		await get_tree().process_frame
	expect(layout.drawer_open and run.get_node("UI/Drawer").position.x < land.x, "drawer slides in")
	expect(layout.game_rect().size == land, "open drawer does not change the game view")
	layout.close_drawer()
	for i in 20:
		await get_tree().process_frame
	expect(not layout.drawer_open, "drawer closes")

	var port := Vector2(480, 960)
	layout.set_override_size(port)
	await get_tree().process_frame
	expect(layout.is_portrait, "480x960 is portrait")
	expect(panel.get_parent().name == "Dock", "panel docks to the bottom in portrait")
	expect(is_equal_approx(layout.game_rect().size.y, 480.0), "game view is the top half in portrait")
	expect(is_equal_approx(cam.zoom.y, 480.0 / 480.0), "camera still fits 15 blocks to the game view")
	expect(not layout.drawer_open, "no drawer in portrait")
	expect(panel.current_tab == "Gear", "tab survives the rotation")

	layout.set_override_size(land)
	await get_tree().process_frame
	expect(panel.get_parent().name == "Drawer", "rotating back moves the panel to the drawer again")

	await _store_tests()
	await _save_tests()


func _store_tests() -> void:
	print("== Store: reducers and selectors ==")
	Store.reset()
	var st: Dictionary = Store.state
	expect(is_equal_approx(Store.gold(), 0.0), "a new game starts with 0 gold")
	expect(Store.is_unlocked("sword") and Store.is_unlocked("chest") and Store.is_unlocked("helmet"), "sword, chest and helmet unlock at start")
	expect(not Store.is_unlocked("legs"), "legs are locked until 100 gold is held")
	expect(is_equal_approx(Store.gold_per_metre(), 1.0), "base gold per metre is 1")

	Store.dispatch(Actions.distance_travelled(10.0))
	expect(is_equal_approx(Store.gold(), 10.0), "10 metres pays 10 gold")
	expect(is_equal_approx(float(st["wallet"]["lifetime_gold"]), 10.0), "lifetime gold tracks earnings")
	Store.dispatch(Actions.coin_collected("gold", 3))
	expect(is_equal_approx(Store.gold(), 28.0), "3 coins pay 18 gold")

	Store.dispatch(Actions.gear_level_bought("sword"))
	expect(Store.gear_level("sword") == 1 and is_equal_approx(Store.gold(), 27.0), "first sword level costs 1 gold")
	expect(is_equal_approx(Store.next_level_cost("sword"), 2.0), "next sword level costs 2 (linear)")
	expect(is_equal_approx(Store.gold_per_metre(), 1.2), "sword level adds 0.2 gold per metre")
	expect(is_equal_approx(Selectors.damage(st), 12.0), "sword level adds 2 damage")

	Store.dispatch(Actions.gear_level_bought("legs"))
	expect(Store.gear_level("legs") == 0, "cannot buy a locked slot")
	Store.dispatch(Actions.gear_level_bought("helmet"))
	expect(Store.gear_level("helmet") == 0 and is_equal_approx(Store.gold(), 27.0), "cannot afford the 100-gold helmet; gold unchanged")

	Store.dispatch(Actions.distance_travelled(100.0))
	expect(Store.is_unlocked("legs"), "legs unlock once the wallet holds 100")
	expect(not Store.is_unlocked("boots"), "boots still locked below 1000")
	expect(not Store.has_sprint(), "no sprint before legs level 1")
	Store.dispatch(Actions.distance_travelled(200.0))
	Store.dispatch(Actions.gear_level_bought("legs"))
	expect(Store.gear_level("legs") == 1 and Store.has_sprint(), "legs level 1 grants sprint")
	expect(Store.next_slot_unlock().get("id", "") == "boots", "next locked slot is boots")

	Store.dispatch(Actions.distance_travelled(1.0))
	expect(st["wallet"]["gold"] < 1e9, "spending gold did not unlock far slots")
	Store.dispatch(Actions.player_damaged(500.0, "basic"))
	expect(is_equal_approx(float(st["run"]["health"]), 1.0), "a basic enemy cannot kill: health floors at 1")
	Store.dispatch(Actions.player_damaged(500.0, "elite"))
	expect(is_equal_approx(float(st["run"]["health"]), 0.0), "an elite can kill")
	Store.dispatch(Actions.player_died("elite"))
	expect(int(st["stats"]["lifetime"]["deaths"]) == 1 and is_equal_approx(float(st["run"]["health"]), Selectors.max_health(st)), "death counts and restores health")
	Store.dispatch(Actions.pit_fallen())
	expect(int(st["stats"]["run"]["pit_falls"]) == 1, "pit fall counted")
	Store.dispatch(Actions.sprint_used())
	expect(float(st["run"]["sprint_cooldown_s"]) > 0.0, "sprint starts its cooldown")
	Store.dispatch(Actions.time_advanced(30.0))
	expect(is_equal_approx(float(st["run"]["sprint_cooldown_s"]), 0.0), "cooldown ticks down with play time")
	expect(Store.action_log.size() > 0, "actions are logged for the batch builder")
	Store.dispatch(Actions.checkpoint_reached("test"))
	expect(Store.action_log.is_empty(), "checkpoint clears the action log")


func _save_tests() -> void:
	print("== Save: round trip, backup and migration ==")
	var path := "user://test_save.json"
	Save.enabled = true
	for p in [path, path + ".tmp", path + ".bak"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
	Store.reset()
	Store.dispatch(Actions.distance_travelled(50.0))
	Store.dispatch(Actions.gear_level_bought("chest"))
	var before := JSON.stringify(Store.state)
	expect(Save.save(path), "save writes a file")
	expect(FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".tmp"), "temp file renamed into place")
	Store.reset()
	expect(is_equal_approx(Store.gold(), 0.0), "reset clears gold")
	expect(Save.load(path), "load finds the save")
	# JSON turns ints into floats, so compare both sides after a JSON round trip.
	expect(JSON.stringify(JSON.parse_string(JSON.stringify(Store.state))) == JSON.stringify(JSON.parse_string(before)), "loaded state equals saved state")
	expect(Store.gear_level("chest") == 1 and is_equal_approx(Store.gold(), 40.0), "chest level and 40 gold survive the round trip")

	expect(Save.save(path), "second save")
	expect(FileAccess.file_exists(path + ".bak"), "previous save kept as backup")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("{ not json")
	f.close()
	Store.reset()
	expect(Save.load(path), "corrupt save falls back to the backup")
	expect(Store.gear_level("chest") == 1, "backup carried the chest level")

	var old := {"wallet": {"gold": 7.0}}
	var migrated := Save.migrate(old)
	expect(migrated.has("gear") and migrated.has("run") and migrated["meta"]["save_format"] == InitialState.SAVE_FORMAT, "migration fills missing slices")
	expect(is_equal_approx(float(migrated["wallet"]["gold"]), 7.0) and migrated["wallet"].has("lifetime_gold"), "migration keeps saved values and adds missing keys")
	for p in [path, path + ".tmp", path + ".bak"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
	Store.reset()


func _next_pit_start(run: Node, after_x: float) -> float:
	var best := -1.0
	for entry in run.track:
		var seg: Dictionary = run.builder.get_segment(entry["id"])
		for pit in seg.get("pits", []):
			var px: float = float(entry["x"]) + float(pit[0]) * 32.0
			if px > after_x and (best < 0.0 or px < best):
				best = px
	return best


func expect(ok: bool, label: String) -> void:
	if ok:
		passes += 1
		print("  PASS  " + label)
	else:
		failures += 1
		print("  FAIL  " + label)

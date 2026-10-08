## Headless tests for the proof segment set and the level builder.
## Run:  godot --headless --path . --script res://tests/run_tests.gd
extends SceneTree

var failures := 0
var passes := 0


func _initialize() -> void:
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
	quit(1 if failures > 0 else 0)


func _simulation_tests() -> void:
	print("== Simulation: idle Viking for 60 s ==")
	var run: Node = load("res://scenes/run/run.tscn").instantiate()
	root.add_child(run)
	await process_frame
	var viking: Viking = run.get_node("Viking")
	var start_x := viking.global_position.x
	for i in 60 * 60:
		await physics_frame
	var metres := (viking.global_position.x - start_x) / 32.0
	expect(run.pit_falls == 0, "idle Viking never falls into a pit (falls: %d)" % run.pit_falls)
	expect(metres > 250.0, "idle Viking keeps running (%d m in 60 s)" % int(metres))
	expect(viking.auto_jumps > 0, "auto-jump fired at pits (%d)" % viking.auto_jumps)

	print("== Simulation: jumping early drops into a pit and extends the level ==")
	viking.auto_jump_enabled = false
	var frames := 0
	while run.pit_falls == 0 and frames < 60 * 60:
		await physics_frame
		frames += 1
	expect(run.pit_falls == 1, "Viking fell into a pit with auto-jump off")
	await physics_frame
	viking.auto_jump_enabled = true
	expect(run.distance_to_level_end_m() >= run.level_length_blocks * 0.9, "level end pushed back a full level (%d m to go)" % int(run.distance_to_level_end_m()))
	for i in 120:
		await physics_frame
	expect(viking.is_on_floor() and viking.global_position.y < 0.0, "Viking dropped in and landed on the floor")

	print("== Simulation: tapping early before a pit drops the Viking in ==")
	var falls_before: int = run.pit_falls
	var pit_x := _next_pit_start(run, viking.global_position.x + 64.0)
	expect(pit_x > 0.0, "found a pit ahead")
	var waited := 0
	while viking.global_position.x < pit_x - 3.0 * 32.0 and waited < 60 * 120:
		await physics_frame
		waited += 1
	viking.request_jump()
	for i in 180:
		await physics_frame
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
	await process_frame
	expect(not layout.is_portrait, "960x480 is landscape")
	expect(panel.get_parent().name == "Drawer", "panel lives in the drawer in landscape")
	expect(not layout.drawer_open, "drawer starts closed")
	expect(layout.game_rect().size == land, "game view fills the screen in landscape")
	expect(is_equal_approx(cam.zoom.y, 480.0 / 480.0), "camera fits 15 blocks to 480 px (zoom %.3f)" % cam.zoom.y)
	layout.open_drawer()
	for i in 20:
		await process_frame
	expect(layout.drawer_open and run.get_node("UI/Drawer").position.x < land.x, "drawer slides in")
	expect(layout.game_rect().size == land, "open drawer does not change the game view")
	layout.close_drawer()
	for i in 20:
		await process_frame
	expect(not layout.drawer_open, "drawer closes")

	var port := Vector2(480, 960)
	layout.set_override_size(port)
	await process_frame
	expect(layout.is_portrait, "480x960 is portrait")
	expect(panel.get_parent().name == "Dock", "panel docks to the bottom in portrait")
	expect(is_equal_approx(layout.game_rect().size.y, 480.0), "game view is the top half in portrait")
	expect(is_equal_approx(cam.zoom.y, 480.0 / 480.0), "camera still fits 15 blocks to the game view")
	expect(not layout.drawer_open, "no drawer in portrait")
	expect(panel.current_tab == "Gear", "tab survives the rotation")

	layout.set_override_size(land)
	await process_frame
	expect(panel.get_parent().name == "Drawer", "rotating back moves the panel to the drawer again")

	print("== Placeholder gear panel ==")
	# A fresh panel, so the gold earned during the simulation does not pre-unlock slots.
	panel = load("res://scenes/ui/menu_panel.tscn").instantiate()
	root.add_child(panel)
	await process_frame
	panel.set_gold(0.0)
	expect(panel.unlocked.get("sword", false) and panel.unlocked.get("helmet", false), "sword, chest and helmet unlock at start")
	expect(not panel.unlocked.get("legs", false), "legs are locked until 100 gold is held")
	panel.set_gold(999.0)
	expect(panel.unlocked.get("legs", false) and not panel.unlocked.get("boots", false), "legs unlock at 100 gold; boots wait for 1000")
	panel._buy("sword")
	expect(int(panel.levels.get("sword", 0)) == 1 and is_equal_approx(panel.gold, 998.0), "first sword level costs 1 gold")
	panel._buy("sword")
	expect(is_equal_approx(panel.gold, 996.0), "second sword level costs 2 gold (linear)")
	panel._buy("chest")
	expect(is_equal_approx(panel.gold, 986.0), "first chest level costs 10 gold")
	panel._buy("helmet")
	expect(is_equal_approx(panel.gold, 886.0), "first helmet level costs 100 gold")
	panel._buy("legs")
	expect(is_equal_approx(panel.gold, 636.0), "first legs level costs 250 gold")
	panel.set_gold(3.0)
	var buy: Button = panel.get_node("%Rows/helmet/H/Buy")
	expect(buy.disabled, "buy button disabled when gold is short")
	var sword_buy: Button = panel.get_node("%Rows/sword/H/Buy")
	expect(not sword_buy.disabled, "cheap sword level still affordable with 3 gold")
	panel.queue_free()


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

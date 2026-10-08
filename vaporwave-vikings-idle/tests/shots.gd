## Screenshot tour of the proof for the docs. Needs a window (xvfb is fine):
##   godot --path . --resolution 960x480 --rendering-driver opengl3 res://tests/shots.tscn -- /out/dir
extends Node

var out_dir := "user://shots"


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out_dir = args[0]
	DirAccess.make_dir_recursive_absolute(out_dir)
	_go.call_deferred()


func _go() -> void:
	Save.enabled = false
	var run: Node = load("res://scenes/run/run.tscn").instantiate()
	get_tree().root.add_child(run)
	await get_tree().process_frame
	var viking: Viking = run.viking
	await _wait(150)
	_shot("surface")
	_teleport(run, "proof_elite_arena", 22.0)
	await _wait(200)
	_shot("elite")
	viking.auto_jump_enabled = false
	_teleport(run, "proof_cave_entrance", 17.0)
	await _wait(150)
	_shot("cave")
	await _wait(300)
	_shot("cave_fail")
	run._leave_course(false)
	viking.auto_jump_enabled = true
	Store.dispatch(Actions.ingredient_eaten("spirit_leaf"))
	await _wait(150)
	_shot("tinted")
	Store.dispatch(Actions.distance_travelled(5000.0))
	Store.dispatch(Actions.gear_level_bought("sword", 40))
	_teleport(run, "proof_boss_arena", 20.0)
	await _wait(150)
	_shot("boss")
	get_tree().quit()


func _teleport(run: Node, id: String, blocks: float) -> void:
	for entry in run.track:
		if entry["id"] == id and float(entry["x"]) > run.viking.global_position.x:
			run.viking.drop_in(float(entry["x"]) + blocks * 32.0, -256.0)
			run.viking.blocker = null
			run._update_stream()
			return


func _wait(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame


func _shot(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.save_png(out_dir.path_join("shot_%s.png" % name))
	print("shot ", name)

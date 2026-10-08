## The runner: auto-run, tap to jump, auto-jump at gaps, pit-fall detection.
## See docs/game-systems/runner.md.
class_name Viking
extends CharacterBody2D

signal pit_fallen(world_x: float)

var block_px := 32.0
var run_speed := 160.0
var gravity := 896.0
var jump_velocity := 448.0
var coyote_time := 0.1
var jump_buffer := 0.1
var probe_ahead := 20.0

var auto_jump_enabled := true
var jumps := 0
var auto_jumps := 0

var _coyote_left := 0.0
var _buffer_left := 0.0
var _fallen := false

@onready var _probe: RayCast2D = $GapProbe


func _ready() -> void:
	var viking: Dictionary = Content.load_json("res://content/viking.json")
	var economy: Dictionary = Content.load_json("res://content/economy.json")
	var phys: Dictionary = viking["physics"]
	block_px = float(phys["block_px"])
	run_speed = float(economy["run_speed_mps"]) * block_px
	gravity = float(phys["gravity_blocks_s2"]) * block_px
	jump_velocity = float(phys["jump_velocity_blocks_s"]) * block_px
	coyote_time = float(phys["coyote_s"])
	jump_buffer = float(phys["jump_buffer_s"])
	probe_ahead = float(phys["probe_ahead_px"])
	_probe.position = Vector2(probe_ahead, -2.0)
	_probe.target_position = Vector2(0, block_px)


func request_jump() -> void:
	_buffer_left = jump_buffer


func _unhandled_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		tapped = true
	if tapped:
		request_jump()  # In mid-air this will later cast the wand instead.


func _physics_process(delta: float) -> void:
	velocity.x = run_speed
	if is_on_floor():
		_coyote_left = coyote_time
	else:
		_coyote_left -= delta
		velocity.y += gravity * delta
	_buffer_left -= delta

	var player_jump := _buffer_left > 0.0 and _coyote_left > 0.0
	var gap_ahead := is_on_floor() and not _probe.is_colliding()
	if player_jump:
		_jump()
	elif auto_jump_enabled and gap_ahead:
		auto_jumps += 1
		_jump()

	move_and_slide()

	if not _fallen and global_position.y > 3.0 * block_px:
		_fallen = true
		pit_fallen.emit(global_position.x)


func _jump() -> void:
	velocity.y = -jump_velocity
	_coyote_left = 0.0
	_buffer_left = 0.0
	jumps += 1


## Drop-in: fall from the top of the screen at world x.
func drop_in(world_x: float, top_y: float) -> void:
	global_position = Vector2(world_x, top_y)
	velocity = Vector2.ZERO
	_fallen = false

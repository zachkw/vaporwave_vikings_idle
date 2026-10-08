## The runner: auto-run, tap to jump, auto-jump at gaps, sprint, automatic
## sword swings, stopping to fight elites and bosses, pit falls and death.
## See docs/game-systems/runner.md and combat.md.
class_name Viking
extends CharacterBody2D

signal pit_fallen(world_x: float)
signal died(cause: String)

var block_px := 32.0
var run_speed := 160.0
var gravity := 896.0
var jump_velocity := 448.0
var coyote_time := 0.1
var jump_buffer := 0.1
var probe_ahead := 20.0
var attack_range := 48.0
var attacks_per_second := 2.0
var sprint_cfg: Dictionary = {}

var auto_jump_enabled := true
var in_course := false
var jumps := 0
var auto_jumps := 0
var kills := 0

## The enemy currently stopping the Viking, or null.
var blocker: Enemy = null
var dead := false

var _coyote_left := 0.0
var _buffer_left := 0.0
var _fallen := false
var _attack_timer := 0.0
var _sprint_left := 0.0
var _fall_kill_y := INF

@onready var _probe: RayCast2D = $GapProbe
@onready var _attack_area: Area2D = $AttackArea
@onready var _visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group("viking")
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
	attack_range = float(viking["attack_range_blocks"]) * block_px
	attacks_per_second = float(viking["attacks_per_second"])
	sprint_cfg = viking["sprint"]
	_probe.position = Vector2(probe_ahead, -2.0)
	_probe.target_position = Vector2(0, block_px)
	_attack_area.get_node("Shape").shape.size = Vector2(attack_range, 60)
	_attack_area.position = Vector2(12 + attack_range / 2, -30)
	_fall_kill_y = 3.0 * block_px
	Store.changed.connect(_on_store_changed)


func set_fall_kill_y(y: float) -> void:
	_fall_kill_y = y


func request_jump() -> void:
	if dead:
		return
	_buffer_left = jump_buffer


func request_sprint() -> void:
	if dead or not Store.has_sprint() or Store.sprint_cooldown() > 0.0 or _sprint_left > 0.0:
		return
	_sprint_left = float(sprint_cfg["duration_s"])
	Store.dispatch(Actions.sprint_used())


func is_sprinting() -> bool:
	return _sprint_left > 0.0


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
	if dead:
		velocity.x = 0.0
		velocity.y += gravity * delta
		move_and_slide()
		return
	_sprint_left = max(0.0, _sprint_left - delta)
	var speed := run_speed * Store.run_speed_mult()
	if _sprint_left > 0.0:
		speed *= float(sprint_cfg["speed_mult"])
	# An elite or boss ahead stops the run until one of us dies.
	if blocker != null and is_instance_valid(blocker) and blocker.health > 0.0:
		if global_position.x >= blocker.stop_line_x():
			speed = 0.0
	else:
		blocker = null
	velocity.x = speed

	if is_on_floor():
		_coyote_left = coyote_time
	else:
		_coyote_left -= delta
		velocity.y += gravity * delta
	_buffer_left -= delta

	var player_jump := _buffer_left > 0.0 and _coyote_left > 0.0
	var gap_ahead := is_on_floor() and not _probe.is_colliding() and speed > 0.0
	if player_jump:
		_jump()
	elif auto_jump_enabled and not in_course and gap_ahead:
		auto_jumps += 1
		_jump()

	move_and_slide()
	_swing(delta)

	if not _fallen and global_position.y > _fall_kill_y:
		_fallen = true
		pit_fallen.emit(global_position.x)


## Automatic sword: hits the nearest enemy in the attack area on a timer.
func _swing(delta: float) -> void:
	_attack_timer -= delta
	if _attack_timer > 0.0:
		return
	var target: Enemy = null
	var best := INF
	for area in _attack_area.get_overlapping_areas():
		if area is Enemy and area.health > 0.0:
			var d: float = absf(area.global_position.x - global_position.x)
			if d < best:
				best = d
				target = area
	if target == null:
		return
	_attack_timer = 1.0 / attacks_per_second
	target.take_hit(Store.damage())
	_visual.modulate = Color(1.4, 1.4, 1.4)
	get_tree().create_timer(0.08).timeout.connect(func() -> void: _visual.modulate = Color.WHITE)


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
	dead = false
	blocker = null
	_visual.modulate = Color.WHITE
	_visual.rotation = 0.0


func _on_store_changed(action: Dictionary) -> void:
	if dead:
		return
	if action["type"] == Actions.PLAYER_DAMAGED and Store.health() <= 0.0:
		dead = true
		_visual.modulate = Color(0.5, 0.5, 0.5)
		_visual.rotation = PI / 2
		died.emit(action.get("source_role", ""))

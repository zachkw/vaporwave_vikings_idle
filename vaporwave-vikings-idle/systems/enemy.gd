## An enemy on the run. Data comes from content/enemies.json; the scene is a
## placeholder rect sized by role. See docs/game-systems/enemies-and-spawning.md.
class_name Enemy
extends Area2D

signal died(enemy: Enemy)

var data: Dictionary = {}
var role := "basic"
var health := 10.0
var max_health := 10.0
var dimension := ""
var _attack_timer := 0.0
var _viking_in_contact: Viking = null

@onready var _visual: ColorRect = $Visual
@onready var _bar: ColorRect = $HealthBar


func setup(enemy_data: Dictionary) -> void:
	data = enemy_data
	role = data["role"]
	health = float(data["health"])
	max_health = health
	dimension = data.get("dimension", "")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var size := Vector2(28, 36)
	match role:
		"elite": size = Vector2(56, 72)
		"boss": size = Vector2(110, 110)
	_visual.size = size
	_visual.position = Vector2(-size.x / 2, -size.y)
	var c: Array = data.get("colour", [0.8, 0.3, 0.3])
	_visual.color = Color(c[0], c[1], c[2])
	$Shape.shape = RectangleShape2D.new()
	$Shape.shape.size = size
	$Shape.position = Vector2(0, -size.y / 2)
	_bar.position = Vector2(-size.x / 2, -size.y - 8)
	_bar.size = Vector2(size.x, 4)
	_update_bar()


func stop_line_x() -> float:
	return global_position.x - _visual.size.x / 2 - 20.0


func take_hit(amount: float) -> void:
	if health <= 0.0:
		return
	health -= amount
	_update_bar()
	if health <= 0.0:
		Store.dispatch(Actions.enemy_killed(data["id"], role, dimension, false))
		died.emit(self)
		queue_free()


func _update_bar() -> void:
	_bar.scale.x = clampf(health / max_health, 0.0, 1.0)


func _physics_process(delta: float) -> void:
	if health <= 0.0 or not _in_reach():
		return
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = float(data["attack_interval_s"])
		Store.dispatch(Actions.player_damaged(float(data["attack"]), role))


## Basics hit on contact. Elites and bosses also hit once the Viking is
## held at their stop line, so a stand-off is never free.
func _in_reach() -> bool:
	if _viking_in_contact != null and not _viking_in_contact.dead:
		return true
	if role == "basic":
		return false
	var v: Node = get_tree().get_first_node_in_group("viking")
	if v == null or v.dead:
		return false
	return v.global_position.x >= stop_line_x() - 4.0 and absf(v.global_position.y - global_position.y) < 3.0 * 32.0


func _on_body_entered(body: Node) -> void:
	if body is Viking:
		_viking_in_contact = body
		_attack_timer = 0.3


func _on_body_exited(body: Node) -> void:
	if body == _viking_in_contact:
		_viking_in_contact = null

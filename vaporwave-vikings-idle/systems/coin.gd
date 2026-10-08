## A coin on the run. Touching it pays through the Store and removes it.
extends Area2D

var from_sky := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Viking:
		Store.dispatch(Actions.coin_collected("gold", 1, from_sky))
		queue_free()

## A question-mark box holding an ingredient. Running into it (or hitting it
## from below) eats the ingredient at once. See docs/game-systems/dimensions.md.
extends Area2D

var ingredient_id := "spirit_leaf"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Viking:
		Store.dispatch(Actions.ingredient_eaten(ingredient_id, "raw", "box"))
		queue_free()

## One parallax layer of trees built from a sprite: `count` trees spread over
## one repeat `width`, with a little random scale, flip and shade so the
## line does not look stamped. The Parallax2D parent repeats it.
@tool
extends Node2D

@export var texture: Texture2D
@export var width := 1920.0
@export var floor_y := -64.0
@export var count := 6
@export var seed := 1
@export var scale_range := Vector2(0.9, 1.25)
@export var tint := Color(1, 1, 1, 1)
@export var tint_variation := 0.12
## Lift or sink the trunks relative to the floor, in pixels.
@export var y_offset := 0.0


func _ready() -> void:
	_build()


func _build() -> void:
	for child in get_children():
		child.queue_free()
	if texture == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var step := width / count
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		var s := rng.randf_range(scale_range.x, scale_range.y)
		sprite.scale = Vector2(s, s)
		sprite.flip_h = rng.randf() < 0.5
		var shade := 1.0 - rng.randf() * tint_variation
		sprite.modulate = Color(tint.r * shade, tint.g * shade, tint.b * shade, tint.a)
		var x := i * step + rng.randf_range(0.0, step * 0.6)
		sprite.position = Vector2(x, floor_y + y_offset - texture.get_height() * s)
		add_child(sprite)

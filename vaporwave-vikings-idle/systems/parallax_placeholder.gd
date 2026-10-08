## Placeholder art for one parallax layer, drawn with shapes until real
## biome art exists. Draws one repeat tile of `width` px; the parent
## Parallax2D repeats it. Floor surface is at y = floor_y (row 2).
@tool
extends Node2D

enum Kind { SUN, MOUNTAINS, HILLS, TREES, GRID }

@export var kind: Kind = Kind.MOUNTAINS
@export var width := 1920.0
@export var floor_y := -64.0
@export var color := Color(0.4, 0.2, 0.6)
@export var accent := Color(1.0, 0.4, 0.8)
@export var height := 200.0
@export var count := 6
@export var seed := 1


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	match kind:
		Kind.SUN:
			var centre := Vector2(width * 0.5, floor_y - height)
			var radius := height * 0.6
			draw_circle(centre, radius, color)
			# vaporwave stripes across the lower half of the sun
			for i in 5:
				var y := centre.y + radius * (0.15 + i * 0.17)
				draw_rect(Rect2(centre.x - radius, y, radius * 2.0, 4.0 + i * 2.0), accent)
		Kind.MOUNTAINS:
			var step := width / count
			for i in count:
				var x := i * step
				var peak := height * rng.randf_range(0.6, 1.0)
				draw_colored_polygon(PackedVector2Array([
					Vector2(x - step * 0.3, floor_y),
					Vector2(x + step * 0.5, floor_y - peak),
					Vector2(x + step * 1.3, floor_y),
				]), color)
				draw_line(Vector2(x + step * 0.5, floor_y - peak), Vector2(x + step * 0.8, floor_y - peak * 0.6), accent, 3.0)
		Kind.HILLS:
			var step := width / count
			for i in count + 1:
				var r := height * rng.randf_range(0.7, 1.0)
				draw_circle(Vector2(i * step, floor_y + r * 0.35), r, color)
		Kind.TREES:
			var step := width / count
			for i in count:
				var x := i * step + rng.randf_range(0.0, step * 0.5)
				var h := height * rng.randf_range(0.6, 1.0)
				draw_rect(Rect2(x - 6.0, floor_y - h * 0.4, 12.0, h * 0.4), accent)
				draw_colored_polygon(PackedVector2Array([
					Vector2(x - 40.0, floor_y - h * 0.35),
					Vector2(x, floor_y - h),
					Vector2(x + 40.0, floor_y - h * 0.35),
				]), color)
		Kind.GRID:
			for i in count:
				var y := floor_y - i * (height / count)
				draw_line(Vector2(0, y), Vector2(width, y), color, 2.0)

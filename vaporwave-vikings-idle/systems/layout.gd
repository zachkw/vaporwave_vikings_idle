## Decides portrait or landscape and places the game view, the menu panel
## and the drawer. See docs/game-systems/hud-and-menus.md.
class_name Layout
extends Node

signal orientation_changed(is_portrait: bool)
signal game_rect_changed(rect: Rect2)

const DRAWER_WIDTH_FRACTION := 0.4
const PORTRAIT_GAME_FRACTION := 0.5

var is_portrait := false
var drawer_open := false
## Tests set this to simulate a screen size; zero means use the real viewport.
var override_size := Vector2.ZERO

var _ui_layer: CanvasLayer
var _panel: Control
var _dock: Control
var _drawer: Control
var _dim: ColorRect
var _menu_button: Button
var _tween: Tween


func setup(ui_layer: CanvasLayer, panel: Control, dock: Control, drawer: Control, dim: ColorRect, menu_button: Button) -> void:
	_ui_layer = ui_layer
	_panel = panel
	_dock = dock
	_drawer = drawer
	_dim = dim
	_menu_button = menu_button
	get_viewport().size_changed.connect(_apply)
	_drawer.clip_contents = true
	_menu_button.pressed.connect(open_drawer)
	_dim.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			close_drawer())
	_apply()


func view_size() -> Vector2:
	return override_size if override_size != Vector2.ZERO else get_viewport().get_visible_rect().size


func set_override_size(size: Vector2) -> void:
	override_size = size
	_apply()


func game_rect() -> Rect2:
	var size := view_size()
	if is_portrait:
		return Rect2(Vector2.ZERO, Vector2(size.x, size.y * PORTRAIT_GAME_FRACTION))
	return Rect2(Vector2.ZERO, size)


func _apply() -> void:
	var size := view_size()
	var portrait := size.y > size.x
	var changed := portrait != is_portrait
	is_portrait = portrait
	var rect := game_rect()
	if is_portrait:
		_dock.visible = true
		_dock.position = Vector2(0, rect.size.y)
		_dock.size = Vector2(size.x, size.y - rect.size.y)
		_move_panel(_dock)
		_drawer.visible = false
		_dim.visible = false
		_menu_button.visible = false
		drawer_open = false
	else:
		_dock.visible = false
		var w := size.x * DRAWER_WIDTH_FRACTION
		_drawer.size = Vector2(w, size.y)
		_drawer.position = Vector2(size.x - w, 0) if drawer_open else Vector2(size.x, 0)
		_drawer.visible = true
		_drawer.get_node("Bg").size = _drawer.size
		_dim.size = size
		_dim.visible = drawer_open
		_menu_button.visible = true
		_move_panel(_drawer)
	_panel.call("set_close_visible", not is_portrait)
	game_rect_changed.emit(rect)
	if changed:
		orientation_changed.emit(is_portrait)


func _move_panel(parent: Control) -> void:
	if _panel.get_parent() != parent:
		if _panel.get_parent() != null:
			_panel.get_parent().remove_child(_panel)
		parent.add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.set_deferred("size", parent.size)
	_panel.set_deferred("position", Vector2.ZERO)


func open_drawer() -> void:
	if is_portrait or drawer_open:
		return
	drawer_open = true
	_dim.visible = true
	_slide(view_size().x - _drawer.size.x)


func close_drawer() -> void:
	if not drawer_open:
		return
	drawer_open = false
	_dim.visible = false
	_slide(view_size().x)


func _slide(to_x: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_drawer, "position:x", to_x, 0.2)

## The menu panel: one scene used as the bottom dock in portrait and as the
## drawer in landscape. Reads the Store through selectors and dispatches
## GEAR_LEVEL_BOUGHT; it owns no player state. See docs/game-systems/hud-and-menus.md.
extends PanelContainer

const TABS := ["Gear", "Artefacts", "Unlocks", "Ascension", "Village", "Shop"]

signal close_requested

var current_tab := "Gear"
var gear: Array = []
var _shown_unlocked := {}

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = %Rows
@onready var _nav: HBoxContainer = %Nav
@onready var _close: Button = %Close


func _ready() -> void:
	gear = Selectors.gear_table()
	Store.changed.connect(_on_store_changed)
	for tab in TABS:
		var b := Button.new()
		b.text = tab
		b.toggle_mode = true
		b.button_pressed = tab == current_tab
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		b.custom_minimum_size = Vector2(0, 44)
		b.add_theme_font_size_override("font_size", 13)
		b.pressed.connect(_select_tab.bind(tab))
		_nav.add_child(b)
	_close.pressed.connect(func() -> void: close_requested.emit())
	_select_tab(current_tab)


func set_close_visible(show_close: bool) -> void:
	_close.visible = show_close


func _on_store_changed(_action: Dictionary) -> void:
	if current_tab != "Gear":
		return
	# Rebuild when a slot has unlocked since the rows were made; otherwise refresh.
	for item in gear:
		if Store.is_unlocked(item["id"]) != _shown_unlocked.get(item["id"], false):
			_rebuild_rows()
			return
	_refresh_rows()


func _select_tab(tab: String) -> void:
	current_tab = tab
	for b in _nav.get_children():
		b.button_pressed = b.text == tab
	_title.text = tab
	_rebuild_rows()


func _rebuild_rows() -> void:
	for c in _rows.get_children():
		c.queue_free()
	if current_tab != "Gear":
		var l := Label.new()
		l.text = "%s: coming in a later build." % current_tab
		_rows.add_child(l)
		return
	_shown_unlocked.clear()
	var next_locked: Dictionary = {}
	for item in gear:
		_shown_unlocked[item["id"]] = Store.is_unlocked(item["id"])
		if _shown_unlocked[item["id"]]:
			_rows.add_child(_make_gear_row(item))
		elif next_locked.is_empty():
			next_locked = item
	if not next_locked.is_empty():
		var l := Label.new()
		l.text = "%s unlocks at %s gold held" % [next_locked["name"], _short(float(next_locked["bracket"]))]
		l.modulate = Color(0.8, 0.8, 0.9)
		_rows.add_child(l)
	_refresh_rows()


func _make_gear_row(item: Dictionary) -> Control:
	var row := PanelContainer.new()
	row.name = item["id"]
	var h := HBoxContainer.new()
	h.name = "H"
	row.add_child(h)
	var text := VBoxContainer.new()
	text.name = "Text"
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(text)
	var name_label := Label.new()
	name_label.name = "Name"
	name_label.add_theme_font_size_override("font_size", 18)
	text.add_child(name_label)
	var effect := Label.new()
	effect.text = item["effect"]
	effect.add_theme_font_size_override("font_size", 12)
	text.add_child(effect)
	var buy := Button.new()
	buy.name = "Buy"
	buy.custom_minimum_size = Vector2(110, 44)
	buy.pressed.connect(_buy.bind(item["id"]))
	h.add_child(buy)
	return row


func _buy(id: String) -> void:
	Store.dispatch(Actions.gear_level_bought(id))


func _refresh_rows() -> void:
	if current_tab != "Gear":
		return
	for item in gear:
		var row := _rows.get_node_or_null(item["id"])
		if row == null:
			continue
		var level := Store.gear_level(item["id"])
		row.get_node("H/Text/Name").text = "%s   Lv.%d" % [item["name"], level]
		var buy: Button = row.get_node("H/Buy")
		var cost := Store.next_level_cost(item["id"])
		var can := Store.can_afford(item["id"])
		buy.text = "%s gold" % _short(cost)
		buy.disabled = not can
		buy.modulate = Color(0.55, 1.0, 0.6) if can else Color(1.0, 0.45, 0.45)


static func _short(v: float) -> String:
	if v < 1000.0:
		return str(int(v))
	var units := ["K", "M", "B", "T"]
	var i := -1
	while v >= 1000.0 and i < units.size() - 1:
		v /= 1000.0
		i += 1
	return "%.1f%s" % [v, units[i]]

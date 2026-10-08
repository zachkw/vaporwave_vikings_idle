## The menu panel: one scene used as the bottom dock in portrait and as the
## drawer in landscape. Placeholder content until the Store exists.
## See docs/game-systems/hud-and-menus.md.
extends PanelContainer

const TABS := ["Gear", "Artefacts", "Unlocks", "Ascension", "Village", "Shop"]

signal close_requested

var gold := 0.0
var levels := {}
var unlocked := {}
var current_tab := "Gear"
var gear: Array = []

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = %Rows
@onready var _nav: HBoxContainer = %Nav
@onready var _close: Button = %Close


func _ready() -> void:
	gear = Content.load_json("res://content/gear.json")
	gear.sort_custom(func(a, b): return int(a["order"]) < int(b["order"]))
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


func set_gold(value: float) -> void:
	gold = value
	# A slot unlocks the first time the wallet reaches its bracket, and stays unlocked.
	var newly := false
	for item in gear:
		if not unlocked.get(item["id"], false) and gold >= float(item["bracket"]):
			unlocked[item["id"]] = true
			newly = true
	if newly:
		_rebuild_rows()
	else:
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
	var next_locked: Dictionary = {}
	for item in gear:
		if unlocked.get(item["id"], false):
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


## Linear level cost: base + step x level. See docs/game-systems/gear-shop.md.
func next_cost(item: Dictionary) -> float:
	return float(item["base_cost"]) + float(item["step"]) * float(levels.get(item["id"], 0))


func _buy(id: String) -> void:
	for item in gear:
		if item["id"] == id and unlocked.get(id, false) and gold >= next_cost(item):
			gold -= next_cost(item)
			levels[id] = int(levels.get(id, 0)) + 1
	_refresh_rows()


func _refresh_rows() -> void:
	if current_tab != "Gear":
		return
	for item in gear:
		var row := _rows.get_node_or_null(item["id"])
		if row == null:
			continue
		var level := int(levels.get(item["id"], 0))
		row.get_node("H/Text/Name").text = "%s   Lv.%d" % [item["name"], level]
		var buy: Button = row.get_node("H/Buy")
		var cost := next_cost(item)
		var can := gold >= cost
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

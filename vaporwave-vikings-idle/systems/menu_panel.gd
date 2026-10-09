## The menu panel: one scene used as the bottom dock in portrait and as the
## drawer in landscape. Reads the Store through selectors and dispatches
## GEAR_LEVEL_BOUGHT; it owns no player state. See docs/game-systems/hud-and-menus.md.
extends PanelContainer

const TABS := ["Gear", "Artefacts", "Unlocks", "Ascension", "Village", "Shop"]

signal close_requested

const BUY_AMOUNTS := ["x1", "x10", "x100", "Max"]

var current_tab := "Gear"
## "x1", "x10", "x100" or "Max": how many levels one tap buys.
var buy_amount := "x1"
var gear: Array = []
var _shown_unlocked := {}

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = %Rows
@onready var _nav: HBoxContainer = %Nav
@onready var _close: Button = %Close
@onready var _amounts: HBoxContainer = %Amounts


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
	for amount in BUY_AMOUNTS:
		var b := Button.new()
		b.text = amount
		b.toggle_mode = true
		b.button_pressed = amount == buy_amount
		b.custom_minimum_size = Vector2(52, 36)
		b.add_theme_font_size_override("font_size", 13)
		b.pressed.connect(_select_amount.bind(amount))
		_amounts.add_child(b)
	_select_tab(current_tab)


func _select_amount(amount: String) -> void:
	buy_amount = amount
	for b in _amounts.get_children():
		b.button_pressed = b.text == amount
	_refresh_rows()


## Levels one tap buys for a slot under the current amount: at least 1 so the
## button can show the price of the next level even when Max is 0.
func levels_to_buy(id: String) -> int:
	match buy_amount:
		"x10": return 10
		"x100": return 100
		"Max": return max(1, Selectors.max_affordable_levels(Store.state, id))
	return 1


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
	_amounts.visible = tab == "Gear"
	_rebuild_rows()


func _rebuild_rows() -> void:
	for c in _rows.get_children():
		# Detach now, not at the end of the frame, so the new rows can reuse the slot ids as names.
		_rows.remove_child(c)
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
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect.modulate = Color(0.85, 0.85, 0.95)
	text.add_child(effect)
	var buy := Button.new()
	buy.name = "Buy"
	buy.custom_minimum_size = Vector2(120, 48)
	buy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	buy.pressed.connect(_buy.bind(item["id"]))
	h.add_child(buy)
	return row


func _buy(id: String) -> void:
	Store.dispatch(Actions.gear_level_bought(id, levels_to_buy(id)))


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
		var count := levels_to_buy(item["id"])
		var cost := Selectors.level_cost_sum(item["id"], level, count)
		var can := Store.is_unlocked(item["id"]) and Store.gold() >= cost
		buy.text = ("%s gold" % _short(cost)) if count == 1 else ("x%d\n%s gold" % [count, _short(cost)])
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

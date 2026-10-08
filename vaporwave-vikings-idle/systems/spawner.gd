## Fills a streamed-in segment's slots with coins, enemies and boxes, and
## builds drop-in columns. Each segment gets its own seeded random stream.
## See "Pass 4 onwards" in docs/game-systems/level-builder.md.
class_name Spawner
extends RefCounted

const COIN_SCENE := preload("res://scenes/pickups/coin.tscn")
const BOX_SCENE := preload("res://scenes/pickups/ingredient_box.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")

static var _enemies_by_id: Dictionary = {}


static func enemy_data(id: String) -> Dictionary:
	if _enemies_by_id.is_empty():
		for e in Content.load_json("res://content/enemies.json"):
			_enemies_by_id[e["id"]] = e
	return _enemies_by_id.get(id, {})


static func biome_data(id: String) -> Dictionary:
	for b in Content.load_json("res://content/biomes.json"):
		if b["id"] == id:
			return b
	return {}


## Fills one segment. `index` is the segment's position in the track.
static func fill(segment: Node2D, meta: Dictionary, biome_id: String, level_seed: int, index: int, block_px: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([level_seed, index, "spawn"])
	var economy: Dictionary = Content.load_json("res://content/economy.json")
	var biome := biome_data(biome_id)
	var slots: Dictionary = meta.get("slots", {})
	var placed := {"coins": 0, "enemies": 0, "boxes": 0}
	var holder := Node2D.new()
	holder.name = "Spawned"
	segment.add_child(holder)

	# Coins: each coin line fills with the economy's chance.
	for line in slots.get("coin_lines", []):
		if rng.randf() > float(economy["coin_line_fill"]):
			continue
		for b in range(int(line["from"]), int(line["to"])):
			var coin := COIN_SCENE.instantiate()
			coin.position = Vector2((b + 0.5) * block_px, -(float(line["row"]) + 0.5) * block_px)
			holder.add_child(coin)
			placed["coins"] += 1

	# Basic packs: a run of neighbouring ground slots becomes a pack.
	var basics: Array = biome.get("basic", [])
	if not basics.is_empty():
		for b in slots.get("ground", []):
			var id: String = basics[rng.randi() % basics.size()]
			_spawn_enemy(holder, id, Vector2((int(b) + 0.5) * block_px, -float(meta["entry_row"]) * block_px))
			placed["enemies"] += 1

	# Elite or boss in the elite slot.
	if slots.get("elite") != null:
		var is_boss: bool = meta.get("flags", []).has("boss_arena")
		var id: String = biome.get("boss", "") if is_boss else biome.get("elite", [""])[0]
		if id != "":
			_spawn_enemy(holder, id, Vector2((int(slots["elite"]) + 0.5) * block_px, -float(meta["entry_row"]) * block_px))
			placed["enemies"] += 1

	# Dimensional flyers in air slots while their dimension is active.
	for effect in Store.state.get("effects", []):
		var ing := Selectors.ingredient(effect["id"])
		if ing.is_empty() or not ing["works_in"].has(biome_id):
			continue
		for air in slots.get("air", []):
			if rng.randf() > float(ing.get("air_fill", 0.0)):
				continue
			var id: String = ing["reveals"][rng.randi() % ing["reveals"].size()]
			_spawn_enemy(holder, id, Vector2((int(air["block"]) + 0.5) * block_px, -float(air["row"]) * block_px))
			placed["enemies"] += 1

	# Ingredient box, only with an unlocked ingredient found in this biome.
	if slots.get("box") != null and rng.randf() <= float(economy["box_fill"]):
		var unlocked: Array = Store.state["unlocks"]["ingredients"]
		var options: Array = []
		for ing_id in biome.get("ingredients", []):
			if unlocked.has(ing_id):
				options.append(ing_id)
		if not options.is_empty():
			var box := BOX_SCENE.instantiate()
			box.ingredient_id = options[rng.randi() % options.size()]
			var slot: Dictionary = slots["box"]
			box.position = Vector2((int(slot["block"]) + 0.5) * block_px, -(float(slot["row"]) + 0.5) * block_px)
			holder.add_child(box)
			placed["boxes"] += 1
	return placed


## The air column the Viking falls through on a drop-in: nothing, coins or enemies.
static func drop_in_column(parent: Node2D, world_x: float, top_y: float, floor_y: float, biome_id: String, seed: int, block_px: float) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var chances: Dictionary = Content.load_json("res://content/economy.json")["drop_in"]
	var roll := rng.randf()
	if roll < float(chances["nothing"]):
		return "nothing"
	var holder := Node2D.new()
	holder.name = "DropIn"
	parent.add_child(holder)
	if roll < float(chances["nothing"]) + float(chances["coins"]):
		var y := top_y + block_px
		while y < floor_y - 2.0 * block_px:
			var coin := COIN_SCENE.instantiate()
			coin.from_sky = true
			coin.position = Vector2(world_x, y)
			holder.add_child(coin)
			y += block_px
		return "coins"
	var basics: Array = biome_data(biome_id).get("basic", [])
	if basics.is_empty():
		return "nothing"
	for i in 2:
		_spawn_enemy(holder, basics[rng.randi() % basics.size()], Vector2(world_x, top_y + (4 + i * 3) * block_px))
	return "enemies"


static func _spawn_enemy(parent: Node, id: String, pos: Vector2) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(enemy_data(id))
	enemy.position = pos
	parent.add_child(enemy)
	return enemy

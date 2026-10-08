## Loads JSON content tables. See docs/game-systems/content-data.md.
class_name Content
extends RefCounted

static var _cache: Dictionary = {}


static func load_json(path: String) -> Variant:
	if _cache.has(path):
		return _cache[path]
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Content: cannot open %s" % path)
		return null
	var data: Variant = JSON.parse_string(file.get_as_text())
	if data == null:
		push_error("Content: invalid JSON in %s" % path)
	_cache[path] = data
	return data

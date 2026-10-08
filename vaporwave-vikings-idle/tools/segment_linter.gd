## Checks a segment library before it ships. See "Library linter" in
## docs/game-systems/level-builder.md. Returns a list of error strings.
class_name SegmentLinter
extends RefCounted

const MAX_RISE_BLOCKS := 3
const MAX_GAP_BLOCKS := 4


static func lint(library: Array) -> Array:
	var errors: Array = []
	if library.is_empty():
		return ["library is empty"]
	var ids := {}
	var has_start := false
	for seg in library:
		var id: String = seg.get("id", "")
		if id == "" or ids.has(id):
			errors.append("missing or duplicate id: '%s'" % id)
		ids[id] = true
		var width := int(seg.get("width", 0))
		if width <= 0:
			errors.append("%s: width must be positive" % id)
		for key in ["entry_row", "exit_row"]:
			var row := int(seg.get(key, -1))
			if row < LevelBuilder.MIN_ROW or row > LevelBuilder.MAX_ROW:
				errors.append("%s: %s %d outside rows %d to %d" % [id, key, row, LevelBuilder.MIN_ROW, LevelBuilder.MAX_ROW])
		if seg.get("roles", []).has("start"):
			has_start = true
		for pit in seg.get("pits", []):
			var a := int(pit[0])
			var b := int(pit[1])
			if a <= 0 or b >= width or b <= a:
				errors.append("%s: pit %s must sit inside the segment" % [id, str(pit)])
			elif b - a > MAX_GAP_BLOCKS:
				errors.append("%s: pit %s wider than %d blocks" % [id, str(pit), MAX_GAP_BLOCKS])
		for plat in seg.get("platforms", []):
			var rise := int(plat["top_row"]) - int(seg.get("entry_row", 0))
			if rise > MAX_RISE_BLOCKS:
				errors.append("%s: platform %s is %d rows above the floor (max %d)" % [id, str(plat), rise, MAX_RISE_BLOCKS])
			if int(plat["from"]) < 0 or int(plat["to"]) > width:
				errors.append("%s: platform %s outside the segment" % [id, str(plat)])
	if not has_start:
		errors.append("no segment has the 'start' role")
	# Every exit row must have a segment that can follow it.
	for seg in library:
		var exit_row := int(seg.get("exit_row", -1))
		var followed := false
		for other in library:
			if LevelBuilder.seam_ok(exit_row, int(other.get("entry_row", -99))):
				followed = true
				break
		if not followed:
			errors.append("%s: nothing can follow exit row %d" % [seg.get("id", "?"), exit_row])
	return errors

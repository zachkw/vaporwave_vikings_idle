## Device save: the whole state as JSON, written at every checkpoint and when
## the app goes to the background or closes. Atomic write with a backup, so a
## crash mid-write cannot corrupt the save. See the state store spec.
extends Node

const SAVE_PATH := "user://save.json"
const TEMP_PATH := "user://save.json.tmp"
const BACKUP_PATH := "user://save.json.bak"

var enabled := true
var saves := 0


func _ready() -> void:
	Store.checkpoint.connect(func(_reason: String) -> void: save())
	get_tree().auto_accept_quit = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			save()
		NOTIFICATION_WM_CLOSE_REQUEST:
			save()
			get_tree().quit()


func save(path: String = SAVE_PATH) -> bool:
	if not enabled:
		return false
	var temp := path + ".tmp"
	var backup := path + ".bak"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_error("Save: cannot write %s" % temp)
		return false
	file.store_string(JSON.stringify(Store.state, "", false))
	file.close()
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, backup)
	var err := DirAccess.rename_absolute(temp, path)
	if err != OK:
		push_error("Save: rename failed (%d)" % err)
		return false
	saves += 1
	return true


## Loads the save (or its backup) into the Store. Returns true if anything loaded.
func load(path: String = SAVE_PATH) -> bool:
	for candidate in [path, path + ".bak"]:
		var data := _read(candidate)
		if not data.is_empty():
			Store.dispatch(Actions.state_loaded(migrate(data)))
			return true
	return false


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var data: Variant = JSON.parse_string(file.get_as_text())
	return data if data is Dictionary else {}


## Brings an older save up to the current format. Fills any slice or key a
## newer build added, so old saves keep working.
static func migrate(data: Dictionary) -> Dictionary:
	var fresh := InitialState.make()
	var merged := _merge_missing(fresh, data)
	merged["meta"]["save_format"] = InitialState.SAVE_FORMAT
	return merged


static func _merge_missing(template: Dictionary, saved: Dictionary) -> Dictionary:
	var out := saved.duplicate(true)
	for key in template:
		if not out.has(key):
			out[key] = template[key]
		elif template[key] is Dictionary and out[key] is Dictionary:
			out[key] = _merge_missing(template[key], out[key])
	return out

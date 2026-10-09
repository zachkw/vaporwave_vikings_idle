## The sync client: guest sign-in, then POST /api/v1/sync with every queued
## batch, no more than once every couple of minutes, plus on launch and when
## the app goes to the background. Offline, the queue just waits. The three
## answers go into the Store as actions; a conflict fetches the server copy.
## See docs/technical/state-store-spec.md ("When it sends") and validation.md.
extends Node

signal synced(result: String, response: Dictionary)
signal sync_failed(reason: String)
## Another device has synced since this one; the server copy is attached (T4 is open).
signal conflict(server_state: Dictionary)

const SESSION_PATH := "user://session.json"

var enabled := true
var base_url := ""
var token := ""
var min_interval_s := 120.0
var last_attempt_at := -INF
var busy := false
var last_result := ""
var last_error := ""
var syncs := 0
## Kept until the server answers, so a retry after a dropped reply is idempotent.
var pending_request_id := ""

## The transport is swappable so tests can fake the server. Signature:
## func(method: String, path: String, body: Dictionary, auth: bool) -> Dictionary
## returning { "status": int, "body": Dictionary } (status 0 = no connection).
var transport: Callable


func _ready() -> void:
	var meta: Dictionary = Content.load_json("res://content/meta.json")
	base_url = String(meta.get("api_base_url", "http://localhost:3000"))
	min_interval_s = float(Content.load_json("res://content/economy.json").get("sync_min_interval_s", 120))
	transport = _http
	_load_session()
	Store.checkpoint.connect(_on_checkpoint)
	# Launch sync, once the save has loaded.
	sync_now.call_deferred("launch")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		sync_now("background")


func _on_checkpoint(_reason: String) -> void:
	if Time.get_ticks_msec() / 1000.0 - last_attempt_at >= min_interval_s:
		sync_now("checkpoint")


func has_queue() -> bool:
	return not Store.queued_batches().is_empty()


## Sends everything queued. Returns the result word, or "" if nothing was sent.
func sync_now(reason: String = "manual") -> String:
	if not enabled or busy:
		return ""
	busy = true
	last_attempt_at = Time.get_ticks_msec() / 1000.0
	var result := await _sync(reason)
	busy = false
	return result


func _sync(reason: String) -> String:
	if token == "":
		if not await _sign_in_guest():
			return _fail("sign_in")
	if not has_queue():
		last_result = "nothing"
		return "nothing"
	if pending_request_id == "":
		pending_request_id = _new_request_id()
	var request := SyncReducer.build_request(Store.state, pending_request_id)
	var reply: Dictionary = await transport.call("POST", "/api/v1/sync", request, true)
	var status := int(reply.get("status", 0))
	if status == 0:
		return _fail("offline")
	if status == 401:
		# The session lapsed; sign in again and let the next attempt resend.
		token = ""
		_save_session()
		return _fail("unauthorised")
	var body: Dictionary = reply.get("body", {})
	var result := String(body.get("result", ""))
	if result == "":
		return _fail("bad_response %d" % status)
	pending_request_id = ""
	match result:
		"accepted":
			Store.dispatch(Actions.sync_accepted(int(body["rev"]), int(body.get("up_to_seq", 0)), String(body.get("server_time", ""))))
		"trimmed":
			Store.dispatch(Actions.sync_trimmed(int(body["rev"]), int(body.get("up_to_seq", 0)), body.get("trims", []), String(body.get("server_time", ""))))
		"rejected":
			var server := await _fetch_state()
			if server.is_empty():
				return _fail("rejected_no_state")
			Store.dispatch(Actions.sync_rejected(Save.migrate(server["state"]), int(server["rev"]), String(body.get("code", ""))))
		"conflict":
			var server := await _fetch_state()
			if server.is_empty():
				return _fail("conflict_no_state")
			var their_device := String(server["state"]["meta"].get("device_id", ""))
			if their_device == Store.state["meta"]["device_id"]:
				# Our own earlier request landed but the reply was lost: catch up and resend the rest.
				Store.dispatch(Actions.sync_accepted(int(server["rev"]), int(server["state"]["sync"].get("last_seq", 0)), String(server.get("server_time", ""))))
				if has_queue():
					return await _sync(reason)
			else:
				conflict.emit(server["state"])
	last_result = result
	syncs += 1
	synced.emit(result, body)
	return result


func _fail(reason: String) -> String:
	last_error = reason
	last_result = "failed"
	sync_failed.emit(reason)
	return "failed"


func _fetch_state() -> Dictionary:
	var reply: Dictionary = await transport.call("GET", "/api/v1/state", {}, true)
	if int(reply.get("status", 0)) != 200:
		return {}
	return reply["body"]


func _sign_in_guest() -> bool:
	var reply: Dictionary = await transport.call("POST", "/api/v1/auth/guest", {}, false)
	if int(reply.get("status", 0)) != 201:
		return false
	token = String(reply["body"]["accessToken"])
	_save_session()
	return true


# ------------------------------------------------------------ transport

func _http(method: String, path: String, body: Dictionary, auth: bool) -> Dictionary:
	var req := HTTPRequest.new()
	req.timeout = 15.0
	add_child(req)
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	if auth:
		headers.append("Authorization: Bearer " + token)
	var verb := HTTPClient.METHOD_GET if method == "GET" else HTTPClient.METHOD_POST
	var err := req.request(base_url + path, headers, verb, "" if method == "GET" else JSON.stringify(body))
	if err != OK:
		req.queue_free()
		return {"status": 0, "body": {}}
	var result: Array = await req.request_completed
	req.queue_free()
	var status := int(result[1])
	if int(result[0]) != HTTPRequest.RESULT_SUCCESS:
		return {"status": 0, "body": {}}
	var parsed = JSON.parse_string(result[3].get_string_from_utf8())
	return {"status": status, "body": parsed if parsed is Dictionary else {}}


# -------------------------------------------------------------- session

func _new_request_id() -> String:
	return "%s-%d-%08x" % [Store.state["meta"]["device_id"], Time.get_unix_time_from_system(), randi()]


func _load_session() -> void:
	if not FileAccess.file_exists(SESSION_PATH):
		return
	var f := FileAccess.open(SESSION_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if data is Dictionary:
		token = String(data.get("access_token", ""))


func _save_session() -> void:
	var f := FileAccess.open(SESSION_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"access_token": token}))

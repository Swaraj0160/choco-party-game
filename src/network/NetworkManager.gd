extends Node

signal player_joined(id, player_info)
signal player_left(id)
signal player_updated(id, player_info)

const PLAYER_COLORS = [
	Color("#FF3B30"), # Red
	Color("#007AFF"), # Blue
	Color("#34C759"), # Green
	Color("#FFCC00"), # Yellow
	Color("#AF52DE"), # Purple
	Color("#FF9500"), # Orange
	Color("#5AC8FA"), # Cyan
	Color("#FF2D55")  # Pink
]

var players = {} # id -> dictionary of player info
var color_index = 0

func _ready():
	ServerManager.phone_connected.connect(_on_phone_connected)
	ServerManager.phone_disconnected.connect(_on_phone_disconnected)
	ServerManager.phone_message_received.connect(_on_phone_message_received)

func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
			if not ip.ends_with(".1") and not ip.ends_with(".255"):
				return ip
	return "127.0.0.1"
	
func get_join_url() -> String:
	return "http://" + get_local_ip() + ":" + str(ServerManager.HTTP_PORT)

func _on_phone_connected(id):
	# Request them to identify/join
	ServerManager.send_message(id, {"type": "request_join"})

func _on_phone_disconnected(id):
	if players.has(id):
		player_left.emit(id)
		players.erase(id)
		ServerManager.broadcast_message({"type": "player_left", "id": id})

func _on_phone_message_received(id, msg):
	if typeof(msg) != TYPE_DICTIONARY or not msg.has("type"):
		return
		
	var type = msg["type"]
	
	match type:
		"join":
			_handle_join(id, msg)
		"ready":
			if players.has(id):
				players[id]["is_ready"] = msg.get("is_ready", true)
				player_updated.emit(id, players[id])
				ServerManager.broadcast_message({"type": "player_updated", "id": id, "info": players[id]})
		"input":
			GameManager.handle_player_input(id, msg.get("action", ""), msg.get("data", {}))

func _handle_join(id, msg):
	var name = msg.get("name", "Player " + str(id)).substr(0, 15)
	
	var color = PLAYER_COLORS[color_index % PLAYER_COLORS.size()].to_html(false)
	color_index += 1
	
	var player_info = {
		"id": id,
		"name": name,
		"color": "#" + color,
		"is_ready": false,
		"score": 0,
		"avatar": msg.get("avatar", "default")
	}
	
	players[id] = player_info
	player_joined.emit(id, player_info)
	
	# Send welcome with their assigned info
	ServerManager.send_message(id, {
		"type": "welcome",
		"id": id,
		"info": player_info,
		"game_state": GameManager.current_state
	})
	
	# Notify others
	ServerManager.broadcast_message({
		"type": "player_joined",
		"id": id,
		"info": player_info
	})
	
	# Send them the current list of players
	for other_id in players:
		if other_id != id:
			ServerManager.send_message(id, {
				"type": "player_joined",
				"id": other_id,
				"info": players[other_id]
			})

func update_player_score(id, delta_score):
	if players.has(id):
		players[id]["score"] += delta_score
		player_updated.emit(id, players[id])
		ServerManager.broadcast_message({"type": "score_update", "id": id, "score": players[id]["score"]})

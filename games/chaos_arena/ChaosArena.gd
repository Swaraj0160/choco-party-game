extends Node3D

var players = {}
var player_scene = preload("res://games/chaos_arena/Player.tscn")

func _ready():
	for id in NetworkManager.players:
		var info = NetworkManager.players[id]
		_spawn_player(id, info)

func _spawn_player(id, info):
	var p = player_scene.instantiate()
	p.name = str(id)
	p.player_id = id
	p.player_info = info
	add_child(p)
	p.global_position = Vector3(randf_range(-4, 4), 5, randf_range(-4, 4))
	players[id] = p

func handle_input(id, action, data):
	if players.has(id):
		players[id].handle_action(action)

var game_timer = 30.0

func _process(delta):
	game_timer -= delta
	if game_timer <= 0:
		set_process(false)
		GameManager.change_state(GameManager.GameState.RESULTS)

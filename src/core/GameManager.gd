extends Node

enum GameState { BOOT, LOBBY, GAME_SELECT, PLAYING, RESULTS }

var current_state = GameState.BOOT
var current_minigame = null

signal state_changed(new_state)

var games_list = [
	"res://games/rhythm_fight/RhythmFight.tscn",
	"res://games/chaos_arena/ChaosArena.tscn",
	"res://games/reaction_rush/ReactionRush.tscn"
]
var current_game_index = 0

func _ready():
	call_deferred("change_state", GameState.LOBBY)
	
func change_state(new_state):
	current_state = new_state
	state_changed.emit(new_state)
	ServerManager.broadcast_message({"type": "state_change", "state": new_state})
	
func handle_player_input(id, action, data):
	if current_state == GameState.PLAYING and current_minigame != null:
		if current_minigame.has_method("handle_input"):
			current_minigame.handle_input(id, action, data)
	elif current_state == GameState.RESULTS:
		if action == "action": # Press action to continue from results
			start_next_game()

func start_next_game():
	current_game_index = (current_game_index + 1) % games_list.size()
	load_minigame(games_list[current_game_index])
	change_state(GameState.PLAYING)

func load_minigame(scene_path: String):
	var root = get_tree().root
	if not root.has_node("Boot/GameContainer"):
		return
		
	var game_container = root.get_node("Boot/GameContainer")
	
	if current_minigame != null:
		current_minigame.queue_free()
		
	var packed_scene = load(scene_path)
	if packed_scene:
		current_minigame = packed_scene.instantiate()
		game_container.add_child(current_minigame)


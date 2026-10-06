extends Node3D

var beatmap: Beatmap
var players = {}
var player_scene = preload("res://games/rhythm_fight/PlayerFighter.tscn")
var hit_window_beats: float = 0.25 # +/- 0.25 beats is a hit

var game_timer = 45.0

func _ready():
	beatmap = Beatmap.new()
	beatmap.generate_simple_4_4_map(16)
	
	RhythmClock.beat_hit.connect(_on_beat_hit)
	
	var i = 0
	var count = NetworkManager.players.size()
	for id in NetworkManager.players:
		var info = NetworkManager.players[id]
		var p = player_scene.instantiate()
		p.player_id = id
		p.player_info = info
		add_child(p)
		
		# Position in a line
		var spacing = 3.0
		var offset = (count - 1) * spacing / 2.0
		p.global_position = Vector3((i * spacing) - offset, 0, 0)
		players[id] = p
		i += 1
		
		# Send layout change to phone
		ServerManager.send_message(id, {"type": "change_controller", "layout": "rhythm"})
		
	# Temporary: just use a sine wave or placeholder for audio if no stream is provided
	RhythmClock.bpm = 120.0
	RhythmClock.start()

func _on_beat_hit(beat):
	# Environment pulses
	$Camera3D.position.y = 5.2
	var tween = create_tween()
	tween.tween_property($Camera3D, "position:y", 5.0, 0.1)

func handle_input(id, action, data):
	if not RhythmClock.is_playing: return
	if not players.has(id): return
	
	var pos_sec = RhythmClock.get_song_position()
	var beat_duration = RhythmClock.get_beat_duration()
	var current_beat = pos_sec / beat_duration
	
	var closest_event = null
	var min_dist = 999.0
	
	for e in beatmap.events:
		var dist = abs(e.beat - current_beat)
		if dist < min_dist:
			min_dist = dist
			closest_event = e
			
	if min_dist <= hit_window_beats:
		var accuracy = 1.0 - (min_dist / hit_window_beats)
		var rating = "good"
		if accuracy > 0.8: rating = "perfect"
		elif accuracy > 0.5: rating = "great"
		
		players[id].do_attack(action, rating)
		NetworkManager.update_player_score(id, int(accuracy * 10))
		ServerManager.send_message(id, {"type": "hit_feedback", "rating": rating})
	else:
		players[id].do_miss()
		ServerManager.send_message(id, {"type": "hit_feedback", "rating": "miss"})

func _process(delta):
	game_timer -= delta
	if game_timer <= 0:
		set_process(false)
		RhythmClock.stop()
		RhythmClock.beat_hit.disconnect(_on_beat_hit)
		# Send controllers back to normal
		for id in NetworkManager.players:
			ServerManager.send_message(id, {"type": "change_controller", "layout": "default"})
		GameManager.change_state(GameManager.GameState.RESULTS)

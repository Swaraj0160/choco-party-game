extends Control

@onready var state_label = $VBoxContainer/StateLabel
@onready var join_label = $VBoxContainer/JoinLabel
@onready var players_container = $VBoxContainer/PlayersContainer
@onready var qr_texture_rect = $VBoxContainer/QRTextureRect

func _ready():
	GameManager.state_changed.connect(_on_state_changed)
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.player_updated.connect(_on_player_updated)
	
	_on_state_changed(GameManager.current_state)
	
	var join_url = NetworkManager.get_join_url()
	join_label.text = "JOIN AT: " + join_url
	_load_qr_code(join_url)

func _on_state_changed(state):
	match state:
		GameManager.GameState.LOBBY:
			state_label.text = "LOBBY - WAITING FOR PLAYERS"
			$VBoxContainer.show()
			$ResultsContainer.hide()
		GameManager.GameState.PLAYING:
			$VBoxContainer.hide()
			$ResultsContainer.hide()
			if GameManager.current_minigame == null:
				GameManager.start_next_game()
		GameManager.GameState.RESULTS:
			$VBoxContainer.hide()
			$ResultsContainer.show()
			if GameManager.current_minigame:
				GameManager.current_minigame.queue_free()
				GameManager.current_minigame = null
			_update_results_ui()

func _load_qr_code(url: String):
	# Try to fetch QR code from internet
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_qr_fetched)
	http_request.request("https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=" + url.uri_encode())

func _on_qr_fetched(result, response_code, headers, body):
	if response_code == 200:
		var image = Image.new()
		var err = image.load_png_from_buffer(body)
		if err == OK:
			var texture = ImageTexture.create_from_image(image)
			qr_texture_rect.texture = texture

func _on_player_joined(id, info):
	_update_players_ui()

func _on_player_left(id):
	_update_players_ui()

func _on_player_updated(id, info):
	_update_players_ui()
	
	# Check if all ready
	if GameManager.current_state == GameManager.GameState.LOBBY and NetworkManager.players.size() > 0:
		var all_ready = true
		for pid in NetworkManager.players:
			if not NetworkManager.players[pid].get("is_ready", false):
				all_ready = false
		
		if all_ready:
			# START GAME
			print("All players ready! Starting game.")
			GameManager.change_state(GameManager.GameState.PLAYING)

func _update_players_ui():
	for child in players_container.get_children():
		child.queue_free()
		
	for id in NetworkManager.players:
		var info = NetworkManager.players[id]
		var label = Label.new()
		label.text = info["name"] + (" (READY)" if info.get("is_ready") else " (NOT READY)")
		label.add_theme_color_override("font_color", Color(info["color"]))
		players_container.add_child(label)

func _update_results_ui():
	var rc = $ResultsContainer/VBoxContainer/ScoreList
	for child in rc.get_children():
		child.queue_free()
	
	var sorted_players = []
	for id in NetworkManager.players:
		sorted_players.append(NetworkManager.players[id])
	
	sorted_players.sort_custom(func(a, b): return a.get("score", 0) > b.get("score", 0))
	
	for p in sorted_players:
		var label = Label.new()
		label.text = p["name"] + " - " + str(p.get("score", 0)) + " PTS"
		label.add_theme_font_size_override("font_size", 32)
		label.add_theme_color_override("font_color", Color(p["color"]))
		rc.add_child(label)

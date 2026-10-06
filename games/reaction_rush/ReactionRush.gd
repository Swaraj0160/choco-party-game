extends Control

var current_target = ""
var target_active = false
var scores = {}

func _ready():
	for id in NetworkManager.players:
		scores[id] = 0
	_next_round()

func _next_round():
	target_active = false
	$CenterContainer/Label.text = "GET READY..."
	$CenterContainer/Label.add_theme_color_override("font_color", Color.WHITE)
	
	var t = Timer.new()
	t.wait_time = randf_range(2.0, 5.0)
	t.one_shot = true
	add_child(t)
	t.start()
	t.timeout.connect(_on_ready_timeout)

func _on_ready_timeout():
	current_target = ["up", "down", "left", "right", "action"][randi() % 5]
	target_active = true
	$CenterContainer/Label.text = "PRESS: " + current_target.to_upper()
	$CenterContainer/Label.add_theme_color_override("font_color", Color.RED)

func handle_input(id, action, data):
	if target_active and action == current_target:
		target_active = false
		scores[id] += 1
		NetworkManager.update_player_score(id, 1)
		$CenterContainer/Label.text = NetworkManager.players[id]["name"] + " WINS ROUND!"
		$CenterContainer/Label.add_theme_color_override("font_color", Color(NetworkManager.players[id]["color"]))
		
		var t = Timer.new()
		t.wait_time = 2.0
		t.one_shot = true
		add_child(t)
		t.start()
		t.timeout.connect(func():
			if scores[id] >= 3:
				$CenterContainer/Label.text = NetworkManager.players[id]["name"] + " WINS GAME!"
				var t2 = Timer.new()
				t2.wait_time = 3.0
				t2.one_shot = true
				add_child(t2)
				t2.start()
				t2.timeout.connect(func(): GameManager.change_state(GameManager.GameState.RESULTS))
			else:
				_next_round()
		)

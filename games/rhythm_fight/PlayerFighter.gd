extends Node3D

var player_id = -1
var player_info = {}

func _ready():
	if player_info.has("color"):
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(player_info["color"])
		mat.emission_enabled = true
		mat.emission = Color(player_info["color"]) * 0.5
		$MeshInstance3D.set_surface_override_material(0, mat)

func do_attack(action, rating):
	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.5, 1.5, 1.5), 0.05)
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.15)

func do_miss():
	var tween = create_tween()
	var orig_x = $MeshInstance3D.position.x
	tween.tween_property($MeshInstance3D, "position:x", orig_x + 0.5, 0.05)
	tween.tween_property($MeshInstance3D, "position:x", orig_x - 0.5, 0.05)
	tween.tween_property($MeshInstance3D, "position:x", orig_x, 0.05)

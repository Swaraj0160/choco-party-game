extends RigidBody3D

var player_id = -1
var player_info = {}
var move_force = 15.0
var jump_force = 15.0

func _ready():
	if player_info.has("color"):
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(player_info["color"])
		$MeshInstance3D.set_surface_override_material(0, mat)

func handle_action(action: String):
	match action:
		"up":
			apply_central_impulse(Vector3(0, 0, -move_force))
		"down":
			apply_central_impulse(Vector3(0, 0, move_force))
		"left":
			apply_central_impulse(Vector3(-move_force, 0, 0))
		"right":
			apply_central_impulse(Vector3(move_force, 0, 0))
		"action":
			if linear_velocity.y > -0.1 and linear_velocity.y < 0.1:
				apply_central_impulse(Vector3(0, jump_force, 0))

func _physics_process(delta):
	if global_position.y < -10:
		# Player fell off
		global_position = Vector3(0, 10, 0)
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		# NetworkManager.update_player_score(player_id, -1)

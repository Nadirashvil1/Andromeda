extends Node3D

var sensitivity = 0.2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Don't process camera if inspecting
	if InspectManager.is_inspecting:
		return
	
	if event is InputEventMouseMotion:
		var delta_x = clamp(event.relative.x, -50, 50)
		var delta_y = clamp(event.relative.y, -50, 50)
		
		get_parent().rotate_y(deg_to_rad(-delta_x * sensitivity))
		rotate_x(deg_to_rad(-delta_y * sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		get_viewport().set_input_as_handled()

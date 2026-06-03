extends Node

var is_inspecting = false
var current_item = null
var player_node = null
var cam: Camera3D = null
var is_dragging = false
var original_position: Vector3
var original_rotation: Vector3
var original_parent: Node

func start_inspect(item: Node3D):
	is_inspecting = true
	current_item = item
	
	cam = get_viewport().get_camera_3d()
	
	player_node = get_tree().get_first_node_in_group("player")
	player_node.set_process_input(false)
	player_node.set_physics_process(false)
	
	original_position = item.global_position
	original_rotation = item.global_rotation
	original_parent = item.get_parent()
	
	# Calculate target position in front of camera in world space
	var target_pos = cam.global_position + (-cam.global_basis.z * 1.0)
	
	# Smoothly move to front of camera in world space
	var tween = get_tree().create_tween()
	tween.tween_property(item, "global_position", target_pos, 0.4)
	tween.parallel().tween_property(item, "rotation", Vector3(0, 0, 0), 0.4)
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Close  [ Hold LMB ] Rotate"
	label.visible = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func stop_inspect():
	is_inspecting = false
	is_dragging = false
	
	# Smoothly move back to original position
	var tween = get_tree().create_tween()
	tween.tween_property(current_item, "global_position", original_position, 0.4)
	tween.parallel().tween_property(current_item, "rotation", original_rotation, 0.4)
	
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Inspect"
	label.visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_item = null

func _input(event):
	if not is_inspecting:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
	
	if event is InputEventMouseMotion and is_dragging:
		current_item.rotate_y(deg_to_rad(event.relative.x * 0.5))
		current_item.rotate_x(deg_to_rad(event.relative.y * 0.5))
	
	if event.is_action_pressed("interact"):
		stop_inspect()

func _process(delta):
	pass

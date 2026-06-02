extends Node

var is_inspecting = false
var current_item = null
var inspect_pivot: Node3D
var player_node = null
var cam: Camera3D = null
var is_dragging = false

func start_inspect(item: Node3D):
	is_inspecting = true
	current_item = item
	
	# Get camera
	cam = get_viewport().get_camera_3d()
	
	# Freeze player completely
	player_node = get_tree().get_first_node_in_group("player")
	player_node.set_process_input(false)
	player_node.set_physics_process(false)
	
	# Hide original item
	item.visible = false
	
	# Create pivot in front of camera
	inspect_pivot = Node3D.new()
	get_tree().current_scene.add_child(inspect_pivot)
	
	# Position it in front of camera and keep it there
	inspect_pivot.global_position = cam.global_position + (-cam.global_basis.z * 1.5)
	inspect_pivot.global_rotation = Vector3.ZERO
	
	# Add display copy
	var display = item.duplicate()
	display.visible = true
	display.position = Vector3.ZERO
	display.rotation = Vector3.ZERO
	inspect_pivot.add_child(display)
	
	# Update label
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Close  [ Hold LMB ] Rotate"
	label.visible = true
	
	# Show cursor so player can click
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func stop_inspect():
	is_inspecting = false
	is_dragging = false
	current_item.visible = true
	inspect_pivot.queue_free()
	inspect_pivot = null
	
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Inspect"
	label.visible = false
	
	# Recapture mouse for player look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_inspecting:
		return
	
	# Left mouse button to start/stop dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
	
	# Only rotate when holding left mouse button
	if event is InputEventMouseMotion and is_dragging:
		inspect_pivot.rotate_y(deg_to_rad(event.relative.x * 0.5))
		inspect_pivot.rotate_x(deg_to_rad(event.relative.y * 0.5))
	
	# Close inspect with E
	if event.is_action_pressed("interact"):
		stop_inspect()

func _process(delta):
	if not is_inspecting or not inspect_pivot or not cam:
		return
	# Keep item locked in front of camera
	inspect_pivot.global_position = cam.global_position + (-cam.global_basis.z * 1.5)

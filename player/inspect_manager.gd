extends Node

var is_inspecting = false
var current_item = null
var inspect_pivot: Node3D
var original_position: Vector3
var player_node = null

func start_inspect(item: Node3D):
	is_inspecting = true
	current_item = item
	
	# Freeze player
	player_node = get_tree().get_first_node_in_group("player")
	player_node.set_process_input(false)
	player_node.set_physics_process(false)
	
	# Hide original sword in world
	item.visible = false
	
	# Create a display copy in front of camera
	inspect_pivot = Node3D.new()
	get_tree().current_scene.add_child(inspect_pivot)
	
	var cam = get_viewport().get_camera_3d()
	inspect_pivot.global_position = cam.global_position + (-cam.global_basis.z * 1.5)
	
	var display = item.duplicate()
	display.visible = true
	display.position = Vector3.ZERO
	inspect_pivot.add_child(display)
	
	# Show exit hint
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Close    [ Mouse ] Rotate"
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func stop_inspect():
	is_inspecting = false
	current_item.visible = true
	inspect_pivot.queue_free()
	
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ E ] Inspect"
	label.visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_inspecting:
		return
	
	# Rotate with mouse
	if event is InputEventMouseMotion:
		inspect_pivot.rotate_y(deg_to_rad(event.relative.x * 0.5))
		inspect_pivot.rotate_x(deg_to_rad(event.relative.y * 0.5))
	
	# Close inspect
	if event.is_action_pressed("interact"):
		stop_inspect()

func _process(delta):
	if not is_inspecting or not inspect_pivot:
		return
	# Keep item in front of camera as player looks around
	var cam = get_viewport().get_camera_3d()
	inspect_pivot.global_position = cam.global_position + (-cam.global_basis.z * 1.5)

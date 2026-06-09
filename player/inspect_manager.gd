extends Node

var is_inspecting = false
var current_item = null
var player_node = null
var cam: Camera3D = null
var head_node = null
var is_dragging = false
var original_position: Vector3
var original_rotation: Vector3
var original_player_rotation: Vector3
var original_head_rotation: Vector3
var crosshair = null
var blur_overlay: ColorRect = null

func start_inspect(item: Node3D):
	is_inspecting = true
	current_item = item
	
	cam = get_viewport().get_camera_3d()
	head_node = cam.get_parent()
	
	player_node = get_tree().get_first_node_in_group("player")
	player_node.set_process_input(false)
	player_node.set_physics_process(false)
	
	# Save everything
	original_position = item.global_position
	original_rotation = item.global_rotation
	original_player_rotation = player_node.global_rotation
	original_head_rotation = head_node.global_rotation
	
	# Hide crosshair
	crosshair = get_tree().current_scene.get_node("CanvasLayer/Crosshair")
	if crosshair:
		crosshair.visible = false
	
	# Fade in blur overlay
	blur_overlay = get_tree().current_scene.get_node_or_null("CanvasLayer/BlurOverlay")
	if blur_overlay:
		var tween_blur = get_tree().create_tween()
		tween_blur.tween_property(blur_overlay, "color", Color(0, 0, 0, 0.5), 0.4)
	
	# Show info panel
	var info_panel = get_tree().current_scene.get_node("CanvasLayer/InfoPanel")
	var item_name_label = get_tree().current_scene.get_node("CanvasLayer/InfoPanel/VBoxContainer/ItemName")
	var item_desc_label = get_tree().current_scene.get_node("CanvasLayer/InfoPanel/VBoxContainer/ItemDescription")
	item_name_label.text = item.item_name
	item_desc_label.text = item.item_description
	info_panel.visible = true
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.visible = true
	
	if item.inspect_type == "pin":
		label.text = "[ E ] Close"
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Camera stays, player is just frozen
	else:
		label.text = "[ E ] Close  [ Hold LMB ] Rotate"
		var target_pos = cam.global_position + (cam.global_transform.basis * Vector3(0, 0, -1))
		var tween = get_tree().create_tween()
		tween.tween_property(item, "global_position", target_pos, 0.4)
		tween.parallel().tween_property(item, "rotation", Vector3(0, 0, 0), 0.4)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	


func stop_inspect():
	is_inspecting = false
	is_dragging = false
	
	# Restore player and head rotations exactly
	player_node.global_rotation = original_player_rotation
	head_node.global_rotation = original_head_rotation
	
	# Show crosshair
	if crosshair:
		crosshair.visible = true
	
	# Fade out blur
	if blur_overlay:
		var tween_blur = get_tree().create_tween()
		tween_blur.tween_property(blur_overlay, "color", Color(0, 0, 0, 0), 0.4)
	
	# Hide info panel
	var info_panel = get_tree().current_scene.get_node("CanvasLayer/InfoPanel")
	info_panel.visible = false
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ Hold E ] Inspect"
	label.visible = false
	
	if current_item.inspect_type == "move":
		var tween = get_tree().create_tween()
		tween.tween_property(current_item, "global_position", original_position, 0.4)
		tween.parallel().tween_property(current_item, "rotation", original_rotation, 0.4)
	
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_item = null

func _input(event):
	if not is_inspecting:
		return
	
	# Block all mouse motion from reaching fp_cam
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		
		# Only rotate move items when dragging
		if current_item and current_item.inspect_type == "move" and is_dragging:
			current_item.rotate_y(deg_to_rad(event.relative.x * 0.5))
			current_item.rotate_x(deg_to_rad(event.relative.y * 0.5))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
	
	if event is InputEventKey:
		if event.is_action_pressed("interact"):
			stop_inspect()

func _process(delta):
	pass

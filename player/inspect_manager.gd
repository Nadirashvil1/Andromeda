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
var equipped_item : Node3D = null
func start_inspect(item: Node3D):
	is_inspecting = true
	current_item = item
	
	cam = get_viewport().get_camera_3d()
	head_node = cam.get_parent()
	
	player_node = get_tree().get_first_node_in_group("player")
	player_node.set_process_input(false)
	player_node.set_physics_process(false)
	
	original_position = item.global_position
	original_rotation = item.global_rotation
	original_player_rotation = player_node.global_rotation
	original_head_rotation = head_node.global_rotation
	
	# Hide crosshair
	crosshair = get_tree().current_scene.get_node("CanvasLayer/Crosshair")
	if crosshair:
		crosshair.visible = false
	
	# Show info panel
	var info_panel = get_tree().current_scene.get_node("CanvasLayer/InfoPanel")
	var item_name_label = get_tree().current_scene.get_node("CanvasLayer/InfoPanel/VBoxContainer/ItemName")
	var item_desc_label = get_tree().current_scene.get_node("CanvasLayer/InfoPanel/VBoxContainer/ItemDescription")
	item_name_label.text = item.item_name
	item_desc_label.text = item.item_description
	info_panel.visible = true
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.visible = true
	
	var equip_hint = "  [ G ] Equip " if item.is_in_group("equippable") else ""
	
	if item.inspect_type == "pin":
		label.text = "[ E ] Close" + equip_hint
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# Show correct hint based on whether item is readable
		if item.is_readable:
			label.text = "[ E ] Close  [ F ] Read" + equip_hint
		else:
			label.text = "[ E ] Close  [ Hold LMB ] Rotate" + equip_hint
		
		var target_pos = cam.global_position + (cam.global_transform.basis * Vector3(0, 0, -item.inspect_distance))
		var tween = get_tree().create_tween()
		tween.tween_property(item, "global_position", target_pos, 0.4)
		tween.parallel().tween_property(item, "rotation", Vector3(0, 0, 0), 0.4)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func stop_inspect(is_equipping = false):
	# Close read panel first if open
	var read_panel = get_tree().current_scene.get_node_or_null("CanvasLayer/ReadPanel")
	if read_panel and read_panel.visible:
		read_panel.visible = false
		return
	
	is_inspecting = false
	is_dragging = false
	
	player_node.global_rotation = original_player_rotation
	head_node.global_rotation = original_head_rotation
	
	if crosshair:
		crosshair.visible = true
	
	var info_panel = get_tree().current_scene.get_node("CanvasLayer/InfoPanel")
	info_panel.visible = false
	
	var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
	label.text = "[ Hold E ] Inspect"
	label.visible = false
	
	if current_item.inspect_type == "move" and not is_equipping:
		var tween = get_tree().create_tween()
		tween.tween_property(current_item, "global_position", original_position, 0.4)
		tween.parallel().tween_property(current_item, "rotation", original_rotation, 0.4)
	
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if not is_equipping:
		current_item = null

func _toggle_read_panel():
	var panel = get_tree().current_scene.get_node("CanvasLayer/ReadPanel")
	if panel.visible:
		panel.visible = false
		# Restore inspect hint
		var equip_hint = "  [ G ] Equip" if current_item.is_in_group("equippable") else ""
		var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
		label.text = "[ E ] Close  [ F ] Read" + equip_hint
	else:
		var read_text = get_tree().current_scene.get_node("CanvasLayer/ReadPanel/VBoxContainer/ReadText")
		var read_hints = get_tree().current_scene.get_node("CanvasLayer/ReadPanel/VBoxContainer/ReadHints")
		read_text.text = current_item.readable_text
		read_hints.text = "[ F ] Close"
		panel.visible = true
		# Update hint while reading
		var label = get_tree().current_scene.get_node("CanvasLayer/InteractLabel")
		label.visible = false

func _is_reading():
	var panel = get_tree().current_scene.get_node_or_null("CanvasLayer/ReadPanel")
	return panel != null and panel.visible

func equip_current_item():
	var item_to_equip = current_item
	var active_tweens = get_tree().get_processed_tweens()
	for t in active_tweens:
		if t.is_valid():
			t.kill()
	stop_inspect(true)
	
	var equip_slot = head_node.get_node_or_null("EquipSlot")
	
	if equip_slot:
		item_to_equip.get_parent().remove_child(item_to_equip)
		equip_slot.add_child(item_to_equip)
		item_to_equip.position = Vector3.ZERO
		item_to_equip.rotation = Vector3.ZERO
		
		for child in item_to_equip.find_children("*", "CollisionShape3D", true, false):
			child.set_deferred("disabled", true)
		
		if item_to_equip is RigidBody3D:
			item_to_equip.freeze = true
		
		equipped_item = item_to_equip
	else:
		print("Error: Could not Find 'EquipSlot' on the player's head node!")
	current_item = null
func _input(event):
	if not is_inspecting:
		return
	
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		if current_item and current_item.inspect_type == "move" and is_dragging and not _is_reading():
			current_item.rotate_y(deg_to_rad(event.relative.x * 0.5))
			current_item.rotate_x(deg_to_rad(event.relative.y * 0.5))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
	
	if event is InputEventKey:
		if event.is_action_pressed("read"):
			if current_item and current_item.is_readable:
				_toggle_read_panel()
		elif event.is_action_pressed("interact"):
			if not _is_reading():
				stop_inspect()
		elif event.is_action_pressed("equip"):
			if current_item and current_item.is_in_group("equippable") and not _is_reading():
				equip_current_item()
	 
func _process(delta):
	pass

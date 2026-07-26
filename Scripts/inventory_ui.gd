extends Control

const CELL_SIZE = 64
const GRID_W = 8
const GRID_H = 6
const CLICK_THRESHOLD = 6.0

var background: ColorRect
var player_node: Node = null
var icon_nodes: Dictionary = {}
var dragging_id = null
var press_start_pos: Vector2

func _ready():
	InventoryManager.inventory_changed.connect(_refresh)
	visible = false

	var panel_size = Vector2(GRID_W, GRID_H) * CELL_SIZE
	position = (get_viewport_rect().size - panel_size) / 2.0

	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.75)
	background.position = Vector2.ZERO
	background.size = panel_size
	add_child(background)
	background.z_index = -1

	player_node = get_tree().get_first_node_in_group("player")

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if not InventoryManager.is_open and InspectManager.is_inspecting:
			return

		InventoryManager.is_open = not InventoryManager.is_open
		visible = InventoryManager.is_open

		if InventoryManager.is_open:
			_refresh()
			player_node.set_process_input(false)
			player_node.set_physics_process(false)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			player_node.set_process_input(true)
			player_node.set_physics_process(true)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if visible and dragging_id != null and event is InputEventMouseMotion:
		var icon = icon_nodes.get(dragging_id)
		if icon:
			icon.position = get_local_mouse_position() - icon.size / 2.0

func _refresh():
	for child in get_children():
		if child != background and child.name != "ItemActionMenu":
			child.queue_free()
	for item_id in InventoryManager.items:
		var data = InventoryManager.items[item_id]
		var icon_rect = TextureRect.new()
		icon_rect.texture = data.icon
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.position = Vector2(data.grid_pos.x, data.grid_pos.y) * CELL_SIZE
		icon_rect.size = Vector2(data.width, data.height) * CELL_SIZE
		icon_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		icon_rect.gui_input.connect(_on_icon_gui_input.bind(item_id))
		add_child(icon_rect)
		icon_nodes[item_id] = icon_rect
		
func _on_icon_gui_input(event, item_id):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("press on ", item_id)
			dragging_id = item_id
			press_start_pos = event.position
			icon_nodes[item_id].z_index = 10
		elif dragging_id == item_id:
			var moved = event.position.distance_to(press_start_pos)
			print("release on ", item_id, " moved: ", moved)
			if moved < CLICK_THRESHOLD:
				_open_item_menu(item_id)
				_end_drag(false)
			else:
				_end_drag(true)
func _end_drag(commit_move: bool):
	var icon = icon_nodes.get(dragging_id)
	if commit_move and icon:
		var cell = Vector2i(round(icon.position.x / CELL_SIZE), round(icon.position.y / CELL_SIZE))
		cell.x = clamp(cell.x, 0, GRID_W - 1)
		cell.y = clamp(cell.y, 0, GRID_H - 1)
		InventoryManager.move_item(dragging_id, cell)
	dragging_id = null
	_refresh()

var context_menu: PopupMenu = null

func _open_item_menu(item_id):
	var data = InventoryManager.items[item_id]
	var item_node = data.source_node

	# Clean up any existing menu first
	var old_menu = get_node_or_null("ItemActionMenu")
	if old_menu:
		old_menu.queue_free()

	var menu = PanelContainer.new()
	menu.name = "ItemActionMenu"
	var vbox = VBoxContainer.new()
	menu.add_child(vbox)

	var inspect_btn = Button.new()
	inspect_btn.text = "Inspect"
	inspect_btn.pressed.connect(func():
		_inspect_from_bag(item_id)
		menu.queue_free()
	)
	vbox.add_child(inspect_btn)

	if item_node.is_in_group("equippable"):
		var equip_btn = Button.new()
		equip_btn.text = "Equip"
		equip_btn.pressed.connect(func():
			_equip_from_bag(item_id)
			menu.queue_free()
		)
		vbox.add_child(equip_btn)

	add_child(menu)
	menu.position = Vector2(600, 400)
func _inspect_from_bag(item_id):
	var data = InventoryManager.items[item_id]
	var item_node = data.source_node

	# Close the bag first
	InventoryManager.is_open = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Bring the item back into the world in front of the camera, then inspect it
	var cam = get_viewport().get_camera_3d()
	get_tree().current_scene.add_child(item_node)
	item_node.global_position = cam.global_position + (-cam.global_transform.basis.z * 1.5)
	item_node.visible = true

	InventoryManager.remove_item(item_id)
	item_node.inspect()

func _equip_from_bag(item_id):
	var data = InventoryManager.items[item_id]
	var item_node = data.source_node

	InventoryManager.is_open = false
	visible = false

	get_tree().current_scene.add_child(item_node)
	InventoryManager.remove_item(item_id)

	InspectManager.equip_current_item(item_node)

	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

extends Control

const CELL_SIZE = 64
const GRID_W = 8
const GRID_H = 6

var background: ColorRect
var player_node: Node = null
var is_open = false

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
			return  # don't allow opening bag mid-inspect

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

func _refresh():
	for child in get_children():
		if child != background:
			child.queue_free()

	for item_id in InventoryManager.items:
		var data = InventoryManager.items[item_id]
		var icon_rect = TextureRect.new()
		icon_rect.texture = data.icon
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.position = Vector2(data.grid_pos.x, data.grid_pos.y) * CELL_SIZE
		icon_rect.size = Vector2(data.width, data.height) * CELL_SIZE
		add_child(icon_rect)

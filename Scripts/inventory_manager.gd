extends Node

signal inventory_changed


const GRID_WIDTH = 8
const GRID_HEIGHT = 6

var grid = []
var items = {}
var is_open = false

func _ready():
	for y in GRID_HEIGHT:
		var row = []
		for x in GRID_WIDTH:
			row.append(null)
		grid.append(row)
func can_place(x: int, y: int, w: int, h: int) -> bool:
	if x + w > GRID_WIDTH or y + h > GRID_HEIGHT:
		return false
	for iy in range(y, y + h):
		for ix in range(x, x + w):
			if grid[iy][ix] != null:
				return false
	return true
	
	
	
func move_item(item_id: String, new_pos: Vector2i) -> bool:
	if not items.has(item_id):
		return false
	var data = items[item_id]
	var old_pos = data.grid_pos

	for y in range(old_pos.y, old_pos.y + data.height):
		for x in range(old_pos.x, old_pos.x + data.width):
			grid[y][x] = null

	if can_place(new_pos.x, new_pos.y, data.width, data.height):
		for y in range(new_pos.y, new_pos.y + data.height):
			for x in range(new_pos.x, new_pos.x + data.width):
				grid[y][x] = item_id
		data.grid_pos = new_pos
		inventory_changed.emit()
		return true
	else:
		for y in range(old_pos.y, old_pos.y + data.height):
			for x in range(old_pos.x, old_pos.x + data.width):
				grid[y][x] = item_id
		return false


func find_free_spot(w: int, h: int) -> Vector2i:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if can_place(x, y, w, h):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func add_item(item_node: Node3D) -> bool:
	var spot = find_free_spot(item_node.inv_width, item_node.inv_height)
	if spot.x == -1:
		print("Inventory full for this item's size")
		return false
	for y in range(spot.y, spot.y + item_node.inv_height):
		for x in range(spot.x, spot.x + item_node.inv_width):
			grid[y][x] = item_node.item_id
	items[item_node.item_id] = {
		"icon": item_node.icon,
		"width": item_node.inv_width,
		"height": item_node.inv_height,
		"grid_pos": spot,
		"source_node": item_node
	}
	inventory_changed.emit()
	return true
func remove_item(item_id: String):
	if not items.has(item_id):
		return
	var data = items[item_id]
	var pos = data.grid_pos
	for y in range(pos.y, pos.y + data.height):
		for x in range(pos.x, pos.x + data.width):
			grid[y][x] = null
	items.erase(item_id)
	inventory_changed.emit()

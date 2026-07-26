extends Node3D

@export var item_id: String = "lamp"          # unique per item type
@export var icon: Texture2D                     # drag your icon png in the Inspector
@export var inv_width: int = 1                   # cells wide, like RE's grid
@export var inv_height: int = 2                  # cells tall
@export var is_collectible: bool = true         # goes to inventory vs stays equippable-only
var item_name = "lamp_test01"
var item_description = "just lamp"
var is_readable = false
var readable_text = ""
var inspect_type = "move"
var inspect_distance = 1
@export var equip_position: Vector3 = Vector3.ZERO
@export var equip_rotation_degrees: Vector3 = Vector3.ZERO

func inspect():
	InspectManager.start_inspect(self)

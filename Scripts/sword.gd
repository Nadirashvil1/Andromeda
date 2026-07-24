extends Node3D


@export var item_id: String = "sword"          # unique per item type
@export var icon: Texture2D                     # drag your icon png in the Inspector
@export var inv_width: int = 1                   # cells wide, like RE's grid
@export var inv_height: int = 2                  # cells tall
@export var is_collectible: bool = true          # goes to inventory vs stays equippable-only
@export var item_name: String = "Test_Sword01"
@export var item_description: String = "Test"
var is_readable = false
var readable_text = ""
var inspect_type = "move"
var inspect_distance = 0.9
@export var equip_position: Vector3 = Vector3(0.15, -0.2, -0.3)
@export var equip_rotation_degrees: Vector3 = Vector3(0, 0, -70)

func inspect():
	InspectManager.start_inspect(self)

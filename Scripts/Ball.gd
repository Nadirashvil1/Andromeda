extends RigidBody3D

var item_name = "Ball"
var item_description = "A worn leather ball."
var is_readable = false
var readable_text = ""
var inspect_type = "move"
var inspect_distance = 0.6

@export var item_id: String = "ball"
@export var icon: Texture2D
@export var inv_width: int = 1
@export var inv_height: int = 1
@export var is_collectible: bool = false

@export var equip_position: Vector3 = Vector3.ZERO
@export var equip_rotation_degrees: Vector3 = Vector3.ZERO

func inspect():
	InspectManager.start_inspect(self)

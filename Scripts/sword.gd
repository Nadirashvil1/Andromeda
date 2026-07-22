extends Node3D

var item_name = "Test_Sword01"
var item_description = "Test"
var is_readable = false
var readable_text = ""
var inspect_type = "move"
var inspect_distance = 0.9
@export var equip_position: Vector3 = Vector3(0.15, -0.2, -0.3)
@export var equip_rotation_degrees: Vector3 = Vector3(0, 0, -70)

func inspect():
	InspectManager.start_inspect(self)

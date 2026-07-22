extends Node3D

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

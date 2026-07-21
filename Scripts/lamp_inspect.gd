extends Node3D

var item_name = "lamp_test01"
var item_description = "just lamp"
var is_readable = false
var readable_text = ""
var inspect_type = "move"
var inspect_distance = 1

func inspect():
	InspectManager.start_inspect(self)

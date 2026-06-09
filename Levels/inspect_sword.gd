extends Node3D

var item_name = "Test_Sword01"
var item_description = "Test"
var is_readable = false
var readable_text = ""
var inspect_type = "move"

func inspect():
	InspectManager.start_inspect(self)

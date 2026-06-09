extends Node3D

var inspect_type = "pin"
var item_name = "Test_Painting"
var item_description = "Test"
var is_readable = false
var readable_text = ""

func inspect():
	InspectManager.start_inspect(self)

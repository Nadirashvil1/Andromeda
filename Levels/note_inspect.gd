extends Node3D

var item_name = "Test_note"
var item_description = "Test"
var is_readable = true
var readable_text = "hello world\n\nThis is the content of the note. It can be as long as you want and will wrap automatically."
var inspect_type = "move"
var inspect_distance = 0.2

func inspect():
	InspectManager.start_inspect(self)

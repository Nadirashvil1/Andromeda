extends Node3D



@export var item_id: String = "note"          # unique per item type
@export var icon: Texture2D                     # drag your icon png in the Inspector
@export var inv_width: int = 1                   # cells wide, like RE's grid
@export var inv_height: int = 2                  # cells tall
@export var is_collectible: bool = true          # goes to inventory vs stays equippable-only
var item_name = "Test_note"
var item_description = "Test"
var is_readable = true
var readable_text = "hello world\n\nThis is the content of the note. It can be as long as you want and will wrap automatically."
var inspect_type = "move"
var inspect_distance = 0.2

func inspect():
	InspectManager.start_inspect(self)
